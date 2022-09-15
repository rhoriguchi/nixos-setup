{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.curl
    pkgs.deadnix
    pkgs.file
    pkgs.jq
    pkgs.nixfmt
    pkgs.nmap
    pkgs.openssl
    pkgs.speedtest-cli
    pkgs.sshpass
    pkgs.tree
    pkgs.unzip
    pkgs.zip
  ];
}
