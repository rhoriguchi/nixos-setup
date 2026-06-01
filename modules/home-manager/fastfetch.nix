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
          type = "OS";
          key = " DISTRO";
          format = "{name} {version-id} ({codename}) {arch}";
          keyColor = colors.normal.accent;
        }
        {
          type = "Kernel";
          key = "│ ├";
          keyColor = colors.normal.accent;
        }
        {
          type = "Packages";
          key = "│ ├󰏖";
          keyColor = colors.normal.accent;
        }
        {
          type = "Shell";
          key = "│ ├";
          keyColor = colors.normal.accent;
        }
        {
          type = "Command";
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
          type = "WM";
          key = " DE/WM";
          keyColor = colors.normal.accent;
        }
        {
          type = "WMTheme";
          key = "│ ├󰉼";
          keyColor = colors.normal.accent;
        }
        {
          type = "lm";
          key = "│ ├󰍂";
          keyColor = colors.normal.accent;
        }
        {
          type = "Icons";
          key = "│ ├󰀻";
          keyColor = colors.normal.accent;
        }
        {
          type = "Cursor";
          key = "│ ├";
          keyColor = colors.normal.accent;
        }
        {
          type = "TerminalFont";
          key = "│ ├";
          keyColor = colors.normal.accent;
        }
        {
          type = "Terminal";
          key = "│ └";
          keyColor = colors.normal.accent;
        }

        {
          type = "Host";
          key = "󰌢 SYSTEM";
          keyColor = colors.normal.accent;
        }
        {
          type = "CPU";
          key = "│ ├󰻠";
          format = "{name}";
          keyColor = colors.normal.accent;
        }
        {
          type = "GPU";
          key = "│ ├󰻑";
          format = "{name}";
          keyColor = colors.normal.accent;
        }
        {
          type = "Display";
          key = "│ ├󰍹";
          compactType = "original-with-refresh-rate";
          keyColor = colors.normal.accent;
        }
        {
          type = "Memory";
          key = "│ ├󰾆";
          percent.type = [ "num" ];
          keyColor = colors.normal.accent;
        }
        {
          type = "Disk";
          key = "│ ├󰉉";
          format = "({mountpoint}) {size-used} / {size-total} ({size-percentage})";
          percent.type = [ "num" ];
          keyColor = colors.normal.accent;
        }
        {
          type = "Uptime";
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
