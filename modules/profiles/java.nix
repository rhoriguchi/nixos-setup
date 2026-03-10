{ pkgs, ... }:
{
  programs.java.enable = true;

  environment.systemPackages = [
    pkgs.jdk11
    pkgs.jdk8
    pkgs.jetbrains.idea-oss
    pkgs.maven
  ];
}
