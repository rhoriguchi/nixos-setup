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
      pkgs.expect
      pkgs.file
      pkgs.gdb
      pkgs.git
      pkgs.gnugrep
      pkgs.gnutar
      pkgs.ipcalc
      pkgs.iproute2
      pkgs.jq
      pkgs.killall
      pkgs.mtr
      pkgs.nano
      pkgs.nixfmt-classic
      pkgs.nmap
      pkgs.openssl
      pkgs.pciutils
      pkgs.postgresql
      pkgs.procps
      pkgs.rsync
      pkgs.smartmontools
      pkgs.speedtest-cli
      pkgs.sshpass
      pkgs.strace
      pkgs.tcpdump
      pkgs.traceroute
      pkgs.tree
      pkgs.unzip
      pkgs.usbutils
      pkgs.yq-go
      pkgs.zip
    ];
  };
}
