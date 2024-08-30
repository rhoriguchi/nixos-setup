{ pkgs, ... }: {
  imports = [ ./guest.nix ./network.nix ./storage.nix ];

  security.polkit.enable = true;

  virtualisation.libvirtd.enable = true;

  services.netdata.configDir = {
    "go.d/windows.conf" = (pkgs.formats.yaml { }).generate "windows.conf" {
      jobs = [{
        name = "Ryan-Desktop";
        vnode = "Ryan-Desktop";
        url = "http://172.16.1.2:9182/metrics";
      }];
    };

    "vnodes/vnodes.conf" = (pkgs.formats.yaml { }).generate "vnodes.conf" [{
      hostname = "Ryan-Desktop";
      guid = "08992515-3e60-4f96-826c-bffe4f19da7d";
    }];
  };
}
