{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.curl
    pkgs.deadnix
    pkgs.file
    pkgs.jq
    pkgs.nixfmt
    pkgs.openssl
    pkgs.sshpass
    pkgs.tree
    pkgs.unzip
    pkgs.zip
  ];
}
