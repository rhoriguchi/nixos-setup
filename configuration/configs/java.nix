{ pkgs, ... }: {
  programs.java.enable = true;

  environment.systemPackages = [ pkgs.maven ];
}
