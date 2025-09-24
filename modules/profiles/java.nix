{ pkgs, ... }:
{
  programs.java.enable = true;

  environment.systemPackages = [
    pkgs.jdk8
    pkgs.jdk11
    pkgs.maven
  ];
}
