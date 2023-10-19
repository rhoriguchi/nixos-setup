{ pkgs, ... }: {
  programs.npm.enable = true;

  environment.systemPackages = [ pkgs.nodejs pkgs.nodePackages.eslint pkgs.nodePackages.prettier pkgs.nodePackages.ts-node pkgs.yarn ];
}
