{ user-settings, pkgs, config, lib, ... }:
let
  inherit (lib) mkOption mkIf types optional mkMerge;
  cfg = config.custom.apps.chrome-based-browser;
in
{

  options = {
    custom.apps.chrome-based-browser = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable a chrome based browser.";
      };
      browser = mkOption {
        type = types.enum [ "chromium" "ungoogled-chromium" "google-chrome" "brave" "vivaldi" "opera" ];
        default = "ungoogled-chromium";
        description = "The browser to use.";
      };
      disableWayland = mkOption {
        type = types.bool;
        default = mkIf (!config.custom.features.isWayland.enable);
        description = "Disable Wayland support.";
      };
    };

  };

  config = mkIf cfg.enable {

    # Conditionally include vivaldi-ffmpeg-codecs
    home.packages =
      optional (cfg.browser == "vivaldi") pkgs.vivaldi-ffmpeg-codecs;

    programs.chromium = {
      enable = true;
      package =
        if cfg.browser == "chromium" then
          pkgs.chromium
        else if cfg.browser == "ungoogled-chromium" then
          pkgs.ungoogled-chromium
        else if cfg.browser == "google-chrome" then
          pkgs.google-chrome
        else if cfg.browser == "opera" then
          pkgs.opera
        else if cfg.browser == "vivaldi" then
          pkgs.vivaldi
        else
          pkgs.brave;
      commandLineArgs =
        let
          isNotOpera = if (cfg.browser == "opera") then false else true;
        in
        mkIf isNotOpera [ "--ozone-platform-hint=auto" ];
      extensions = [
        # bookmark search
        {
          id = "cofpegcepiccpobikjoddpmmocficdjj";
        }
        # kagi search
        {
          id = "cdglnehniifkbagbbombnjghhcihifij";
        }
        # 1password
        {
          id = "aeblfdkhhhdcdjpifhhbdiojplfjncoa";
        }
        # dark reader
        {
          id = "eimadpbcbfnmbkopoojfekhnkhdbieeh";
        }
        # ublock origin
        {
          id = "cjpalhdlnbpafiamejdnhcphjbkeiagm";
        }
        # tactiq
        {
          id = "fggkaccpbmombhnjkjokndojfgagejfb";
        }
        # okta
        {
          id = "glnpjglilkicbckjpbgcfkogebgllemb";
        }
        # grammarly
        {
          id = "kbfnbcaeplbcioakkpcpgfkobkghlhen";
        }
        # simplify
        {
          id = "pbmlfaiicoikhdbjagjbglnbfcbcojpj";
        }
        # todoist
        {
          id = "jldhpllghnbhlbpcmnajkpdmadaolakh";
        }
        # Loom video recording
        {
          id = "liecbddmkiiihnedobmlmillhodjkdmb";
        }
        # Privacy Badger
        {
          id = "pkehgijcmpdhfbdbbnkijodmdjhbjlgp";
        }
        # Checker Plus for Mail
        {
          id = "oeopbcgkkoapgobdbedcemjljbihmemj";
        }
        # Checker Plus for Cal
        {
          id = "hkhggnncdpfibdhinjiegagmopldibha";
        }
        # Google docs offline
        {
          id = "ghbmnnjooekpmoecnnnilnnbdlolhkhi";
        }
        # Markdown downloader
        {
          id = "pcmpcfapbekmbjjkdalcgopdkipoggdi";
        }
        # obsidian clipper
        {
          id = "mphkdfmipddgfobjhphabphmpdckgfhb";
        }
        # URL/Tab Manager
        {
          id = "egiemoacchfofdhhlfhkdcacgaopncmi";
        }
        # Mail message URL
        {
          id = "bcelhaineggdgbddincjkdmokbbdhgch";
        }
        # Glean browser extension
        {
          id = "cfpdompphcacgpjfbonkdokgjhgabpij";
        }
        # gnome extention plugin
        {
          id = "gphhapmejobijbbhgpjhcjognlahblep";
        }
        # copy to clipboard
        {
          id = "miancenhdlkbmjmhlginhaaepbdnlllc";
        }
        # Speed dial extention
        {
          id = "jpfpebmajhhopeonhlcgidhclcccjcik";
        }
        # Omnivore
        {
          id = "blkggjdmcfjdbmmmlfcpplkchpeaiiab";
        }
        # Tokyonight
        {
          id = "enpfonmmpgoinjpglildebkaphbhndek";
        }
        # email tracking for work
        {
          id = "pgbdljpkijehgoacbjpolaomhkoffhnl";
        }
        # zoom
        # {
        #   id = "kgjfgplpablkjnlkjmjdecgdpfankdle";
        # }
        # xbrowsersync
        # {
        #   id = "lcbjdhceifofjlpecfpeimnnphbcjgnc";
        # }
        # Catppuccin Mocha theme
        # {
        #   id = "bkkmolkhemgaeaeggcmfbghljjjoofoh";
        # }
        # Catppuccin Frappe theme
        # {
        #   id = "olhelnoplefjdmncknfphenjclimckaf";
        # }
        # Catppuccin Macchiato theme
        # {
        #   id = "cmpdlhmnmjhihmcfnigoememnffkimlk";
        # }
        # Catppuccin Latte theme
        # {
        #   id = "jhjnalhegpceacdhbplhnakmkdliaddd";
        # }
        # tineye
        # {
        #     id = "haebnnbpedcbhciplfhjjkbafijpncjl";
        # }

      ];
    };
    # force brave to use wayland - https://skerit.com/en/make-electron-applications-use-the-wayland-renderer
    home.file =
      let
        browserConfig =
          if !cfg.disableWayland then
            if cfg.browser == "chromium" || cfg.browser == "google-chrome" || cfg.browser == "ungoogled-chromium" then {
              ".config/chromium-flags.conf".text = ''
                --force-dark-mode
                --enable-features=WebUIDarkMode
                --no-default-browser-check
                --enable-features=UseOzonePlatform
                --ozone-platform=wayland
                --enable-features=WaylandWindowDecorations
                --ozone-platform-hint=auto
              '';
              # --force-device-scale-factor=1
            } else if cfg.browser == "brave" then {
              ".config/brave-flags.conf".text = ''
                --force-dark-mode
                --enable-features=WebUIDarkMode
                --no-default-browser-check
                --enable-features=UseOzonePlatform
                --ozone-platform=wayland
                --enable-features=WaylandWindowDecorations
                --ozone-platform-hint=auto
              '';
              # --force-device-scale-factor=1
            } else if cfg.browser == "opera" then {
              ".config/opera-flags.conf".text = ''
                --force-dark-mode
                --enable-features=WebUIDarkMode
                --no-default-browser-check
                --enable-features=UseOzonePlatform
                --ozone-platform=wayland
                --enable-features=WaylandWindowDecorations
                --ozone-platform-hint=auto
              '';
              # --force-device-scale-factor=1
            } else if cfg.browser == "vivaldi" then {
              ".config/vivaldi-stable.conf".text = ''
                --force-dark-mode
                --enable-features=WebUIDarkMode
                --no-default-browser-check
                --enable-features=UseOzonePlatform
                --ozone-platform=wayland
                --enable-features=WaylandWindowDecorations
                --ozone-platform-hint=auto
              '';
              # --force-device-scale-factor=1
            } else
              { }
          else
            { };
      in
      mkMerge [
        browserConfig
        {
          # Add other home.file configurations here

        }
      ];
  };
}
