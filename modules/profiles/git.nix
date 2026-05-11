{ pkgs, ... }:
{
  programs = {
    git = {
      enable = true;

      lfs.enable = true;
    };

    gnupg.agent.enable = true;
  };

  environment.systemPackages = [ pkgs.git-crypt ];
}
