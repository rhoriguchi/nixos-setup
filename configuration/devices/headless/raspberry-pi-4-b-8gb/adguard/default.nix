{
  imports = [
    ../common.nix

    ./adguardhome.nix
  ];

  networking.hostName = "AdGuard";

  services.wireguard-network = {
    enable = true;

    type = "client";
  };
}
