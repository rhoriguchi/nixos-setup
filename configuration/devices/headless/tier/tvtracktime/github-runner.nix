{
  config,
  lib,
  pkgs,
  secrets,
  ...
}:
let
  user = index: "github-runner-${toString index}";
  group = index: "github-runner-${toString index}";

  agentCount = 5;
  agentIndices = lib.range 1 agentCount;
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

      systemd.tmpfiles.rules = lib.flatten (
        map (index: [
          "d /run/${user index} 0700 ${user index} ${group index}"
          "d /run/${user index}/home 0700 ${user index} ${group index}"
          "f+ /run/${user index}/github-runner-token 0400 ${user index} ${group index} - ${secrets.tvtracktime.githubRunnerToken}"
        ]) agentIndices
      );

      users = {
        users = lib.pipe agentIndices [
          (map (
            index:
            lib.nameValuePair (user index) {
              isSystemUser = true;
              group = group index;
              extraGroups = [ "docker" ];
            }
          ))

          lib.listToAttrs
        ];

        groups = lib.pipe agentIndices [
          (map (index: lib.nameValuePair (group index) { }))
          lib.listToAttrs
        ];
      };

      services.github-runners = lib.pipe agentIndices [
        (map (
          index:
          lib.nameValuePair "tvtracktime-${toString index}" {
            enable = true;

            ephemeral = true;
            replace = true;

            name = "tvtracktime-runner-${toString index}";
            url = "https://github.com/rhoriguchi/tvtracktime";

            user = user index;
            group = group index;

            tokenFile = "/run/${user index}/github-runner-token";

            extraLabels = [ "nixos" ];

            extraPackages = [
              config.virtualisation.docker.package

              # backend
              pkgs.curl
              pkgs.unzip
            ];

            extraEnvironment.MAVEN_OPTS = "-Duser.home=/run/${user index}/home";
          }
        ))

        lib.listToAttrs
      ];

      systemd.services = lib.pipe agentIndices [
        (map (
          index:
          lib.nameValuePair "github-runner-tvtracktime-${toString index}" {
            serviceConfig = {
              Restart = lib.mkForce "always";
              RestartSec = 5 + (index * 3);
            };
          }
        ))

        lib.listToAttrs
      ];
    };
  };
}
