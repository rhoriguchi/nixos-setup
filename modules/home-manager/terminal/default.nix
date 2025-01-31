{ config, lib, ... }: {
  imports = [ ./ghostty.nix ];

  home.sessionVariables.TERMINAL = "ghostty";

  # Don't set if `null`, `userSettings` uses mkMerge so options can't be overwritten
  programs.vscode.userSettings = lib.optionalAttrs (config.programs.ghostty.package != null) {
    "terminal.external.linuxExec" = "${config.programs.ghostty.package}/bin/ghostty";
  };
}
