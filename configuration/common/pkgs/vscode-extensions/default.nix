{ vscode-extensions, callPackage }:
vscode-extensions // {
  shan.code-settings-sync = callPackage ./code-settings-sync.nix { };
}
