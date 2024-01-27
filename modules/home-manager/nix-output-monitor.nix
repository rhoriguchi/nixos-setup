{ pkgs, ... }: {
  home.packages = [ pkgs.nix-output-monitor ];

  programs.zsh.shellAliases = {
    "nix build" = "${pkgs.nix-output-monitor}/bin/nom build";
    "nix shell" = "${pkgs.nix-output-monitor}/bin/nom shell";
    "nix develop" = "${pkgs.nix-output-monitor}/bin/nom develop";

    nix-build = "${pkgs.nix-output-monitor}/bin/nom-build";
    nix-shell = "${pkgs.nix-output-monitor}/bin/nom-shell";
  };
}
