{ pkgs, lib, config, ... }: {
  imports = [ ../../configs/fancy-motd.nix ../../configs/nginx.nix ];

  nix.gc = {
    automatic = true;
    dates = "05:00";
    options = "--delete-older-than 7d";
  };

  security.acme.defaults.email = "ryan.horiguchi@gmail.com";

  networking.networkmanager = {
    ethernet.macAddress = "permanent";
    wifi.macAddress = "permanent";
  };

  environment.systemPackages = [ pkgs.glances pkgs.htop ];

  users.users.xxlpitu = {
    extraGroups = [ "wheel" ] ++ (lib.optional config.virtualisation.docker.enable "docker")
      ++ (lib.optionals config.virtualisation.libvirtd.enable [ "kvm" "libvirtd" ]);
    isNormalUser = true;
    password = (import ../../secrets.nix).users.users.xxlpitu.password;
    openssh.authorizedKeys.keys = import ../../authorized-keys.nix;
  };

  system.activationScripts.createZshrc = lib.mkIf config.programs.zsh.enable (let
    normalUsers = lib.filter (user: user.isNormalUser == true) (lib.attrValues config.users.users);
    commands = map (user: "touch ${user.home}/.zshrc") normalUsers;
  in lib.concatStringsSep "\n" commands);
}
