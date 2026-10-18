{ inputs, ... }:
{

  imports = [ inputs.zen-browser.homeModules.twilight ];
  programs.zen-browser = {
    enable = true;
    # The .app itself comes from environment.systemPackages so it lands in /Applications;
    # this module only manages policies, profiles and settings.
    package = null;
    darwinDefaultsId = "app.zen-browser.zen";

    policies = {
      DisableTelemetry = true;
      DisableFirefoxStudies = true;
      DisablePocket = true;
      DisableFirefoxAccounts = false;
      DontCheckDefaultBrowser = true;
      NoDefaultBookmarks = true;
    };

    profiles.default = {
      isDefault = true;

      settings = {
        # Privacy
        "privacy.trackingprotection.enabled" = true;
        "privacy.donottrackheader.enabled" = true;
        "dom.security.https_only_mode" = true;

        # Disable telemetry
        "toolkit.telemetry.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;

        # Smooth scrolling
        "general.smoothScroll" = true;

        # Transparency
        "widget.macos.titlebar-blend-mode" = "behind-window";
        "browser.tabs.allow_transparent_browser" = true;
        "zen.view.grey-out-inactive-windows" = false;

        # WebAuthn - enable macOS Touch ID for security keys
        "security.webauthn.enable_macos_passkeys" = true;

        # Zen-specific
        "zen.view.compact" = true;
      };

      presets.catppuccin = {
        enable = true;
        flavor = "Mocha";
        accent = "Mauve";
      };

      # Keep catppuccin but undo its solid sidebar/titlebar backgrounds so the window stays transparent
      userChrome = ''
        @import "catppuccin/userChrome.css";

        :root {
          --zen-main-browser-background: transparent !important;
          --zen-themed-toolbar-bg: transparent !important;
          --toolbox-bgcolor-inactive: transparent !important;
        }

        hbox#titlebar,
        #TabsToolbar,
        #zen-appcontent-navbar-container {
          background-color: transparent !important;
        }
      '';

      search = {
        default = "ddg";
        force = true;
      };
    };
  };

}
