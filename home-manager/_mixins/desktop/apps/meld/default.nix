{ config, lib, pkgs, username, ... }:
let
  installFor = [ "juca" ];
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkOption types mkIf;
  cfg = config.desktop.apps.meld;
in
{
  options.desktop.apps.blackbox = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = cfg.enable {
    # Install meld for Linux and macOS but only apply configuration to Linux.
    home = mkIf (lib.elem username installFor) {
      file = mkIf isLinux {
        "${config.home.homeDirectory}/.local/share/libgedit-gtksourceview-300/styles/catppuccin-mocha.xml".text = builtins.readFile ./gedit-catppuccin-mocha.xml;
      };
      packages = with pkgs; [ meld ];
    };

    # User specific dconf settings; only intended as override for NixOS dconf profile user database
    dconf.settings =
      with lib.hm.gvariant;
      mkIf isLinux {
        "org/gnome/meld" = {
          custom-font = "FiraCode Nerd Font Mono Medium 13";
          indent-width = mkInt32 4;
          insert-spaces-instead-of-tabs = true;
          highlight-current-line = true;
          show-line-numbers = true;
          prefer-dark-theme = true;
          highlight-syntax = true;
          style-scheme = "catppuccin_mocha";
        };
      };
  };
}
