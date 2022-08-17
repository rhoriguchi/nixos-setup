{ pkgs, ... }: {
  environment.systemPackages = [
    pkgs.git
    pkgs.git-crypt
    pkgs.git-lfs
    pkgs.gitkraken
  ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
