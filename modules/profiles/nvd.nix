{ pkgs, ... }: {
  environment = {
    systemPackages = [ pkgs.nvd ];

    shellAliases.changes = ''
      ${pkgs.nvd}/bin/nvd diff $(${pkgs.coreutils}/bin/ls -dv /nix/var/nix/profiles/system-*-link | ${pkgs.coreutils}/bin/tail -2) 2> /dev/null || echo "No generations to compare"'';
  };
}
