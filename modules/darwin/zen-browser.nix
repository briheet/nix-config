{ inputs, ... }:
{

  imports = [ inputs.zen-browser.homeModules.twilight ];
  programs.zen-browser = {
    enable = true;

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

        # WebAuthn - enable macOS Touch ID for security keys
        "security.webauthn.enable_macos_passkeys" = true;

        # Zen-specific
        "zen.theme.accent-color" = "#d8a657"; # gruvbox yellow
        "zen.view.compact" = true;
      };

      search = {
        default = "ddg";
        force = true;
      };

      # Gruvbox Material Medium Dark themed spaces
      spaces = {
        personal = {
          id = "a1b2c3d4-1111-4aaa-bbbb-000000000001";
          position = 0;
          theme = {
            type = "gradient";
            opacity = 0.5;
            colors = [
              # gruvbox green: #a9b665
              {
                red = 169;
                green = 182;
                blue = 101;
                primary = true;
                algorithm = "floating";
              }
            ];
          };
        };
        work = {
          id = "a1b2c3d4-1111-4aaa-bbbb-000000000002";
          position = 1;
          theme = {
            type = "gradient";
            opacity = 0.5;
            colors = [
              # gruvbox blue: #7daea3
              {
                red = 125;
                green = 174;
                blue = 163;
                primary = true;
                algorithm = "floating";
              }
            ];
          };
        };
        dev = {
          id = "a1b2c3d4-1111-4aaa-bbbb-000000000003";
          position = 2;
          theme = {
            type = "gradient";
            opacity = 0.5;
            colors = [
              # gruvbox purple: #d3869b
              {
                red = 211;
                green = 134;
                blue = 155;
                primary = true;
                algorithm = "floating";
              }
            ];
          };
        };
        media = {
          id = "a1b2c3d4-1111-4aaa-bbbb-000000000004";
          position = 3;
          theme = {
            type = "gradient";
            opacity = 0.5;
            colors = [
              # gruvbox orange: #e78a4e
              {
                red = 231;
                green = 138;
                blue = 78;
                primary = true;
                algorithm = "floating";
              }
            ];
          };
        };
      };
    };
  };

}
