{ pkgs, ... }: {
  environment = {
    systemPackages = [ pkgs.nvd ];

    shellAliases.changes =
      ''${pkgs.nvd}/bin/nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2) 2> /dev/null || echo "No generations to compare"'';
  };
}
