{
  colors,
  config,
  lib,
  libCustom,
  ...
}:
{
  programs = {
    grep = {
      enable = true;

      colors.mt = libCustom.ansiColorCode colors.normal.accent { bold = true; };
    };

    zsh.shellAliases.grep = lib.mkIf config.programs.grep.enable "${config.programs.grep.package}/bin/grep --color=auto";
  };
}
