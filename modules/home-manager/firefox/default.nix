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
      {
        title = "NixOS";
        url = "https://nixos.org";
      }
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

    # HTTPS only
    "dom.security.https_only_mode" = true;

    # Trusted DNS (TRR)
    "network.trr.mode" = 2;
    "network.trr.uri" = "https://mozilla.cloudflare-dns.com/dns-query";

    # ECH - prevent TLS connections leaking request hostname
    "network.dns.echconfig.enabled" = true;
    "network.dns.http3_echconfig.enabled" = true;

    # Tracking
    "browser.contentblocking.category" = "strict";
    "privacy.trackingprotection.enabled" = true;
    "privacy.trackingprotection.pbmode.enabled" = true;
    "privacy.trackingprotection.emailtracking.enabled" = true;
    "privacy.trackingprotection.socialtracking.enabled" = true;
    "privacy.trackingprotection.cryptomining.enabled" = true;
    "privacy.trackingprotection.fingerprinting.enabled" = true;

    # Fingerprinting
    "privacy.fingerprintingProtection" = true;
    "privacy.resistFingerprinting" = true;
    "privacy.resistFingerprinting.pbmode" = true;

    "privacy.firstparty.isolate" = true;

    # URL query tracking
    "privacy.query_stripping.enabled" = true;
    "privacy.query_stripping.enabled.pbmode" = true;

    # Prevent WebRTC leaking IP address
    "media.peerconnection.ice.default_address_only" = true;

    # Use Mozilla geolocation service instead of Google
    "geo.provider.network.url" = "https://location.services.mozilla.com/v1/geolocate?key=%MOZILLA_API_KEY%";

    # Disable password manager
    "signon.rememberSignons" = false;
    "signon.autofillForms" = false;
    "signon.formlessCapture.enabled" = false;

    # Hardens against potential credentials phishing:
    # 0 = don’t allow sub-resources to open HTTP authentication credentials dialogs
    # 1 = don’t allow cross-origin sub-resources to open HTTP authentication credentials dialogs
    # 2 = allow sub-resources to open HTTP authentication credentials dialogs (default)
    "network.auth.subresource-http-auth-allow" = 1;

    "browser.bookmarks.showMobileBookmarks" = true;

    "browser.sessionstore.max_windows_undo" = 3;
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
        DefaultDownloadDirectory = "\${home}/downloads";
      };

      profiles = {
        "adrianus.vian.habirowo@devoteam.com" = {
          id = 0;

          bookmarks = profile-bookmarks;

          settings = profile-settings;

          search = {
            default = "DuckDuckGo";
            privateDefault = "DuckDuckGo";
            force = true;
          };

          # extensions =
          #   [
          #   ];

          # userChrome = '''';
          # userContent = '''';
        };

        "vian@idjo.cc" = {
          id = 1;

          bookmarks = profile-bookmarks;

          settings = profile-settings;

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
