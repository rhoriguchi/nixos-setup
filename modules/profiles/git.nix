{ pkgs, ... }: {
  environment.systemPackages = [ pkgs.git pkgs.git-crypt pkgs.git-lfs ];

  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };
}
