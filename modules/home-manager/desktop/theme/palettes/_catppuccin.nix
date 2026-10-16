# Helper compartilhado pelas variantes Catppuccin (GTK, cursor e ícones).
{
  lib,
  pkgs,
  accent,
  variant, # "mocha" | "macchiato" | "frappe" | "latte"
  label,
  colors,
}:
let
  # Papéis do tema -> nomes de acento do catppuccin-gtk
  accentName =
    {
      blue = "blue";
      purple = "mauve";
      pink = "pink";
      red = "red";
      orange = "peach";
      yellow = "yellow";
      green = "green";
      teal = "teal";
      cyan = "sky";
    }
    .${accent};

  cap = s: lib.toUpper (builtins.substring 0 1 s) + builtins.substring 1 (builtins.stringLength s) s;
  isLight = variant == "latte";
in
{
  inherit label colors;
  variant = if isLight then "light" else "dark";

  gtk = {
    name = "catppuccin-${variant}-${accentName}-standard+rimless";
    package = pkgs.catppuccin-gtk.override {
      accents = [ accentName ];
      size = "standard";
      tweaks = [ "rimless" ];
      inherit variant;
    };
    # Nomes antigos que alguns apps ainda procuram
    aliases = [ "Catppuccin-${cap variant}-Standard-${cap accentName}-Dark" ];
  };

  icons = {
    name = if isLight then "Papirus-Light" else "Papirus-Dark";
    package = pkgs.papirus-icon-theme;
  };

  cursor = {
    name = "catppuccin-${variant}-${if isLight then "light" else "dark"}-cursors";
    package = pkgs.catppuccin-cursors."${variant}${if isLight then "Light" else "Dark"}";
    aliases = [ "Catppuccin-${cap variant}-${if isLight then "Light" else "Dark"}-Cursors" ];
  };
}
