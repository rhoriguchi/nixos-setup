{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.gradle
    pkgs.kotlin
  ];
}
