{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.tools.meld;
  isDark = (config.desktop.theme.variant or "dark") == "dark";
  schemeId = builtins.replaceStrings [ "-" ] [ "_" ] config.desktop.theme.name;
in
{
  options = {
    system.programs.tools.meld = {
      enable = mkEnableOption "Enable's meld";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = [ pkgs.meld ];
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
          prefer-dark-theme = isDark;
          highlight-syntax = true;
          style-scheme = schemeId;
        };
      };
  };
}
