{ pkgs, ... }: {
  home.packages = [ pkgs.sops ];

  programs.git.extraConfig.diff.sopsdiffer.textconv = "sops --decrypt --config /dev/null";
}
