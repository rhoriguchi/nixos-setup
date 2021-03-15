{ pkgs, ... }: {
  home-manager.users.rhoriguchi.xdg.configFile."flameshot/flameshot.ini".source =
    (pkgs.formats.ini { }).generate "flameshot.ini" {
      General = {
        buttons = ''
          @Variant(\0\0\0\x7f\0\0\0\vQList<int>\0\0\0\0\x12\0\0\0\0\0\0\0\x1\0\0\0\x2\0\0\0\x3\0\0\0\x4\0\0\0\x5\0\0\0\x6\0\0\0\x12\0\0\0\xf\0\0\0\x13\0\0\0\a\0\0\0\b\0\0\0\t\0\0\0\x10\0\0\0\n\0\0\0\v\0\0\0\f\0\0\0\r)
        '';
        contrastUiColor = "#D06DDE";
        copyAndCloseAfterUpload = true;
        disabledTrayIcon = false;
        drawColor = "#FF4136";
        drawThickness = 0;
        filenamePattern = "%Y_%m_%d_%H:%M:%S";
        saveAfterCopyPath = "/home/rhoriguchi/Pictures";
        showHelp = false;
        uiColor = "#B10DC9";
      };
    };
}
