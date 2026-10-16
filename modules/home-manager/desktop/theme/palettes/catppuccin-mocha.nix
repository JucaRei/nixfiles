args:
import ./_catppuccin.nix (
  args
  // {
    variant = "mocha";
    label = "Catppuccin Mocha";
    colors = {
      bg = "#1e1e2e";
      bgAlt = "#181825";
      bgDark = "#11111b";
      surface = "#313244";
      surfaceAlt = "#45475a";
      border = "#585b70";
      fg = "#cdd6f4";
      fgMuted = "#a6adc8";
      fgSubtle = "#6c7086";
      red = "#f38ba8";
      orange = "#fab387";
      yellow = "#f9e2af";
      green = "#a6e3a1";
      teal = "#94e2d5";
      cyan = "#89dceb";
      blue = "#89b4fa";
      purple = "#cba6f7";
      pink = "#f5c2e7";
      # Extras do Catppuccin (usados pela polybar)
      lavender = "#b4befe";
      sapphire = "#74c7ec";
      sky = "#89dceb";
      maroon = "#eba0ac";
      flamingo = "#f2cdcd";
      rosewater = "#f5e0dc";
      subtext1 = "#bac2de";
    };
  }
)
