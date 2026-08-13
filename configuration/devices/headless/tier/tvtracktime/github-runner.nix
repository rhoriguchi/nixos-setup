{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  containerCfg = config.containers.tvtracktime-github-runner.config;

  inherit (containerCfg.services.github-runners.tvtracktime) user group;
in
{
  containers.tvtracktime-github-runner = {
    autoStart = true;
    ephemeral = true;

    # Allow BPF system calls and capabilities required by the nested Docker
    # daemon inside systemd-nspawn (same workaround as the podman-in-nspawn
    # setup in ./application.nix).
    additionalCapabilities = [
      "CAP_BPF"
      "CAP_SYS_ADMIN"
    ];

    extraFlags = [
      "--system-call-filter=bpf"
    ];

    privateUsers = "pick";

    privateNetwork = true;
    hostAddress = "169.254.1.1";
    localAddress = "169.254.1.77";

    config = {
      nixpkgs.pkgs = pkgs;
      system.stateVersion = config.system.stateVersion;

      virtualisation.docker.enable = true;

      # actions/setup-java and actions/setup-node download prebuilt binaries
      # that expect an FHS-style dynamic linker, which NixOS doesn't provide.
      programs.nix-ld.enable = true;

      systemd.tmpfiles.rules = [
        "d /run/${user} 0700 ${user} ${group}"
        "f+ /run/${user}/github-runner-token 0400 ${user} ${group} - ${secrets.tvtracktime.githubRunnerToken}"
      ];

      users = {
        users.${user} = {
          isSystemUser = true;
          inherit group;
          extraGroups = [ "docker" ];
        };

        groups.${group} = { };
      };

      services.github-runners.tvtracktime = {
        enable = true;

        ephemeral = true;
        replace = true;

        name = "tvtracktime-runner";
        url = "https://github.com/rhoriguchi/tvtracktime";

        user = "github-runner";
        group = "github-runner";

        tokenFile = "/run/${user}/github-runner-token";

        extraLabels = [ "nixos" ];

        extraPackages = [ pkgs.docker-buildx ];
      };

      systemd.services.github-runner-tvtracktime.serviceConfig = {
        Restart = lib.mkForce "always";
        RestartSec = 5;
      };
    };
  };
}
