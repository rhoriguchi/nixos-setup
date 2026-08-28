{ pkgs, ... }:
{
  programs.java.enable = true;

  environment.systemPackages = [
    pkgs.jetbrains.idea-oss
    pkgs.maven
  ];
}
