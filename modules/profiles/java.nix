{ pkgs, ... }:
{
  programs.java.enable = true;

  environment.systemPackages = [
    pkgs.intellij-idea-oss
    pkgs.maven
  ];
}
