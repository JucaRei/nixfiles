{ options
, config
, lib
, pkgs
, namespace
, ...
}:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.desktop.addons.firefox-nordic-theme;
  profileDir = ".mozilla/firefox/${config.${namespace}.user.name}";
in
{
  options.${namespace}.desktop.addons.firefox-nordic-theme = with types; {
    enable = mkBoolOpt false "Whether to enable the Nordic theme for firefox.";
  };

  config = mkIf cfg.enable {
    excalibur.apps.firefox = {
      extraConfig = builtins.readFile "${pkgs.excalibur.firefox-nordic-theme}/configuration/user.js";
      userChrome = ''
        @import "${pkgs.excalibur.firefox-nordic-theme}/userChrome.css";
      '';
    };
  };
}
