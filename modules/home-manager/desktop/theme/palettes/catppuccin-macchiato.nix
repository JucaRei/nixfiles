args:
import ./_catppuccin.nix (
  args
  // {
    variant = "macchiato";
    label = "Catppuccin Macchiato";
    colors = {
      bg = "#24273a";
      bgAlt = "#1e2030";
      bgDark = "#181926";
      surface = "#363a4f";
      surfaceAlt = "#494d64";
      border = "#5b6078";
      fg = "#cad3f5";
      fgMuted = "#a5adcb";
      fgSubtle = "#6e738d";
      red = "#ed8796";
      orange = "#f5a97f";
      yellow = "#eed49f";
      green = "#a6da95";
      teal = "#8bd5ca";
      cyan = "#91d7e3";
      blue = "#8aadf4";
      purple = "#c6a0f6";
      pink = "#f5bde6";
      lavender = "#b7bdf8";
      sapphire = "#7dc4e4";
      sky = "#91d7e3";
      maroon = "#ee99a0";
      flamingo = "#f0c6c6";
      rosewater = "#f4dbd6";
      subtext1 = "#b8c0e0";
    };
  }
)
