{ pkgs, lib, config, hostname, ... }:
let
  vars = import ../vars.nix { inherit pkgs config hostname; };
  _ = lib.getExe;
in
{
  home = {
    file = {
      "${config.xdg.configHome}/rofi/configurations/screenshot.rasi".text = ''
        @theme "/dev/null"

        * {
          bg:			#0C0F09;
          fg:			#05E289;
          bgAlt:		#1B1E25;
          background-color:	@bg;
          text-color:		@fg;
        }
        @import "./Themes/style.rasi"

        window {
          transparency:	"real";
          width:		  100px;
          height:		  260px;
          location: east;
          x-offset: -10px;
        }

        mainbox { children: [ listview ]; }

        listview {
            cycle:      true;
            dynamic:    true;
            layout:     vertical;
            padding:    10px;
        }

        element {
          padding:		0px 0px 0px 0px;
          border-radius:	8px;
        }

        element-text {
          margin:		5px 8px 5px 12px;
          padding:		4px 5px 4px 5px;
          font:			"FiraCode Nerd Font 35";
          background-color:	inherit;
          text-color:		inherit;
        }
        element selected {
          background-color:	@fg;
          text-color:		@bgAlt;
        }
      '';
      "${config.xdg.configHome}/rofi/configurations/Themes/Nord/purple.rasi".text = ''
        @theme "/dev/null"

        * {
          bg:			#2E3440;
          fg:			#B48EAD;
          button:		#3B4252;
          background-color:	@bg;
          text-color:		@fg;
        }

        window {
          transparency:	"real";
          width:		  100px;
          height:		  260px;
          location: east;
          x-offset: -10px;
        }

        mainbox { children: [ listview ]; }

        listview {
            cycle:      true;
            dynamic:    true;
            layout:     vertical;
            padding:    10px;
        }

        element {
          padding:		0px 0px 0px 0px;
          border-radius:	8px;
        }

        element-text {
          margin:		5px 8px 5px 12px;
          padding:		4px 5px 4px 5px;
          font:			"FiraCode Nerd Font 35";
          background-color:	inherit;
          text-color:		inherit;
        }
        element selected {
          background-color:	@bg;
          text-color:		@bg;
        }
      '';
    };
  };
  programs.rofi = {
    enable = true;
    # font =
    plugins = with pkgs; [
      rofimoji
      rofi-calc
      rofi-bluetooth
      rofi-power-menu
      rofi-screenshot
      pinentry-rofi
    ];
    pass = {
      enable = true;
      package = pkgs.rofi-pass;
      extraConfig = ''
        # workaround for https://github.com/carnager/rofi-pass/issues/226
        help_color="#FF0000"'';
    };
    terminal = "${_ vars.alacritty-custom}";
  };
}
