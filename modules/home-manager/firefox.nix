{ pkgs, lib, config, ... }: {
  home.sessionVariables.BROWSER = "${config.programs.firefox.package}/bin/firefox";

  programs.firefox = {
    enable = true;

    profiles.default = {
      id = 0;

      extensions = [
        pkgs.firefox-addons.bitwarden
        pkgs.firefox-addons.bypass-paywalls-clean
        pkgs.firefox-addons.export-tabs-urls-and-titles
        pkgs.firefox-addons.grammarly
        pkgs.firefox-addons.metamask
        pkgs.firefox-addons.multi-account-containers
        pkgs.firefox-addons.octolinker
        pkgs.firefox-addons.open-in-browser
        pkgs.firefox-addons.privacy-badger
        pkgs.firefox-addons.rabattcorner
        pkgs.firefox-addons.reddit-comment-collapser
        pkgs.firefox-addons.reddit-enhancement-suite
        pkgs.firefox-addons.tab-session-manager
        pkgs.firefox-addons.ublock-origin
        pkgs.firefox-addons.view-image
        pkgs.firefox-addons.wappalyzer
      ];

      search = {
        force = true;

        default = "Google";
        order = [ "Google" "Wikipedia" ];
        engines = {
          "Amazon.de".metaData.hidden = true;
          Bing.metaData.hidden = true;
          DuckDuckGo.metaData.hidden = true;
          eBay.metaData.hidden = true;
          Google.metaData.alias = "g";
          "Wikipedia (en)".metaData.alias = "w";
        };
      };

      bookmarks = [{
        toolbar = true;
        bookmarks = [
          {
            name = "Google";
            url = "https://www.google.com";
          }
          {
            name = "WhatsApp";
            url = "https://web.whatsapp.com";
          }
          {
            name = "Gmail";
            url = "https://mail.google.com/mail/u/0";
          }
          {
            name = "YouTube";
            url = "https://www.youtube.com";
          }
          {
            name = "Gogoanime";
            url = "https://gogoanime.cl";
          }
          {
            name = "TV Time";
            url = "https://www.tvtime.com/en/to-watch";
          }
          {
            name = "Todoist";
            url = "https://todoist.com/app?lang=en#start";
          }
          {
            name = "reddit";
            url = "https://www.reddit.com";
          }
          {
            name = "Rechtschreibprüfung";
            url =
              "https://mentor.duden.de/?utm_source=duden_de&utm_medium=premium_int&utm_campaign=topnavi&utm_content=duden-mentor-textpruefung";
          }
          {
            name = "The Pirate Bay";
            url = "https://thepiratebay10.org";
          }
        ];
      }];

      settings = {
        "app.shield.optoutstudies.enabled" = false;
        "browser.aboutConfig.showWarning" = false;
        "browser.bookmarks.restore_default_bookmarks" = false;
        "browser.bookmarks.showMobileBookmarks" = false;
        "browser.contentblocking.category" = "standard";
        "browser.discovery.enabled" = false;
        "browser.download.autohideButton" = false;
        "browser.download.dir" = "${config.home.homeDirectory}/Downloads/Browser";
        "browser.download.folderList" = 2;
        "browser.newtabpage.activity-stream.feeds.section.highlights" = false;
        "browser.newtabpage.activity-stream.feeds.snippets" = false;
        "browser.newtabpage.activity-stream.feeds.topsites" = false;
        "browser.newtabpage.activity-stream.showSearch" = false;
        "browser.newtabpage.enabled" = false;
        "browser.laterrun.enabled" = false;
        "browser.rights.3.shown" = true;
        "browser.search.region" = "CH";
        "browser.search.suggest.enabled.private" = true;
        "browser.startup.homepage" = lib.concatStringsSep "|" [
          "https://todoist.com/app/today"
          "https://web.whatsapp.com"
          "https://mail.google.com/mail/u/0/#inbox"
          "https://www.tvtime.com/en/to-watch"
          "https://status.nixos.org"
          "https://github.com/notifications"
        ];
        "browser.startup.page" = 1;
        "browser.tabs.warnOnClose" = false;
        "browser.toolbars.bookmarks.showOtherBookmarks" = false;
        "browser.toolbars.bookmarks.visibility" = "always";
        "browser.uiCustomization.state" = let
          bitwarden = "_446900e4-71c2-419f-a6a7-df9c091e268b_-browser-action";
          bypass-paywalls-clean = "_d133e097-46d9-4ecc-9903-fa6a722a6e0e_-browser-action";
          export-tabs-urls-and-titles = "_17165bd9-9b71-4323-99a5-3d4ce49f3d75_-browser-action";
          grammarly = "87677a2c52b84ad3a151a4a72f5bd3c4_jetpack-browser-action";
          metamask = "webextension_metamask_io-browser-action";
          privacy-badger = "jid1-mnnxcxisbpnsxq_jetpack-browser-action";
          tab-session-manager = "tab-session-manager_sienori-browser-action";
          ublock-origin = "ublock0_raymondhill_net-browser-action";
          view-image = "_287dcf75-bec6-4eec-b4f6-71948a2eea29_-browser-action";
          wappalyzer = "wappalyzer_crunchlabz_com-browser-action";
        in {
          "placements" = {
            "widget-overflow-fixed-list" = [ ];
            "nav-bar" = [
              "back-button"
              "forward-button"
              "stop-reload-button"
              "home-button"
              "urlbar-container"
              "downloads-button"
              bitwarden
              privacy-badger
              metamask
              export-tabs-urls-and-titles
              tab-session-manager
              ublock-origin
              bypass-paywalls-clean
              wappalyzer
            ];
            "toolbar-menubar" = [ "menubar-items" ];
            "TabsToolbar" = [ "tabbrowser-tabs" "new-tab-button" "alltabs-button" ];
            "PersonalToolbar" = [ "personal-bookmarks" ];
          };
          "seen" = [
            bitwarden
            bypass-paywalls-clean
            export-tabs-urls-and-titles
            grammarly
            metamask
            privacy-badger
            tab-session-manager
            ublock-origin
            view-image
            wappalyzer

            "developer-button"
          ];
          "dirtyAreaCache" = [ "nav-bar" "toolbar-menubar" "TabsToolbar" "PersonalToolbar" ];

          "currentVersion" = 18;
          "newElementCount" = 0;
        };
        "browser.urlbar.openViewOnFocus" = false;
        "browser.urlbar.placeholderName" = "Google";
        "browser.urlbar.placeholderName.private" = "Google";
        "browser.urlbar.showSearchSuggestionsFirst" = false;
        "browser.urlbar.suggest.openpage" = false;
        "devtools.aboutdebugging.collapsibilities.processes" = false;
        "devtools.accessibility.enabled" = false;
        "devtools.application.enabled" = false;
        "devtools.chrome.enabled" = true;
        "devtools.debugger.remote-enabled" = true;
        "devtools.memory.enabled" = false;
        "devtools.performance.enabled" = false;
        "devtools.performance.popup.intro-displayed" = true;
        "devtools.screenshot.audio.enabled" = false;
        "devtools.screenshot.clipboard.enabled" = true;
        "devtools.styleeditor.enabled" = false;
        "extensions.activeThemeID" = "default-theme@mozilla.org";
        "extensions.autoDisableScopes" = 0;
        "extensions.pocket.enabled" = false;
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
        "privacy.query_stripping.enabled" = true;
        "privacy.trackingprotection.enabled" = true;
        "privacy.userContext.enabled" = true;
        "privacy.userContext.extension" = "@contain-facebook";
        "privacy.userContext.ui.enabled" = true;
        "privacy.webrtc.hideGlobalIndicator" = true;
        "privacy.webrtc.legacyGlobalIndicator" = false;
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
}
