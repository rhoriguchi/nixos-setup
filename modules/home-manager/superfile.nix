{
  colors,
  config,
  lib,
  pkgs,
  ...
}:
let
  bookmarks = (
    map (
      bookmark:
      let
        splits = lib.splitString " " bookmark;
      in
      {
        name = lib.replaceStrings [ "file://${config.home.homeDirectory}/" ] [ "" ] (
          builtins.elemAt splits (builtins.length splits - 1)
        );
        location = lib.replaceStrings [ "file://" ] [ "" ] (lib.head splits);
      }
    ) (lib.filter (bookmark: !(lib.hasPrefix "sftp://" bookmark)) config.gtk.gtk3.bookmarks)
  );
in
{
  # TODO use options merged https://github.com/nix-community/home-manager/pull/7806
  xdg.dataFile = {
    "superfile/pinned.json".source = (pkgs.formats.json { }).generate "pinned.json" bookmarks;

    "superfile/firstUseCheck".text = "";
  };

  programs = {
    zsh.shellAliases.spf = "${config.programs.superfile.package}/bin/superfile";

    superfile = {
      enable = true;

      settings = {
        theme = "Custom";

        auto_check_update = false;

        cd_on_quit = true;

        code_previewer = lib.optionalString config.programs.bat.enable "bat";

        ignore_missing_fields = true;

        # Plugins
        metadata = true;
        zoxide_support = true;
      };

      hotkeys.pinned_folder = [ ];

      themes.Custom = {
        file_panel_border = colors.extra.terminal.border;
        sidebar_border = colors.extra.terminal.border;
        footer_border = colors.extra.terminal.border;

        file_panel_border_active = colors.normal.accent;
        sidebar_border_active = colors.normal.accent;
        footer_border_active = colors.normal.accent;
        modal_border_active = colors.normal.accent;

        full_screen_bg = colors.extra.terminal.background;
        file_panel_bg = colors.extra.terminal.background;
        sidebar_bg = colors.extra.terminal.background;
        footer_bg = colors.extra.terminal.background;
        modal_bg = colors.extra.terminal.background;

        full_screen_fg = colors.normal.white;
        file_panel_fg = colors.normal.white;
        sidebar_fg = colors.normal.white;
        footer_fg = colors.normal.white;
        modal_fg = colors.normal.white;

        cursor = colors.normal.accent;
        correct = colors.normal.green;
        error = colors.normal.red;
        hint = "#73c7ec";
        cancel = colors.bright.red;
        gradient_color = [
          colors.normal.white
          colors.normal.white
        ];

        file_panel_top_directory_icon = colors.normal.white;
        file_panel_top_path = colors.normal.white;
        file_panel_item_selected_fg = colors.normal.accent;
        file_panel_item_selected_bg = colors.extra.terminal.background;

        sidebar_title = colors.extra.terminal.border;
        sidebar_item_selected_fg = colors.normal.accent;
        sidebar_item_selected_bg = colors.extra.terminal.background;
        sidebar_divider = colors.extra.terminal.border;

        modal_cancel_fg = colors.extra.terminal.background;
        modal_cancel_bg = colors.bright.red;
        modal_confirm_fg = colors.extra.terminal.background;
        modal_confirm_bg = colors.bright.cyan;

        help_menu_hotkey = colors.bright.cyan;
        help_menu_title = colors.extra.terminal.border;
      };
    };
  };
}
