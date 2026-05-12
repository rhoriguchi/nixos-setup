{
  config,
  lib,
  pkgs,
  ...
}:
{
  programs = {
    htop.enable = true;
    mtr.enable = true;
    nano.enable = true;
    vim.enable = true;
  };

  environment = {
    defaultPackages = [ ];

    systemPackages = [
      pkgs.bind
      pkgs.conntrack-tools
      pkgs.cryptsetup
      pkgs.curl
      pkgs.deadnix
      pkgs.dmidecode
      pkgs.dnsutils
      pkgs.ethtool
      pkgs.expect
      pkgs.file
      pkgs.gnugrep
      pkgs.gnutar
      pkgs.ipcalc
      pkgs.iproute2
      pkgs.jq
      pkgs.killall
      pkgs.nixfmt
      pkgs.nixfmt-tree
      pkgs.nmap
      pkgs.openssl
      pkgs.pciutils
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
    ]
    ++ lib.optional config.services.postgresql.enable pkgs.postgresql;
  };
}
