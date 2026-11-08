# What it is: Simple package installer for CLI and GUI applications on NixOS.
# How to enable: Set `my.apps.cli = [ "..." ];` or `my.apps.gui = [ "..." ];` in settings.nix.
# Example: my.apps.cli = [ "htop" "ripgrep" ]; my.apps.gui = [ "firefox" ];
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.apps;

  # Resolve package attribute from nixpkgs with user-friendly error message
  resolvePkg =
    name: pkgs.${name} or (throw "pacote '${name}' não encontrado; procure em search.nixos.org");
in
{
  options.my.apps = {
    cli = lib.my.mkListOfEx lib.types.str [ ] "Lista de programas CLI para instalar pelo nome." [
      "htop"
      "ripgrep"
    ];
    gui = lib.my.mkListOfEx lib.types.str [ ] "Lista de programas GUI para instalar pelo nome." [
      "firefox"
      "vlc"
    ];
  };

  config = {
    environment.systemPackages = (map resolvePkg cfg.cli) ++ (map resolvePkg cfg.gui);
  };
}
