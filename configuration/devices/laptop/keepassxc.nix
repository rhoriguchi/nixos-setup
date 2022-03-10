{ pkgs, config, ... }:
let
  script = pkgs.writeShellScript "keepassxc.sh" ''
    ${pkgs.libsecret}/bin/secret-tool lookup KeePass 2FA | keepassxc --pw-stdin "${config.services.resilio.syncPath}/KeePass/2FA.kdbx"
  '';

  keepassxc = pkgs.keepassxc.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      substituteInPlace $out/share/applications/org.keepassxc.KeePassXC.desktop \
        --replace "Exec=keepassxc %f" "Exec=${script}" \
        --replace "TryExec=keepassxc" "TryExec=${script}"
    '';
  });
in { environment.systemPackages = [ keepassxc ]; }
