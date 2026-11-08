# Catppuccin Frappe palette definition
args:
let
  frappe = {
    crust = "#232634";
    mantle = "#292c3c";
    base = "#303446";
    surface0 = "#414559";
    surface1 = "#51576d";
    surface2 = "#626880";
    overlay0 = "#737994";
    overlay1 = "#838ba7";
    overlay2 = "#949cbb";
    subtext0 = "#a5adce";
    subtext1 = "#b5bfe2";
    text = "#c6d0f5";
    rosewater = "#f2d5cf";
    flamingo = "#eebebe";
    pink = "#f4b8e4";
    mauve = "#ca9ee6";
    red = "#e78284";
    maroon = "#ea999c";
    peach = "#ef9f76";
    yellow = "#e5c890";
    green = "#a6d189";
    teal = "#81c8be";
    sky = "#99d1db";
    sapphire = "#85c1dc";
    blue = "#8caaee";
    lavender = "#babbf1";
  };
in
import ./_catppuccin.nix (
  args
  // {
    variant = "frappe";
    label = "Catppuccin Frappe";
    colors = {
      bg = frappe.base;
      bgAlt = frappe.mantle;
      bgDark = frappe.crust;
      surface = frappe.surface0;
      surfaceAlt = frappe.surface1;
      border = frappe.surface2;
      fg = frappe.text;
      fgMuted = frappe.subtext0;
      fgSubtle = frappe.overlay0;
      inherit (frappe)
        red
        yellow
        green
        teal
        blue
        pink
        ;
      orange = frappe.peach;
      cyan = frappe.sky;
      purple = frappe.mauve;
    };
  }
)
