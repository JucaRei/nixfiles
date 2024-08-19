{ pkgs, lib, config, ... }:
with lib;
let
  inherit (pkgs.stdenv) isLinux isDarwin;
in
{
  programs = {
    fish = {
      enable = true;
      catppuccin.enable = true;
    };
  };

  home.file = {
    "${config.xdg.configHome}/fastfetch/config.jsonc".text = builtins.readFile ../../../../../resources/configs/fastfetch.jsonc;
    "${config.xdg.configHome}/gh-dash/config.yml".text = builtins.readFile ../../../../../resources/configs/gh-dash-catppuccin-mocha-blue.yml;
    "${config.xdg.configHome}/yazi/keymap.toml".text = builtins.readFile ../../../../../resources/configs/yazi-keymap.toml;
    "${config.xdg.configHome}/fish/functions/help.fish".text = builtins.readFile ../../../../../resources/configs/help.fish;
    "${config.xdg.configHome}/fish/functions/h.fish".text = builtins.readFile ../../../../../resources/configs/h.fish;
    ".hidden".text = ''snap'';
  };
}
