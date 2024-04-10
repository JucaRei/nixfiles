{ pkgs, config, lib, ... }@args:
let
  _ = lib.getExe;
  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; };
  vars = import ./vars.nix { inherit pkgs config; };
  thunar-with-plugins = with pkgs.xfce; (thunar.override {
    thunarPlugins = [ thunar-volman thunar-archive-plugin thunar-media-tags-plugin ];
  });

in
{

  imports = [ ./polybar.nix ];
  config = {
    home =
      let
        gio = pkgs.gnome.gvfs;
      in
      {
        packages = with pkgs; [
          ### Window
          wmname
          sxhkd
          # dunst
          # rofi
          # polybar
          thunar-with-plugins
          xfce.xfce4-power-manager
          xfce.tumbler
          xfce.exo

          ### Theme
          lxappearance-gtk2
          papirus-icon-theme
          papirus-folders
          materia-theme
          gnome3.adwaita-icon-theme

          ### File Manager
          gio # Virtual Filesystem support library
          cifs-utils # Tools for managing Linux CIFS client filesystems

          # Utils
          pamixer # Pulseaudio command line mixer
          # nitrogen
          feh
          cava
          font-manager
          imagemagick
          libinput-gestures
          imagemagick
          meld
          xclip
          lm_sensors
          xorg.xprop
          xorg.xrandr
          # gnome.gnome-disk-utility
          gparted
          ntfsprogs
          pavucontrol
          udiskie
          udisks

          # Polkit
          mate.mate-polkit

          # fonts
          maple-mono
          font-awesome
          meslo-lgs-nf
          maple-mono-SC-NF
          unstable.sarasa-gothic
        ];

        # sudo apt-get reinstall lxsession;sudo apt install --reinstall lightdm;sudo systemctl enable lightdm

        sessionVariables = {
          "_JAVA_AWT_WM_NONREPARENTING" = "1";
          GIO_EXTRA_MODULES = "${gio}/lib/gio/modules";
        };

        sessionPath = [ "$HOME/.local/bin" ];

        file = {
          ".config/Thunar/accels.scm".text = lib.fileContents ../../config/thunar/accels.scm;
          ".config/Thunar/uca.xml".text = ''
            <?xml version="1.0" encoding="UTF-8"?>
            <actions>
                <action>
                    <icon>xterm</icon>
                    <name>Open Terminal Here</name>
                    <unique-id>1612104464586264-1</unique-id>
                    <command>${pkgs.xfce.exo}/bin/exo-open --working-directory %f --launch "${_ vars.alacritty-custom}"</command>
                    <command>"${vars.alacritty-custom}/bin/alacritty"</command>
                    <description>Example for a custom action</description>
                    <patterns>*</patterns>
                    <startup-notify/>
                    <directories/>
                </action>
                <action>
                    <icon>code</icon>
                    <name>Open VSCode Here</name>
                    <unique-id>1612104464586265-1</unique-id>
                    <command>code %f</command>
                    <description></description>
                    <patterns>*</patterns>
                    <startup-notify/>
                    <directories/>
                </action>
                <action>
                    <icon>bcompare</icon>
                    <name>Compare</name>
                    <submenu></submenu>
                    <unique-id>1622791692322694-4</unique-id>
                    <command>${pkgs.meld}/bin/meld %F</command>
                    <description>Compare files and directories with  meld</description>
                    <range></range>
                    <patterns>*</patterns>
                    <directories/>
                    <text-files/>
                </action>
            </actions>
          '';
          "${config.xdg.configHome}/libinput-gestures.conf".text = ''
            gesture swipe right 3 bspc desktop -f next.local
            gesture swipe left 3 bspc desktop -f prev.local
          '';
        };
      };

    dconf.settings = { };
    xsession = {
      enable = true;
      windowManager = {
        bspwm = {
          enable = true;
          package = (nixgl pkgs.unstable.bspwm);
          startupPrograms = [
            "pgrep -x sxhkd > /dev/null || sxhkd"
            "xsetroot -cursor_name left_ptr"
            # "nitrogen --restore"
            "sleep 2; polybar -q everforest"
          ];
          alwaysResetDesktops = true;
          monitors = {
            Virtual-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" ];
            eDP-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" ];
            # bspc monitor eDP-1 -d 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰮯 󰮯
          };
          extraConfigEarly = ''
            xsetroot -cursor_name left_ptr

            # picom
            pkill picom
            picom -b &
            #picom --expiremental-backends --no-use-damage &
          '';
          settings = {
            pointer_modifier = "mod4";
            pointer_action1 = "move";
            pointer_action2 = "resize_side";
            pointer_action3 = "resize_corner";

            border_width = 3;
            window_gap = 10;
            split_ratio = 0.50;

            single_monocle = true;
            borderless_monocle = true;
            gapless_monocle = false;
            paddingless_mono = true;

            normal_border_color = "#343c40"; # "#1E1F29";
            active_border_color = "#DBBC7F";
            focused_border_color = "#DBBC7F"; # "#BD93F9";
            presel_border_color = "#343c40"; #"#FF79C6";

          };

          rules = {
            "chromium" = {
              desktop = "^3";
              focus = true;
            };
            "Blueman-manager" = {
              state = "floating";
              center = true;
            };
            "Alacritty" = {
              state = "pseudo_tiled";
              center = true;
            };
            "mpv" = {
              # "mplayer2"
              state = "floating";
              # rectangle = "1200x700+360+190";
              # desktop = "^6";
              sticky = true;
            };
            # "Kupfer.py" = {
            #   focus = "on";
            # };
            # "Screenkey" = {
            #   manage = "off";
            # };
            "Pavucontrol" = {
              state = "floating";
            };
          };
          # bspc rule -a Chromium desktop='^2'
          # bspc rule -a Blueman-manager state=floating center=true
          # bspc rule -a kitty state=pseudo_tiled center=true
          # bspc rule -a mplayer2 state=floating
          # bspc rule -a Kupfer.py focus=on
          # bspc rule -a Screenkey manage=off
        };
      };
    };

    gtk = {
      enable = true;
      iconTheme = {
        name = "Qogir-manjaro-dark";
        package = pkgs.qogir-icon-theme;
      };
      theme = {
        name = "zukitre-dark";
        package = pkgs.zuki-themes;
      };
      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };

    services = {
      sxhkd = {
        enable = true;
        keybindings = import ./sxhkdrc.nix args;
      };
      fusuma.enable = true;
    };

    programs = {
      alacritty = {
        enable = true;
        package = nixgl pkgs.alacritty;
        settings = import ../../apps/terminal/alacritty.nix args;
      };
      rofi = import ./rofi.nix args;
      feh = {
        enable = true;
        packages = pkgs.feh;
        keybindings = "";
        buttons = "";
      };
    };

    i18n = {
      glibcLocales = pkgs.glibcLocales.override {
        allLocales = false;
        locales = [ "en_US.UTF-8/UTF-8" "pt_BR.UTF-8/UTF-8" ];
      };
      inputMethod = {
        enabled = "fcitx5";
        fcitx5.addons = with pkgs; [
          fcitx5-rime
        ];
      };
    };

    systemd.user.services.polkit-agent = {
      Unit = {
        Description = "launch authentication-agent-1";
        After = [ "graphical-session.target" ];
        PartOf = [ "graphical-session.target" ];
      };
      Service = {
        Type = "simple";
        Restart = "on-failure";
        ExecStart = ''
          ${pkgs.mate.mate-polkit}/libexec/polkit-mate-authentication-agent-1
        '';
      };

      Install = { WantedBy = [ "graphical-session.target" ]; };
    };
  };
}
