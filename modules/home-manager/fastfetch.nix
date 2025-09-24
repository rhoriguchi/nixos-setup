{
  colors,
  config,
  lib,
  pkgs,
  ...
}:
{
  home.packages = [ pkgs.nerd-fonts.roboto-mono ];

  programs.zsh.shellAliases.neofetch = "${config.programs.fastfetch.package}/bin/fastfetch --config neofetch";

  programs.fastfetch = {
    enable = true;

    settings = {
      "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";

      logo.padding.top = 1;

      display.separator = " 󰑃 ";

      modules = [
        "break"

        {
          type = "os";
          key = " DISTRO";
          format = "{name} {version-id} ({codename}) {arch}";
          keyColor = colors.normal.accent;
        }
        {
          type = "kernel";
          key = "│ ├";
          keyColor = colors.normal.accent;
        }
        {
          type = "packages";
          key = "│ ├󰏖";
          keyColor = colors.normal.accent;
        }
        {
          type = "shell";
          key = "│ ├";
          keyColor = colors.normal.accent;
        }
        {
          type = "command";
          key = "│ └";
          text = "birth_install=${
            lib.concatStringsSep "; " [
              "$(stat -c %W /)"
              "current=$(date +%s)"
              "time_progression=$((current - birth_install))"
              "days_difference=$((time_progression / 86400))"
              "echo $days_difference days"
            ]
          }";
          keyColor = colors.normal.accent;
        }

        {
          type = "wm";
          key = " DE/WM";
          keyColor = colors.normal.accent;
        }
        {
          type = "theme";
          key = "│ ├󰉼";
          keyColor = colors.normal.accent;
        }
        {
          type = "icons";
          key = "│ ├󰀻";
          keyColor = colors.normal.accent;
        }
        {
          type = "cursor";
          key = "│ ├";
          keyColor = colors.normal.accent;
        }
        {
          type = "terminalfont";
          key = "│ ├";
          keyColor = colors.normal.accent;
        }
        {
          type = "terminal";
          key = "│ └";
          keyColor = colors.normal.accent;
        }

        {
          type = "host";
          key = "󰌢 SYSTEM";
          keyColor = colors.normal.accent;
        }
        {
          type = "cpu";
          key = "│ ├󰻠";
          format = "{name}";
          keyColor = colors.normal.accent;
        }
        {
          type = "gpu";
          key = "│ ├󰻑";
          format = "{name}";
          keyColor = colors.normal.accent;
        }
        {
          type = "display";
          key = "│ ├󰍹";
          compactType = "original-with-refresh-rate";
          keyColor = colors.normal.accent;
        }
        {
          type = "memory";
          key = "│ ├󰾆";
          percent.type = [ "num" ];
          keyColor = colors.normal.accent;
        }
        {
          type = "disk";
          key = "│ ├󰉉";
          format = "({mountpoint}) {size-used} / {size-total} ({size-percentage})";
          percent.type = [ "num" ];
          keyColor = colors.normal.accent;
        }
        {
          type = "uptime";
          key = "│ └󰅐";
          keyColor = colors.normal.accent;
        }

        "break"

        "colors"

        "break"
      ];
    };
  };
}
