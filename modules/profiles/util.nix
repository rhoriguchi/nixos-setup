{ pkgs, ... }: {
  programs.htop.enable = true;

  environment = {
    defaultPackages = [ ];

    systemPackages = [
      pkgs.cryptsetup
      pkgs.curl
      pkgs.deadnix
      pkgs.dmidecode
      pkgs.file
      pkgs.git
      pkgs.glances
      pkgs.jq
      pkgs.nixfmt
      pkgs.nmap
      pkgs.openssl
      pkgs.pciutils
      pkgs.rsync
      pkgs.speedtest-cli
      pkgs.sshpass
      pkgs.strace
      pkgs.traceroute
      pkgs.tree
      pkgs.unzip
      pkgs.zip
    ];
  };

  services.fwupd.enable = true;
}
