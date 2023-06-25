{ pkgs, ... }: {
  programs.htop.enable = true;

  environment = {
    defaultPackages = [ ];

    systemPackages = [
      pkgs.bind
      pkgs.cryptsetup
      pkgs.curl
      pkgs.deadnix
      pkgs.dmidecode
      pkgs.dnsutils
      pkgs.file
      pkgs.gdb
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
      pkgs.gnutar
      pkgs.traceroute
      pkgs.tree
      pkgs.unzip
      pkgs.zip
    ];
  };
}
