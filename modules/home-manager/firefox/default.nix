{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib;
let
  cfg = config.modules.firefox;
  firefox-addons = inputs.firefox-addons.packages.${pkgs.system};

  profile-settings = {
    # Disable about:config warning
    "browser.aboutConfig.showWarning" = false;

    # Mozilla telemetry
    "toolkit.telemetry.enabled" = false;

    # Homepage settings
    # 0 = blank, 1 = home, 2 = last visited page, 3 = resume previous session
    "browser.startup.page" = 1;
    "browser.startup.homepage" = "about:home";
    "browser.newtabpage.enabled" = true;
    "browser.newtabpage.activity-stream.topSitesRows" = 2;
    "browser.newtabpage.storageVersion" = 1;
    "browser.newtabpage.pinned" = [
      # {
      #   title = "NixOS";
      #   url = "https://nixos.org";
      # }
    ];

    # Activity Stream
    "browser.newtab.preload" = false;
    "browser.newtabpage.activity-stream.telemetry" = false;
    "browser.newtabpage.activity-stream.showSponsored" = false;
    "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
    "browser.newtabpage.activity-stream.feeds.topsites" = true;
    "browser.newtabpage.activity-stream.feeds.telemetry" = false;
    "browser.newtabpage.activity-stream.feeds.snippets" = false;
    "browser.newtabpage.activity-stream.feeds.section.topstories" = false;
    "browser.newtabpage.activity-stream.feeds.discoverystreamfeed" = false;
    "browser.newtabpage.activity-stream.section.highlights.includePocket" = false;
    "browser.newtabpage.activity-stream.default.sites" = "";

    # Addon recomendations
    "browser.discovery.enabled" = false;
    "extensions.getAddons.showPane" = false;
    "extensions.htmlaboutaddons.recommendations.enabled" = false;

    # Crash reports
    "breakpad.reportURL" = "";
    "browser.tabs.crashReporting.sendReport" = false;

    # Auto-decline cookies
    "cookiebanners.service.mode" = 2;
    "cookiebanners.service.mode.privateBrowsing" = 2;

    # Disable autoplay
    "media.autoplay.default" = 5;

    # Prefer dark theme
    "layout.css.prefers-color-scheme.content-override" = 0; # 0: Dark, 1: Light, 2: Auto

    # ECH - prevent TLS connections leaking request hostname
    "network.dns.echconfig.enabled" = true;
    "network.dns.http3_echconfig.enabled" = true;

    # Tracking
    # Removed: "browser.contentblocking.category" = "strict";  // Covered by policies.EnableTrackingProtection
    # Removed: "privacy.trackingprotection.enabled" = true; // Covered by policies.EnableTrackingProtection
    "privacy.trackingprotection.pbmode.enabled" = true;
    "privacy.trackingprotection.emailtracking.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
    # Removed:  "privacy.trackingprotection.cryptomining.enabled" = true; // Covered by policies.EnableTrackingProtection
    # Removed: "privacy.trackingprotection.fingerprinting.enabled" = true; // Covered by policies.EnableTrackingProtection

    # Fingerprinting
    "privacy.fingerprintingProtection" = true;
    "privacy.resistFingerprinting" = false;
    "privacy.resistFingerprinting.pbmode" = false;

    "privacy.firstparty.isolate" = true;

    # URL query tracking
    "privacy.query_stripping.enabled" = true;
    "privacy.query_stripping.enabled.pbmode" = true;

    # Prevent WebRTC leaking IP address
    "media.peerconnection.ice.default_address_only" = true;

    # Use Mozilla geolocation service instead of Google
    "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";

    # Disable password manager
    # Removed: "signon.rememberSignons" = false; // Covered by policies.PasswordManagerEnabled
    # Removed: "signon.autofillForms" = false; // Covered by policies.PasswordManagerEnabled
    "signon.formlessCapture.enabled" = false;

    # Hardens against potential credentials phishing:
    # 0 = don’t allow sub-resources to open HTTP authentication credentials dialogs
    # 1 = don’t allow cross-origin sub-resources to open HTTP authentication credentials dialogs
    # 2 = allow sub-resources to open HTTP authentication credentials dialogs (default)
    "network.auth.subresource-http-auth-allow" = 1;

    "browser.bookmarks.showMobileBookmarks" = true;

    "browser.sessionstore.max_windows_undo" = 3;

    "extensions.autoDisableScopes" = 0;
  };

  profile-bookmarks = [
    {
      name = "Google Cloud Console";
      url = "https://console.cloud.google.com";
      tags = [
        "gcp"
        "google"
      ];
    }
    {
      name = "Google Mail";
      url = "https://mail.google.com";
      tags = [
        "google"
      ];
    }
    {
      name = "Google Chat";
      url = "https://chat.google.com";
      tags = [
        "google"
      ];
    }
    {
      name = "Google Calendar";
      url = "https://calendar.google.com";
      tags = [
        "google"
      ];
    }
    {
      name = "Playground Vertex AI";
      url = "https://console.cloud.google.com/vertex-ai/studio/chat?project=lv-playground-genai";
      tags = [
        "gcp"
        "google"
      ];
    }
    {
      name = "WhatsApp";
      url = "https://web.whatsapp.com";
      tags = [
        "messaging"
        "social"
      ];
    }
    {
      name = "Github";
      url = "https://github.com";
      tags = [
        "social"
      ];
    }
    {
      name = "NixOS Packages";
      url = "https://search.nixos.org/packages?channel=unstable";
      tags = [
        "nixos"
      ];
    }
    {
      name = "NixOS Options";
      url = "https://search.nixos.org/options?channel=unstable";
      tags = [
        "nixos"
      ];
    }
    {
      name = "NixVim";
      url = "https://nix-community.github.io/nixvim/index.html";
      tags = [
        "nixos"
      ];
    }
  ];

  profile-extensions = with firefox-addons; [
    ublock-origin
    privacy-badger
    # enhancer-for-youtube
  ];
in
{
  options.modules.firefox = {
    enable = mkEnableOption "firefox";
  };
  config = mkIf cfg.enable {
    programs.firefox = {
      enable = cfg.enable;

      languagePacks = [
        "en-US"
        "id"
      ];

      nativeMessagingHosts = [
        pkgs.tridactyl-native
      ];

      policies = {
        #  ----------------------
        #  General Settings
        #  ----------------------
        AllowFileSelectionDialogs = true; # Allows file selection dialogs to open.
        DontCheckDefaultBrowser = false; # Prevents Firefox from checking if it's the default browser.
        HardwareAcceleration = true; # Enables hardware acceleration for improved performance.
        RequestedLocales = [
          "en-US"
          "id"
        ]; # Sets the preferred UI languages for the browser.
        UseSystemPrintDialog = true; # Forces the usage of the OS print dialog instead of firefox's print dialog

        # ----------------------
        #  Update Settings
        #  ----------------------
        AppAutoUpdate = false; # Disables automatic application updates.
        BackgroundAppUpdate = false; # Disables background application updates.
        DisableAppUpdate = true; # Further disables automatic updates of the application
        ManualAppUpdateOnly = true; # Forces updates to be done manually.
        ExtensionUpdate = false; # Disables automatic extension updates.
        DisableSystemAddonUpdate = true; # Disables automatic system addons updates.

        # ----------------------
        #  Privacy and Security
        # ----------------------
        AutofillCreditCardEnabled = false; # Disables autofilling of credit card information.
        DisableFeedbackCommands = true; # Disables sending feedback to mozilla.
        DisableFirefoxAccounts = true; # Disables usage of firefox accounts
        DisableFirefoxStudies = true; # Disables the firefox studies.
        DisablePocket = true; # Disable pocket integration
        DisableTelemetry = true; # Disables sending usage data to Mozilla.
        DNSOverHTTPS = {
          # Configures DNS over HTTPS settings.
          Enabled = true;
          ProviderURL = "https://all.dns.mullvad.net/dns-query";
          Locked = true;
        };
        EnableTrackingProtection = {
          # Enables enhanced tracking protection.
          Value = true;
          Locked = true;
          Cryptomining = true;
          Fingerprinting = false;
        };
        HttpsOnlyMode = "enabled"; # Forces HTTPS for all connections
        PasswordManagerEnabled = false; # Disables the built-in password manager.
        OfferToSaveLogins = false; # Disables saving login
        OfferToSaveLoginsDefault = false; # Disables saving logins by default
        PasswordManagerExceptions = [ ]; # Disables password manager exceptions
        PictureInPicture = {
          # Disables Picture-in-Picture mode
          Enabled = false;
          Locked = true;
        };
        PopupBlocking = {
          # Enables popup blocking by default
          Default = true;
          Locked = false;
        };

        #  ----------------------
        #  Homepage Settings
        #  ----------------------
        FirefoxHome = {
          # Configures Firefox's homepage content.
          Search = true;
          TopSites = true;
          SponsoredTopSites = false;
          Highlights = false;
          Pocket = false;
          SponsoredPocket = false;
          Snippets = true;
          Locked = true;
        };
        NewTabPage = true; # Enables new tab page
        ShowHomeButton = true; # Enables the home button

        # ----------------------
        # Search Settings
        # ----------------------
        FirefoxSuggest = {
          # Configures search suggestions.
          WebSuggestions = true;
          SponsoredSuggestions = false;
          ImproveSuggest = false;
          Locked = true;
        };
        SearchBar = "unified"; # Enables unified search bar, combines address and search bar

        # ----------------------
        # User Interface Settings
        # ----------------------
        DisplayBookmarksToolbar = "newtab"; # Sets the bookmarks toolbar visibility to be on new tabs.
        DisplayMenuBar = "default-off"; # Sets the menu bar to be hidden by default.
        DisableSetDesktopBackground = true; # Disables the ability to set the background via firefox

        # ----------------------
        #  Download Settings
        #  ----------------------
        DefaultDownloadDirectory = "\$/downloads"; # Sets the default directory for downloads.
        DownloadDirectory = "\$/downloads"; # Sets the download directory.
        PromptForDownloadLocation = false; # Prevents firefox from asking the location to download a file
        StartDownloadsInTempDirectory = true; # Starts downloads in a temporary directory

        # ----------------------
        #  Autofill Settings
        #  ----------------------
        AutofillAddressEnabled = true; # Enables autofilling of address information.

        # ----------------------
        #  Handler Settings
        #  ----------------------
        Handlers = {
          # Configures how specific protocols are handled by the browser.
          schemes = {
            mailto = {
              action = "useHelperApp";
              ask = true;
              handlers = [
                {
                  name = "Gmail";
                  uriTemplate = "https://mail.google.com/mail/?extsrc=mailto&url=%s";
                }
              ];
            };
          };
        };

        #  ----------------------
        #  PDF Settings
        #  ----------------------
        PDFjs = {
          # Enables and configures PDF viewer within Firefox.
          Enabled = true;
          EnablePermissions = true;
        };

        # ----------------------
        #  Add-ons Settings
        #  ----------------------
        InstallAddonsPermission = {
          # Configures permission to install add-ons
          Default = false;
        };

        # ----------------------
        #  User Messaging Settings
        #  ----------------------
        UserMessaging = {
          # Configures messaging and recommendation prompts to the user.
          ExtensionRecommendations = false;
          FeatureRecommendations = false;
          UrlbarInterventions = false;
          SkipOnboarding = true;
          MoreFromMozilla = false;
          FirefoxLabs = false;
          Locked = true;
        };
        #  ----------------------
        #  Other Settings
        #  ----------------------
        NetworkPrediction = true; # Enables network prediction to improve page load speed.
        NoDefaultBookmarks = true; # Removes all default bookmarks on startup.
        TranslateEnabled = true; # Enables the translator service.
      };

      profiles = {
        "adrianus.vian.habirowo@devoteam.com" = {
          id = 0;

          bookmarks = profile-bookmarks;

          settings = profile-settings;

          extensions = with firefox-addons; [
            ublock-origin
            privacy-badger
          ];

          search = {
            default = "DuckDuckGo";
            privateDefault = "DuckDuckGo";
            force = true;
          };
        };

        "vian@idjo.cc" = {
          id = 1;

          bookmarks = profile-bookmarks;

          settings = profile-settings;

          extensions = profile-extensions;

          search = {
            default = "DuckDuckGo";
            privateDefault = "DuckDuckGo";
            force = true;
          };
        };

        "v_adrianus.devo@smartfren.com" = {
          id = 2;

          bookmarks = profile-bookmarks;

          settings = profile-settings;

          extensions = profile-extensions;

          search = {
            default = "DuckDuckGo";
            privateDefault = "DuckDuckGo";
            force = true;
          };
        };
      };
    };
  };
}
