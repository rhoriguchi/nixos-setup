{ pkgs, ... }: {
  programs.npm.enable = true;

  environment.systemPackages = [ pkgs.nodejs pkgs.nodePackages.prettier pkgs.yarn ];
}
