{ pkgs, ... }: {
  programs.htop.enable = true;

  environment = {
    defaultPackages = [ ];

    systemPackages = [
      pkgs.curl
      pkgs.deadnix
      pkgs.file
      pkgs.glances
      pkgs.jq
      pkgs.nixfmt
      pkgs.nmap
      pkgs.openssl
      pkgs.pciutils
      pkgs.rsync
      pkgs.speedtest-cli
      pkgs.sshpass
      pkgs.tree
      pkgs.unzip
      pkgs.zip
    ];
  };
}
