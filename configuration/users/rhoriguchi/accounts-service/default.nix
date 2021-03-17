{ pkgs, config, ... }:
let
  configFile = (pkgs.formats.ini { }).generate "rhoriguchi" {
    User = {
      Icon = "${./icon.jpg}";
      Language = "";
      Session = "";
      SystemAccount = config.users.users.rhoriguchi.isSystemUser;
      XSession = "";
    };
  };
in {
  system.activationScripts.rhoriguchiCopyAccountServiceConfig = ''
    ${pkgs.coreutils}/bin/cp -f ${configFile} /var/lib/AccountsService/users/rhoriguchi
  '';
}
