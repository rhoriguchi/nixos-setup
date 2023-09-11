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
      pkgs.gnugrep
      pkgs.gnutar
      pkgs.jq
      pkgs.killall
      pkgs.nixfmt
      pkgs.nmap
      pkgs.openssl
      pkgs.pciutils
      pkgs.procps
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
}
