{ config, lib, pkgs, ... }:

let
  inherit (lib) mkIf mkEnableOption mkMerge;
  cfg = config.modules.dev.nodejs;
in {
  options.modules.dev.nodejs = {
    enable = mkEnableOption "Enable nodejs";
    xdg.enable = mkEnableOption "Enable nodejs environment";
  };

  config = mkMerge [
    (mkIf cfg.enable {
      home.packages = builtins.attrValues {
        inherit (pkgs) nodejs;
      };
    })

    (mkIf (cfg.enable || cfg.xdg.enable) {
      xdg.configFile."npm/config".text = ''
        cache=${config.xdg.cacheHome}/npm
        prefix=${config.xdg.dataHome}/npm
      '';

      home.sessionVariables = {
        NPM_CONFIG_USERCONFIG = "${config.xdg.configHome}/npm/config";
        NPM_CONFIG_CACHE      = "${config.xdg.cacheHome}/npm";
        NPM_CONFIG_TMP        = "$XDG_RUNTIME_DIR/npm";
        NPM_CONFIG_PREFIX     = "${config.xdg.cacheHome}/npm";
        NODE_REPL_HISTORY     = "${config.xdg.cacheHome}/node/repl_history";
      };
    })
  ];
}
