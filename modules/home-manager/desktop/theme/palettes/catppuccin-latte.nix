# Catppuccin Latte palette definition
args:
let
  latte = {
    crust = "#dce0e8";
    mantle = "#e6e9ef";
    base = "#eff1f5";
    surface0 = "#ccd0da";
    surface1 = "#bcc0cc";
    surface2 = "#acb0be";
    overlay0 = "#9ca0b0";
    overlay1 = "#8c8fa1";
    overlay2 = "#7c7f93";
    subtext0 = "#6c6f85";
    subtext1 = "#5c5f77";
    text = "#4c4f69";
    rosewater = "#dc8a78";
    flamingo = "#dd7878";
    pink = "#ea76cb";
    mauve = "#8839ef";
    red = "#d20f39";
    maroon = "#e64553";
    peach = "#fe640b";
    yellow = "#df8e1d";
    green = "#40a02b";
    teal = "#179299";
    sky = "#04a5e5";
    sapphire = "#209fb5";
    blue = "#1e66f5";
    lavender = "#7287fd";
  };
in
import ./_catppuccin.nix (
  args
  // {
    variant = "latte";
    label = "Catppuccin Latte";
    colors = {
      bg = latte.base;
      bgAlt = latte.mantle;
      bgDark = latte.crust;
      surface = latte.surface0;
      surfaceAlt = latte.surface1;
      border = latte.surface2;
      fg = latte.text;
      fgMuted = latte.subtext0;
      fgSubtle = latte.overlay0;
      inherit (latte)
        red
        yellow
        green
        teal
        blue
        pink
        ;
      orange = latte.peach;
      cyan = latte.sky;
      purple = latte.mauve;
    };
  }
)
