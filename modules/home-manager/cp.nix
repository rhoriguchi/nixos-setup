{ pkgs, ... }: { programs.zsh.shellAliases.cp-with-progress = ''f(){ cp "$@" & ${pkgs.progress}/bin/progress -mp $!; unset -f f; }; f''; }
