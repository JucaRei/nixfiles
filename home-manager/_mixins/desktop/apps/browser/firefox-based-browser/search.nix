{ pkgs, config, ... }: {
  engines = {

    "NixOS Wiki" = {
      urls = [
        {
          template = "https://nixos.wiki/index.php?search={searchTerms}";
        }
      ];
      definedAliases = [ "@nw" ];
    };

    "NixOS Options" = {
      urls = [
        {
          template = "https://search.nixos.org/options";
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@no" ];
    };

    "Nix Packages" = {
      urls = [
        {
          template = "https://search.nixos.org/packages";
          params = [
            {
              name = "channel";
              value = "unstable";
            }
            {
              name = "type";
              value = "packages";
            }
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      updateInterval = 24 * 60 * 60 * 1000; # every day
      definedAliases = [ "@np" ];
    };

    "NixOS Discourse" = {
      urls = [{
        template = "https://discourse.nixos.org/search?q={searchTerms}";
      }];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@nd" ];
    };
    "Home Manager Options" = {
      urls = [{ template = "https://home-manager-options.extranix.com/?query={searchTerms}&release = master "; }];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      updateInterval = 24 * 60 * 60 * 1000; # every day
      definedAliases = [ "@hm" ];
    };
    "Home-Manager Docs" = {
      urls = [{ template = "https://rycee.gitlab.io/home-manager/options.html"; }];
      definedAliases = [ "@hm-docs" ];
    };

    "Sourcegraph" =
      {
        urls = [{
          template = "https://sourcegraph.com/search/?q=context:global+lang:Nix+-repo:^github\.com/NixOS/nixpkgs%24+-repo:^github\.com/nix-community/home-manager%24+content:{searchTerms}";
        }];
        definedAliases = [ "@sc" ];
      };

    "Brave" = {
      urls = [{
        template = "https://search.brave.com/search";
        params = [
          { name = "type"; value = "search"; }
          { name = "q"; value = "{searchTerms}"; }
        ];
      }];
      icon = "${config.programs.brave.package}/share/icons/hicolor/64x64/apps/brave-browser.png";
      definedAliases = [ "@brave" "@b" ];
    };

    "YouTube" = {
      urls = [{
        template = "https://www.youtube.com/search";
        params = [
          { name = "type"; value = "search"; }
          { name = "q"; value = "{searchTerms}"; }
        ];
      }];
      definedAliases = [ "@yt" ];
    };

    "DuckDuckGo" = {
      name = "DuckDuckGo";
      keyword = "@ddg";
      search = "https://duckduckgo.com/?q={searchTerms}";
    };

    "Bing".metaData = {
      hidden = false;
      alias = "@b";
    };

    "Searx" = {
      urls = [{ template = "https://searx.juancord.xyz/searxng/search?q={searchTerms}"; }];
      definedAliases = [ "@s" ];
    };

    "GitHub" = {
      urls = [{ template = "https://github.com/search?q={searchTerms}&type=code"; }];
      definedAliases = [ "@gh" ];
    };

    "Google".metaData.alias = "@g";

    "Wikipedia".metaData.alias = "@wiki";
  };

  order = [
    "Google"
    "Bing"
    "Brave"
    "DuckDuckGo"
    "Searx"
  ];

  default = "Google";
  force = false;
}
