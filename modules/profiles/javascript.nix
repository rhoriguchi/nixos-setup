{ pkgs, ... }:
{
  programs.npm.enable = true;

  environment.systemPackages = [
    pkgs.eslint
    pkgs.prettier
    pkgs.typescript
    pkgs.yarn
  ];
}
