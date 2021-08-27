{ pkgs, config, ... }:
let
  accountServiceConfig = (pkgs.formats.ini { }).generate "accountServiceConfig.ini" {
    User = {
      Icon = "${./icon.jpg}";
      Language = "";
      Session = "";
      SystemAccount = config.users.users.rhoriguchi.isSystemUser;
      XSession = "";
    };
  };
in { system.activationScripts.rhoriguchiCopyAccountServiceConfig = "cp -f ${accountServiceConfig} /var/lib/AccountsService/users/rhoriguchi"; }
