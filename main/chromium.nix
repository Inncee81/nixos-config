{ config, lib, ... }: {

  # Configure Chromium/Chrome.
  # Command line arguments are set in ../overlays/ungoogled-chromium.
  programs.chromium = {
    enable = true;

    # Enterprise policy list: https://chromeenterprise.google/policies/
    # chrome://policy shows applied policies and syntax errors.
    extraOpts = {

      # Settings
      BlockThirdPartyCookies = true;
      DefaultCookiesSetting = 1;
      DefaultNotificationsSetting = 2;
      DefaultSearchProviderEnabled = true;
      DefaultSearchProviderName = "DuckDuckGo";
      DefaultSearchProviderKeyword = "duck.com";
      DefaultSearchProviderIconURL = "https://duckduckgo.com/favicon.ico";
      DefaultSearchProviderSearchURL =
        "https://duckduckgo.com/?q={searchTerms}";
      DefaultSearchProviderSuggestURL =
        "https://duckduckgo.com/ac/?q={searchTerms}&type=list";
      HideWebStoreIcon = true;

      # uBlock Origin
      "3rdparty".extensions.cjpalhdlnbpafiamejdnhcphjbkeiagm.adminSettings = let
        externalLists = [
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/porn/clefspeare13/hosts"
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/porn/sinfonietta/hosts"
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/porn/sinfonietta-snuff/hosts"
          "https://raw.githubusercontent.com/StevenBlack/hosts/master/extensions/porn/tiuxo/hosts"
        ];
      in __toJSON {
        selectedFilterLists = [
          "user-filters"
          "ublock-filters"
          "ublock-badware"
          "ublock-privacy"
          "ublock-abuse"
          "ublock-unbreak"
          "easylist"
          "easyprivacy"
          "urlhaus-1"
          "adguard-annoyance"
          "ublock-annoyances"
          "plowe-0"
        ] ++ externalLists;
        userSettings.externalLists = lib.concatStringsSep "\n" externalLists;
        userFilters = ''
          ! Reddit: Hide 'Get Coins' button
          www.reddit.com##.jEUbSHJJx8vISKpWirlfx
          ! Reddit: Hide account information
          www.reddit.com###email-collection-tooltip-id
        '';
      };

      # Bookmarks
      ManagedBookmarks = let inherit (config.system.nixos) release;
      in [
        {
          name = "Manuals";
          children = [
            {
              name = "Nix Manual";
              url =
                "file:///run/current-system/sw/share/doc/nix/manual/index.html";
            }
            {
              name = "NixOS Manual";
              url = "file:///run/current-system/sw/share/doc/nixos/index.html";
            }
            {
              name = "Nixpkgs Manual";
              url =
                "file:///run/current-system/sw/share/doc/nixpkgs/manual.html";
            }
            {
              name = "Home Manager Manual";
              url =
                "file:///run/current-system/sw/share/doc/home-manager/index.html";
            }
          ];
        }
        {
          name = "Nix & NixOS";
          children = [
            {
              name = "NixOS/nixpkgs: Nix Packages collection";
              url = "https://github.com/NixOS/nixpkgs";
            }
            {
              name = "Nixpkgs PR progress tracker";
              url = "https://nixpk.gs/pr-tracker.html";
            }
            {
              name = "NixOS Infra Status";
              url = "https://status.nixos.org/";
            }
            {
              name = "Hydra - Overview";
              url = "https://hydra.nixos.org/";
            }
            {
              name = "Hydra - Jobset nixos:release-${release}";
              url = "https://hydra.nixos.org/jobset/nixos/release-${release}";
            }
            {
              name = "Hydra - Jobset nixos:trunk-combined";
              url = "https://hydra.nixos.org/jobset/nixos/trunk-combined";
            }
            {
              name = "Useful Nix Hacks";
              url = "http://chriswarbo.net/projects/nixos/useful_hacks.html";
            }
          ];
        }
        {
          name = "Chrome";
          children = [
            {
              name = "Chrome Release Schedule";
              url = "https://www.chromestatus.com/features/schedule";
            }
            {
              name = "Chrome Enterprise release notes";
              url = "https://support.google.com/chrome/a/answer/7679408/";
            }
            {
              name = "Chrome Enterprise policy list";
              url = "https://chromeenterprise.google/policies/";
            }
          ];
        }
        {
          name = "Extensions";
          children = [
            {
              name = "Extensions";
              url = "chrome://extensions";
            }
            {
              name = "Chromium Web Store";
              url = "https://github.com/NeverDecaf/chromium-web-store/releases";
            }
          ] ++ lib.mkWebstoreBookmarks {
            "Dark Reader" = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
            "Go Back with Backspace" = "eekailopagacbcdloonjhbiecobagjci";
            "Just Black" = "aghfnjkcakhmadgdomlmlhhaocbkloab";
            "Not yet, AV1" = "dcmllfkiihingappljlkffafnlhdpbai";
            "SponsorBlock" = "mnjggcdmjocbbbhaepdhchncahnbgone";
            "uBlock Origin" = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
            "Video Speed Controller" = "nffaoalbilbmmfgbnbgppjihopabppdk";
            "Violentmonkey" = "jinjaccalgkegednnccohejagnlnfdag";
          };
        }
        {
          name = "Userscripts";
          children = lib.mkGreasyforkBookmarks {
            "Default YouTube to Dark Theme" = 408542;
            "Display remaining Youtube playlist time" = 408966;
            "Google - auto-set privacy/GDPR consent cookie (prevent consent popup)" =
              424411;
            "Play Youtube playlist in reverse order" = 404986;
            "YouTube CPU Tamer" = 418283;
            "YouTube ScrollBar Remove" = 423150;
            "Youtube - dismiss sign-in" = 412178;
          };
        }
      ];

      # MS Teams
      CookiesAllowedForUrls =
        [ "assignments.onenote.com" "login.microsoftonline.com" ];
    };
  };

}
