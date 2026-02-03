{
  inputs,
  lib,
  options,
  ...
}: {
  programs.firefox = {
    enable = true;

    policies = {
      AppAutoUpdate = false;
      BackgroundAppUpdate = false;
      DisableBuiltinPDFViewer = false;
      DisableFirefoxStudies = true;
      DisableFirefoxAccounts = false;
      DisablePocket = true;
      DisableTelemtry = true;
      DontCheckDefaultBrowser = true;
      OfferToSaveLogins = false;
      EnableTrackingProtection = {
        Value = true;
        Locked = true;
        Cryptomining = true;
        Fingerprinting = true;
        EmailTracking = true;
      };
      ExtensionUpdate = false;
    };

    profiles.default = {
      search = {
        default = "ddg";
        privateDefault = "ddg";
        force = true;
        engines = {
          "bing".metaData.hidden = true;
        };
      };

      settings = {
        "dom.security.https_only_mode" = true;
        "browser.startup.page" = 3;
        "signon.rememberSignons" = false;
        "signon.management.page.breach-alerts.enabled" = false;
        "app.shield.optoutstudies.enabled" = false;
        "datareporting.healthreport.uploadEnabled" = false;
        "browser.newtabpage.activity-stream.showSponsoredTopSites" = false;
      };

      extensions.force = true;

      extensions.packages = with inputs.firefox-addons.packages."x86_64-linux"; [
        bitwarden
        duckduckgo-privacy-essentials
        ublock-origin
        stylus
        firefox-color
      ];
    };
  };

  home = lib.optionalAttrs (options.home ? "persistence") {
    persistence = {
      "/persist" = {
        # directories = [
        #   ".mozilla/firefox"
        # ];
      };
    };
  };
}
