# Zen (twilight) on Linux, from the zen-browser flake: Zen's own aarch64
# build, repackaged, so nothing compiles. The same profile as on the Macs
# (../darwin/zen-browser.nix) without the macOS-only parts.
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

        # Wayland, rendered on the GPU
        "widget.dmabuf.force-enabled" = true;
        "gfx.webrender.all" = true;

        # Transparency
        "browser.tabs.allow_transparent_browser" = true;
        "zen.view.grey-out-inactive-windows" = false;

        # Zen-specific
        "zen.view.compact" = true;
      };

      presets.catppuccin = {
        enable = true;
        flavor = "Mocha";
        accent = "Mauve";
      };

      search = {
        default = "ddg";
        force = true;
      };
    };
  };
}
