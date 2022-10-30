{ pkgs, ... }: {
  programs.java.enable = true;

  environment.systemPackages = [ pkgs.jdk11 pkgs.maven ];
}
