{ pkgs, config, lib, hostname, ... }@args:
let
  inherit (lib) getExe getExe' mkDefault mkIf;
  _ = getExe;
  __ = getExe';

  nixgl = import ../../../../lib/nixGL.nix { inherit config pkgs; }; # if is non-nixos system
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  hasSystemd = if ("${pkgs.ps}/bin/ps --no-headers -o comm 1" == "systemd") then false else true; # check if is systemd system or not

  random-walls = "${pkgs.procps}/bin/watch -n 600 ${pkgs.feh}/bin/feh --randomize --bg-fill '$HOME/Pictures/wallpapers/*'"; # wallpapers from system
in
{
  imports = [
    ./packages.nix
    ./jgmenu.nix
  ];
  config = {
    xsession = {
      windowManager = {
        bspwm = {
          enable = true;
          package = if isGeneric then (nixgl pkgs.bspwm) else pkgs.bspwm;
          monitors = {
            Virtual-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
            HDMI-1-0 = [ "I" "III" "V" "VII" "IX" ];
            eDP-1 = [ "II" "IV" "VI" "VIII" "X" ];
            eDP1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
            eDP1-1 = [ "I" "II" "III" "IV" "V" "VI" "VII" "VIII" "IX" "X" ];
            #   # bspc monitor eDP-1 -d 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰮯 󰮯
          };
          extraConfigEarly = "
            ${getExe pkgs.wmname} LG3D \n
            # ${getExe' config.xsession.windowManager.bspwm.package "bspc"} config remove_disabled_monitors true \n
            # ${getExe' config.xsession.windowManager.bspwm.package "bspc"} config remove_unplugged_monitors true \n
          ";
          # ${isNitro_workspace}/bin/isNitro_workspace
          extraConfig = ''
            ${pkgs.systemdMinimal}/bin/systemctl --user start bspwm-session.target
            ${pkgs.xorg.xsetroot}/bin/xsetroot -cursor_name left_ptr
          '';
          rules = {
            "firefox" = {
              desktop = "^3";
              focus = true;
            };
            "Thunar" = {
              desktop = "^2";
              follow = true;
            };
            "Lxappearance" = {
              desktop = "^8";
              follow = false;
            };
            "Alacritty" = {
              # desktop = "^1";
              follow = true;
              state = "floating";
            };
            "Alacritty:floating" = {
              state = "floating";
            };
            "mpv" = {
              state = "floating";
              center = true;
              # rectangle = "1200x700+360+190";
              # desktop = "^6";
              # sticky = true;
            };
            "Pavucontrol" = {
              state = "floating";
              desktop = "^10";
              follow = true;
            };
            "ZapZap" = {
              state = "floating";
              desktop = "^9";
              follow = true;
            };
            "Notepadqq" = {
              desktop = "^4";
              follow = true;
            };
            ".gimp-2.10-wrapped_" = {
              desktop = "^5";
              follow = true;
            };
            "BleachBit" = {
              desktop = "^9";
              follow = true;
            };
            "Zathura" = {
              state = "tiled";
            };
            "GParted" = {
              desktop = "^10";
              follow = true;
            };
            "Virt-manager" = {
              desktop = "^5";
              follow = true;
              state = "floating";
            };
            # "ark" = {
            #   desktop = "^7";
            #   follow = true;
            # };
            "Engrampa" = {
              state = "floating";
            };
            "Audacity" = {
              # desktop = "^5";
              follow = true;
              state = "floating";
            };
            "Blueman-manager" = {
              state = "floating";
              center = true;
            };
          };
          settings = {
            remove_disabled_monitors = true;
            remove_unplugged_monitors = true;
            pointer_modifier = "mod1";
            pointer_action1 = "move"; # Move floating windows
            ### Resize floating windows ###
            pointer_action2 = "resize_side";
            pointer_action3 = "resize_corner";
            click_to_focus = "button1";
            focus_follows_pointer = false;
            top_padding = 2;
            left_padding = 1;
            right_padding = 1;
            border_width = 2;
            window_gap = 4;
            top_monocle_padding = 2;
            right_monocle_padding = 2;
            left_monocle_padding = 2;
            bottom_monocle_padding = 2;
            automatic_scheme = "tiling";
            initial_polarity = "first_child";
            split_ratio = 0.50;
            single_monocle = true;
            borderless_monocle = true;
            gapless_monocle = false;
            paddingless_mono = true;
            normal_border_color = "#b8bfe5"; # "#343c40"; # "#1E1F29"
            active_border_color = "#DBBC7F";
            focused_border_color = "#81ae5f"; # "#BD93F9";
            presel_border_color = "#343c40"; #"#FF79C6";
          };
          alwaysResetDesktops = true;
          startupPrograms = [
            "${getExe config.programs.alacritty.package} --daemon"
          ];
        };
      };

      numlock = {
        enable = if (hostname == "nitro") then true else false;
      };
    };

    systemd.user = {
      targets.bspwm-session = {
        Unit = {
          Description = "Bspwm Session";
          BindsTo = [ "graphical-session.target" ];
          Wants = [ "graphical-session-pre.target" ];
          After = [ "graphical-session-pre.target" ];
        };
      };
    };
  };
}
