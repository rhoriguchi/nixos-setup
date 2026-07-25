{ pkgs, ... }:
{
  programs.npm.enable = true;

  environment.systemPackages = [
    pkgs.eslint
    pkgs.nodejs
    pkgs.prettier
    pkgs.typescript
    pkgs.yarn
  ];
}
