{ pkgs, ... }: {
  environment = {
    systemPackages = [ pkgs.nvd ];

    shellAliases."changes" = "nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)";
  };
}
