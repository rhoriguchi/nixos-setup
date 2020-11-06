{ lib, config, pkgs, ... }:
with lib;
let
  cfg = config.mal_export;

  malExport = pkgs.mach-nix.buildPythonApplication rec {
    pname = "mal_export";
    version = "1.0.2";

    src = pkgs.fetchFromGitHub {
      owner = "rhoriguchi";
      repo = pname;
      rev = version;
      sha256 = "1nvgp60f07phxnkb6lp80is458wz0nqxpimry4p1bgd74fx8v840";
    };
  };

  configFile = pkgs.writeText "config.yaml" ''
    username: ${cfg.username}
    password: ${cfg.password}
    save_path: ${cfg.exportPath}
  '';
in {
  options.mal_export = {
    enable = mkEnableOption "mal_export";
    exportPath = mkOption { type = types.str; };
    username = mkOption { type = types.str; };
    password = mkOption { type = types.str; };
  };

  config = mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.exportPath != "";
        message = "Export path cannot be empty.";
      }
      {
        assertion = cfg.username != "";
        message = "Username cannot be empty.";
      }
      {
        assertion = cfg.password != "";
        message = "Password cannot be empty.";
      }
    ];

    users.users.mal_export = {
      isSystemUser = true;
      extraGroups = optional config.rslsync.enable "rslsync";
    };

    systemd.services.mal_export = {
      after = [ "network.target" ];
      description = "mal_export";
      serviceConfig = {
        ExecStart = "${malExport}/bin/mal_export ${configFile}";
        ExecStartPre = "${pkgs.busybox}/bin/mkdir -p ${cfg.exportPath}";
        Restart = "on-abort";
        UMask = "0007";
        User = "mal_export";
      };
      startAt = "06:00";
    };
  };
}
