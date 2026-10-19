{ pkgs, ... }: {
  engines = {
    "NixOS Wiki" = {
      urls = [
        {
          template = "https://nixos.wiki/index.php?search={searchTerms}";
        }
      ];
      icon = "https://nixos.wiki/favicon.png";
      updateInterval = 24 * 60 * 60 * 1000;
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

    "Nixhub" = {
      urls = [
        {
          template = "https://www.nixhub.io/search?";
          params = [
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
      definedAliases = [ "@nh" ];
    };

    "NixOS Discourse" = {
      urls = [
        {
          template = "https://discourse.nixos.org/search?q={searchTerms}";
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      definedAliases = [ "@nd" ];
    };

    "Home Manager" = {
      urls = [
        {
          # template = "https://mipmip.github.io/home-manager-option-search/";
          template = "https://home-manager-options.extranix.com/";
          params = [
            {
              name = "query";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.nixos-icons}/share/icons/hicolor/scalable/apps/nix-snowflake.svg";
      updateInterval = 24 * 60 * 60 * 1000; # every day
      definedAliases = [ "@hm" ];
    };

    "Home-Manager Docs" = {
      urls = [ { template = "https://rycee.gitlab.io/home-manager/options.html"; } ];
      definedAliases = [ "@hm-docs" ];
    };

    "Sourcegraph" = {
      urls = [
        {
          template = "https://sourcegraph.com/search/?q=context:global+lang:Nix+-repo:^github\.com/NixOS/nixpkgs%24+-repo:^github\.com/nix-community/home-manager%24+content:{searchTerms}";
        }
      ];
      definedAliases = [ "@sc" ];
    };

    "Brave" = {
      urls = [
        {
          template = "https://search.brave.com/search";
          params = [
            {
              name = "type";
              value = "search";
            }
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "${pkgs.brave}/share/icons/hicolor/64x64/apps/brave-browser.png";
      definedAliases = [
        "@brave"
        "@br"
      ];
    };

    "youtube" = {
      urls = [
        {
          template = "https://www.youtube.com/search";
          params = [
            {
              name = "type";
              value = "search";
            }
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      definedAliases = [ "@yt" ];
    };

    "ddg".metaData = {
      alias = "@ddg";
    };

    "bing".metaData = {
      hidden = false;
      alias = "@b";
    };

    "GitHub" = {
      urls = [
        {
          template = "https://github.com/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "https://github.com/fluidicon.png";
      updateInterval = 7 * 24 * 60 * 60 * 1000;
      definedAliases = [ "@gh" ];
    };

    "Google" = {
      urls = [
        {
          template = "https://www.google.com/search";
          params = [
            {
              name = "q";
              value = "{searchTerms}";
            }
          ];
        }
      ];
      icon = "https://www.google.com/favicon.ico";
      updateInterval = 24 * 60 * 60 * 1000;
      definedAliases = [
        "@go"
        "@g"
      ];
    };

    # Metadados adicionais para compatibilidade caso o motor já venha embutido (ex: Firefox padrão)
    "google".metaData.alias = "@go";

    "wikipedia".metaData.alias = "@wiki";
  };

  order = [
    "Google"
    "google"
    "bing"
    "Brave"
    "ddg"
  ];

  default = "Google";
  force = true;
}
