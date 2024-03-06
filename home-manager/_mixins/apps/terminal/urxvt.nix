{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  termDesktop = pkgs.writeTextFile {
    name = "urxvt.desktop";
    destination = "/share/applications/rxvt.desktop";
    text = ''
      [Desktop Entry]
      Exec=/home/juca/.local/bin/term
      Icon=utilities-terminal
      Name[en_US]=Terminal
      Name=Terminal
      StartupNotify=true
      Terminal=false
      Type=Application
    '';
  };

  cfg = config.within.urxvt;
in {
  config = {
    home.packages = with pkgs; [
      rxvt-unicode
      urxvt_font_size
      urxvt_perl
      urxvt_tabbedex
      urxvt_vtwheel
      anonymousPro

      # XXX HACK Terminal desktop file
      termDesktop
    ];

    home.file.".local/bin/term" = {
      executable = true;
      text = ''
        #!/bin/sh

        ${pkgs.xorg.xrdb}/bin/xrdb -merge ~/.Xresources

        ${pkgs.rxvt-unicode}/bin/urxvtc "$@"
        if [ $? -eq 2 ]; then
          ${pkgs.rxvt-unicode}/bin/urxvtd -q -o -f
          ${pkgs.rxvt-unicode}/bin/urxvtc "$@"
        fi
      '';
    };

    xresources.extraConfig = lib.mkForce ''
      ! -----------------------------------------------------------------------------
      ! File: gruvbox-urxvt256.xresources
      ! Description: Retro groove colorscheme generalized
      ! Author: morhetz <morhetz@gmail.com>
      ! Source: https://github.com/morhetz/gruvbox-generalized
      ! Last Modified: 13 Dec 2013
      ! -----------------------------------------------------------------------------
      URxvt.color24:  #076678
      URxvt.color66:  #427b58
      URxvt.color88:  #9d0006
      URxvt.color96:  #8f3f71
      URxvt.color100: #79740e
      URxvt.color108: #8ec07c
      URxvt.color109: #83a598
      URxvt.color130: #af3a03
      URxvt.color136: #b57614
      URxvt.color142: #b8bb26
      URxvt.color167: #fb4934
      URxvt.color175: #d3869b
      URxvt.color208: #fe8019
      URxvt.color214: #fabd2f
      URxvt.color223: #ebdbb2
      URxvt.color228: #f2e5bc
      URxvt.color229: #fbf1c7
      URxvt.color230: #f9f5d7
      URxvt.color234: #1d2021
      URxvt.color235: #282828
      URxvt.color236: #32302f
      URxvt.color237: #3c3836
      URxvt.color239: #504945
      URxvt.color241: #665c54
      URxvt.color243: #7c6f64
      URxvt.color244: #928374
      URxvt.color245: #928374
      URxvt.color246: #a89984
      URxvt.color248: #bdae93
      URxvt.color250: #d5c4a1
    '';

    xresources.properties = lib.mkForce {
      # colors
      "*background" = "#32302f";
      "*foreground" = "#ebdbb2";
      "*color0" = "#282828";
      "*color1" = "#cc241d";
      "*color2" = "#98971a";
      "*color3" = "#d79921";
      "*color4" = "#458588";
      "*color5" = "#b16286";
      "*color6" = "#689d6a";
      "*color7" = "#a89984";
      "*color8" = "#928374";
      "*color9" = "#fb4934";
      "*color10" = "#b8bb26";
      "*color11" = "#fabd2f";
      "*color12" = "#83a598";
      "*color13" = "#d3869b";
      "*color14" = "#8ec07c";
      "*color15" = "#ebdbb2";

      # extensions i use
      "URxvt.perl-ext-common" = "default,clipboard,matcher,tabbedex,vtwheel";

      # transparency
      "URxvt*depth" = "32";

      # URL opening
      "URxvt.url-launcher" = "${pkgs.xdg_utils}/bin/xdg-open";
      "URxvt.keysym.C-Delete" = "perl:matcher:last";
      "URxvt.keysym.M-Delete" = "perl:matcher:list";
      "URxvt.matcher.button" = "1";

      # Tabs
      "URxvt.tabbedex.autohide" = "false";
      "URxvt.tabbedex.reopen-on-close" = "no";
      "URxvt.keysym.Control-t" = "perl:tabbedex:new_tab";
      "URxvt.keysym.Control-Tab" = "perl:tabbedex:next_tab";
      "URxvt.keysym.Control-Shift-Tab" = "perl:tabbedex:prev_tab";
      "URxvt.keysym.Control-Shift-Left" = "perl:tabbedex:move_tab_left";
      "URxvt.keysym.Control-Shift-Right" = "perl:tabbedex:move_tab_right";
      "URxvt.keysym.Control-Shift-R" = "perl:tabbedex:rename_tab";
      "URxvt.tabbedex.no-tabbedex-keys" = "true";
      "URxvt.tabbedex.new-button" = "yes";

      # Clipboard
      "URxvt.clipboard.autocopy" = "true";
      "URxvt.keysym.Shift-M-C" = "perl:clipboard:copy";
      "URxvt.keysym.Shift-M-V" = "perl:clipboard:paste";

      # Font-size
      "URxvt.keysym.C-Up" = "perl:font-size:increase";
      "URxvt.keysym.C-Down" = "perl:font-size:decrease";
      "URxvt.keysym.C-S-Up" = "perl:font-size:incglobal";
      "URxvt.keysym.C-S-Down" = "perl:font-size:decglobal";
      "URxvt.keysym.C-equal" = "perl:font-size:reset";
      "URxvt.keysym.C-slash" = "perl:font-size:show";

      # Hacks
      "URxvt*skipBuiltinGlyphs" = "true";
      "URxvt.scrollBar" = "false";
      "URxvt.iso14755" = "false";
      "URxvt.iso14755_52" = "false";
      "URxvt.geometry" = "100x50";
      "URxvt.depth" = "32";
      "URxvt.background" = "[95]#32302f";

      # Font
      "URxvt.font" = "xft:Hack:size=12";
    };

    systemd.user.services = {
      urxvtd = {
        Unit = {
          Description = "Urxvt Terminal Daemon";
          Documentation = "man:urxvtd(1) man:urxvt(1)";
        };

        Service = {ExecStart = ["${pkgs.rxvt-unicode}/bin/urxvtd -o -q"];};

        Install = {WantedBy = ["default.target"];};
      };
    };
  };
}
