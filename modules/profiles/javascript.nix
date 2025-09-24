{ pkgs, ... }:
{
  programs.npm.enable = true;

  environment.systemPackages = [
    pkgs.eslint
    pkgs.nodejs
    pkgs.nodePackages.prettier
    pkgs.nodePackages.ts-node
    pkgs.typescript
    pkgs.yarn
  ];
}
