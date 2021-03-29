{ pkgs, config, ... }: {
  home-manager.users.rhoriguchi.programs.firefox = {
    enable = true;

    extensions = [
      pkgs.firefox-addons.export-tabs-urls-and-titles
      pkgs.firefox-addons.facebook-container
      pkgs.firefox-addons.grammarly
      pkgs.firefox-addons.https-everywhere
      pkgs.firefox-addons.lastpass-password-manager
      pkgs.firefox-addons.metamask
      pkgs.firefox-addons.octolinker
      pkgs.firefox-addons.open-in-browser
      pkgs.firefox-addons.pocket-select-all
      pkgs.firefox-addons.privacy-badger
      pkgs.firefox-addons.rabattcorner
      pkgs.firefox-addons.reddit-comment-collapser
      pkgs.firefox-addons.reddit-enhancement-suite
      pkgs.firefox-addons.tab-session-manager
      pkgs.firefox-addons.ublock-origin
      pkgs.firefox-addons.view-image
      pkgs.firefox-addons.wappalyzer
    ];

    profiles = {
      default = {
        id = 0;

        settings = {
          "app.shield.optoutstudies.enabled" = false;
          "browser.aboutConfig.showWarning" = false;
          "browser.bookmarks.restore_default_bookmarks" = false;
          "browser.bookmarks.showMobileBookmarks" = false;
          "browser.contentblocking.category" = "standard";
          "browser.discovery.enabled" = false;
          "browser.download.autohideButton" = false;
          "browser.download.dir" = "${config.users.users.rhoriguchi.home}/Downloads/Browser";
          "browser.download.folderList" = 2;
          "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
          "browser.newtabpage.activity-stream.feeds.snippets" = false;
          "browser.newtabpage.activity-stream.feeds.topsites" = false;
          "browser.newtabpage.activity-stream.showSearch" = false;
          "browser.newtabpage.enabled" = false;
          "browser.rights.3.shown" = true;
          "browser.search.region" = "CH";
          "browser.startup.homepage" = builtins.concatStringsSep "|" [
            "https://todoist.com/app/today"
            "https://web.whatsapp.com"
            "https://mail.google.com/mail/u/0/#inbox"
            "https://www.tvtime.com/en/to-watch"
            "https://www.daydeal.ch"
            "https://www.digitec.ch/de/LiveShopping/81"
            "https://www.galaxus.ch/de/LiveShopping/82"
          ];
          "browser.startup.page" = 0;
          "browser.tabs.warnOnClose" = false;
          "browser.toolbars.bookmarks.showOtherBookmarks" = false;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.uiCustomization.state" = builtins.toJSON {
            "placements" = {
              "widget-overflow-fixed-list" = [ ];
              "nav-bar" = [
                "back-button"
                "forward-button"
                "stop-reload-button"
                "home-button"
                "urlbar-container"
                "downloads-button"
                "_react-devtools-browser-action"
                "support_lastpass_com-browser-action"
                "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
                "webextension_metamask_io-browser-action"
                "_17165bd9-9b71-4323-99a5-3d4ce49f3d75_-browser-action"
                "tab-session-manager_sienori-browser-action"
                "wappalyzer_crunchlabz_com-browser-action"
                "ublock0_raymondhill_net-browser-action"
                "_027368fc-da0d-4b05-aada-38db897f3b8c_-browser-action"
              ];
              "toolbar-menubar" = [ "menubar-items" ];
              "TabsToolbar" = [ "tabbrowser-tabs" "new-tab-button" "alltabs-button" ];
              "PersonalToolbar" = [ "personal-bookmarks" ];
            };
            "seen" = [
              "developer-button"
              "webextension_metamask_io-browser-action"
              "ublock0_raymondhill_net-browser-action"
              "support_lastpass_com-browser-action"
              "_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action"
              "tab-session-manager_sienori-browser-action"
              "https-everywhere_eff_org-browser-action"
              "wappalyzer_crunchlabz_com-browser-action"
              "_react-devtools-browser-action"
              "jid1-mnnxcxisbpnsxq_jetpack-browser-action"
              "_17165bd9-9b71-4323-99a5-3d4ce49f3d75_-browser-action"
              "87677a2c52b84ad3a151a4a72f5bd3c4_jetpack-browser-action"
              "profiler-button"
              "_contain-facebook-browser-action"
              "_027368fc-da0d-4b05-aada-38db897f3b8c_-browser-action"
            ];
            "dirtyAreaCache" = [ "nav-bar" "toolbar-menubar" "TabsToolbar" "PersonalToolbar" ];

            "currentVersion" = 16;
            "newElementCount" = 1;
          };
          "browser.urlbar.openViewOnFocus" = false;
          "browser.urlbar.placeholderName.private" = "Google";
          "browser.urlbar.placeholderName" = "Google";
          "browser.urlbar.suggest.openpage" = false;
          "devtools.aboutdebugging.collapsibilities.processes" = false;
          "devtools.accessibility.enabled" = false;
          "devtools.application.enabled" = false;
          "devtools.memory.enabled" = false;
          "devtools.performance.enabled" = false;
          "devtools.performance.popup.intro-displayed" = true;
          "devtools.screenshot.audio.enabled" = false;
          "devtools.screenshot.clipboard.enabled" = true;
          "devtools.styleeditor.enabled" = false;
          "extensions.autoDisableScopes" = 0;
          "extensions.ui.extension.hidden" = false;
          "extensions.ui.locale.hidden" = true;
          "extensions.update.enabled" = false;
          "findbar.highlightAll" = true;
          "layout.spellcheckDefault" = 0;
          "media.eme.enabled" = true;
          "network.dns.disablePrefetch" = true;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;
          "network.trr.mode" = 2;
          "pref.downloads.disable_button.edit_actions" = false;
          "privacy.donottrackheader.enabled" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.userContext.enabled" = true;
          "privacy.userContext.extension" = "@contain-facebook";
          "privacy.userContext.ui.enabled" = true;
          "services.sync.engine.addons" = false;
          "services.sync.engine.bookmarks" = true;
          "services.sync.engine.creditcards" = false;
          "services.sync.engine.history" = true;
          "services.sync.engine.passwords" = false;
          "services.sync.engine.prefs" = false;
          "services.sync.engine.tabs" = false;
          "signon.rememberSignons" = false;
          "toolkit.telemetry.reportingpolicy.firstRun" = false;
          "trailhead.firstrun.didSeeAboutWelcome" = true;
        };
      };
    };
  };
}
