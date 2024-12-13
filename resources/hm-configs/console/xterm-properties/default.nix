# { lib, config, ... }:
# let
#   inherit (lib) mkOption mkIf types;
#   cfg = config.console.xterm-properties;
# in
# {
#   options.console.xterm-properties = {
#     enable = mkOption {
#       default = true;
#       type = types.bool;
#     };
#   };

#   config = mkIf cfg.enable {
#     xresources.properties = {
#       "URxvt*depth" = 32;
#       "URxvt*.borderless" = 1;
#       "URxvt*.buffered" = true;
#       "URxvt*.cursorBlink" = true;
#       "URxvt*.font" = "xft:FiraCode Nerd Font Mono Retina:pixelsize=13";
#       "URxvt*.internalBorder" = 10;
#       "URxvt*.letterSpace" = 0;
#       "URxvt*.lineSpace" = 0;
#       "URxvt*.loginShell" = false;
#       "URxvt*.matcher.button" = 1;
#       "URxvt*.matcher.rend.0" = "Uline Bold fg5";
#       "URxvt*.saveLines" = 5000;
#       "URxvt*.scrollBar" = false;
#       "URxvt*.underlineColor" = "grey";
#       "URxvt.clipboard.autocopy" = true;
#       "URxvt.iso14755" = false;
#       "URxvt.iso14755_52" = false;
#       "URxvt.perl-ext-common" = "default,matcher";

#       # !!st
#       "Xft.antialias" = 1;
#       "Xft.hinting" = 1;
#       "Xft.autohint" = 0;
#       "Xft.hintstyle" = "hintslight";
#       "Xft.rgba" = "rgb";
#       "Xft.lcdfilter" = "lcddefault";

#       "st.font" = "FiraCode Nerd Font Mono:style=Medium,Regular:pixelsize=21.34:antialias=true";
#       # ! window padding
#       "st.borderpx" = 20;

#       # ! Set to a non-zero value to disable window decorations (titlebar, etc) and go borderless.
#       "st.borderless" = 1;

#       "st.disablebold" = 1;
#       "st.disableitalics" = 1;
#       "st.disableroman" = 1;

#       # ! Amount of lines scrolled
#       "st.scrollrate" = 5;

#       # ! Kerning / character bounding-box height multiplier
#       "st.chscale" = "1.0";

#       # ! Kerning / character bounding-box width multiplier
#       "st.cwscale" = "1.0";

#       # ! Available cursor values: 2 4 6 7 = █ _ | ☃ ( 1 3 5 are blinking versions)
#       "st.cursorshape" = 6;

#       # ! thickness of underline and bar cursors
#       "st.cursorthickness" = 2;

#       # ! (0|1) boxdraw(bold) enable toggle
#       "st.boxdraw_bold" = 0;

#       # ! braille (U28XX):  1: render as adjacent "pixels",  0: use font
#       "st.boxdraw_braille" = 0;

#       # ! set this to a non-zero value to force window depth
#       "st.depth" = 0;

#       # ! opacity==255 means what terminal will be not transparent, 0 - fully transparent
#       # ! (float values in range 0 to 1.0 may also be used)
#       "st.opacity" = "0.5";

#       # ! 1: render most of the lines/blocks characters without using the font for
#       # ! perfect alignment between cells (U2500 - U259F except dashes/diagonals).
#       # ! Bold affects lines thickness if boxdraw_bold is not 0. Italic is ignored.
#       # ! 0: disable (render all U25XX glyphs normally from the font).
#       "st.boxdraw" = 0;

#       "st.background" = "#181f21";
#       "st.foreground" = "#dadada";

#       # ! Black + DarkGrey
#       "st.color0" = "#151515";
#       "st.color8" = "#505050";

#       # ! DarkRed + Red
#       "st.color1" = "#ac4142";
#       "st.color9" = "#ac4142";

#       # ! DarkGreen + Green
#       "st.color2" = "#7e8d50";
#       "st.color10" = "#7e8d50";

#       # ! DarkYellow + Yellow
#       "st.color3" = "#e5b566";
#       "st.color11" = "#e5b566";

#       # ! DarkBlue + Blue
#       "st.color4" = "#6c99ba";
#       "st.color12" = "#6c99ba";

#       # ! DarkMagenta + Magenta
#       "st.color5" = "#9e4e85";
#       "st.color13" = "#9e4e85";

#       # ! DarkCyan + Cyan
#       "st.color6" = "#7dd5cf";
#       "st.color14" = "#7dd5cf";

#       # ! LightGrey + White
#       "st.color7" = "#d0d0d0";
#       "st.color15" = "#f5f5f5";

#       "XTerm*background" = "#121214";
#       "XTerm*foreground" = "#c8c8c8";
#       "XTerm*cursorBlink" = true;
#       "XTerm*cursorColor" = "#FFC560";
#       "XTerm*boldColors" = false;

#       #Black + DarkGrey
#       "*color0" = "#141417";
#       "*color8" = "#434345";
#       #DarkRed + Red
#       "*color1" = "#D62C2C";
#       "*color9" = "#DE5656";
#       #DarkGreen + Green
#       "*color2" = "#42DD76";
#       "*color10" = "#A1EEBB";
#       #DarkYellow + Yellow
#       "*color3" = "#FFB638";
#       "*color11" = "#FFC560";
#       #DarkBlue + Blue
#       "*color4" = "#28A9FF";
#       "*color12" = "#94D4FF";
#       #DarkMagenta + Magenta
#       "*color5" = "#E66DFF";
#       "*color13" = "#F3B6FF";
#       #DarkCyan + Cyan
#       "*color6" = "#14E5D4";
#       "*color14" = "#A1F5EE";
#       #LightGrey + White
#       "*color7" = "#c8c8c8";
#       "*color15" = "#e9e9e9";
#       "XTerm*faceName" = "FiraCode Nerd Font:size=13:style=Medium:antialias=true";
#       "XTerm*boldFont" = "FiraCode Nerd Font:size=13:style=Bold:antialias=true";
#       "XTerm*geometry" = "132x50";
#       "XTerm.termName" = "xterm-256color";
#       "XTerm*locale" = false;
#       "XTerm*utf8" = true;
#     };
#   };
# }

{ }
