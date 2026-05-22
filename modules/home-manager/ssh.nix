{
  config,
  lib,
  libCustom,
  ...
}:
let
  home = config.home.homeDirectory;

  tailscaleIps = import (
    libCustom.relativeToRoot "configuration/devices/headless/nelliel/headscale/ips.nix"
  );
  filteredTailscaleIps = lib.filterAttrs (
    key: _:
    !(lib.elem key [
      "headplane-agent"
      "XXLPitu-Nnoitra"
    ])
  ) tailscaleIps;
in
{
  programs.ssh = {
    enable = true;

    enableDefaultConfig = false;

    settings = {
      "*" = {
        IdentityFile = "${home}/.ssh/id_ed25519";

        Compression = true;
        ControlPath = "${home}/.ssh/master-%r@%n:%p";
        AddKeysToAgent = "yes";
        ServerAliveInterval = 10;
        ConnectionAttempts = 3;
        UserKnownHostsFile = "${home}/.ssh/known_hosts";
      };

      "github.com" = {
        User = "git";
        IdentityFile = "${home}/.ssh/github_ed25519";
      };

      "gitlab.com" = {
        User = "git";
        IdentityFile = "${home}/.ssh/gitlab_ed25519";
      };

      "jcrk.synology.me" = {
        User = "xxlpitu";
        Port = 10022;
      };
    }
    // (lib.mapAttrs' (
      key: value:
      lib.nameValuePair (lib.toLower key) {
        Hostname = value;
        User = "xxlpitu";
        HostKeyAlias = lib.toLower key;
      }
    ) filteredTailscaleIps);
  };
}
