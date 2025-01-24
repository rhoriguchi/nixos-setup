{ config, ... }: {
  imports = [ ./ghostty.nix ];

  home.sessionVariables.TERMINAL = "ghostty";

  programs.vscode.userSettings."terminal.external.linuxExec" = "${config.programs.ghostty.package}/bin/ghostty";
}
