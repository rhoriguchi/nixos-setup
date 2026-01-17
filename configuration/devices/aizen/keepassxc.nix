{ pkgs, ... }:
let
  script = pkgs.writeShellScript "keepassxc.sh" ''
    ${pkgs.libsecret}/bin/secret-tool lookup KeePass 2FA | keepassxc --pw-stdin "$HOME/Sync/KeePass/2FA.kdbx"
  '';

  keepassxc = pkgs.symlinkJoin {
    inherit (pkgs.keepassxc) name pname version;
    paths = [ pkgs.keepassxc ];

    postBuild = ''
      cp --remove-destination $(realpath $out/share/applications/org.keepassxc.KeePassXC.desktop) $out/share/applications/org.keepassxc.KeePassXC.desktop
      substituteInPlace $out/share/applications/org.keepassxc.KeePassXC.desktop \
        --replace-fail "Exec=keepassxc %f" "Exec=${script}" \
        --replace-fail "TryExec=keepassxc" "TryExec=${script}"
    '';
  };
in
{
  environment.systemPackages = [ keepassxc ];
}
