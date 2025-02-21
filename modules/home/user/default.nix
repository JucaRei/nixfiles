{ lib, config, pkgs, namespace, osConfig ? { }, ... }:
let
  inherit (lib)
    types
    mkIf
    mkDefault
    mkMerge
    ;
  inherit (lib.${namespace}) mkOpt enabled;

  cfg = config.${namespace}.user;

  is-linux = pkgs.stdenv.isLinux;
  is-darwin = pkgs.stdenv.isDarwin;

  home-directory =
    if cfg.name == null then
      null
    else if is-darwin then
      "/Users/${cfg.name}"
    else
      "/home/${cfg.name}";
in
{
  options.${namespace}.user = {
    enable = mkOpt types.bool true "Whether to configure the user account.";
    name = mkOpt (types.nullOr types.str) (config.snowfallorg.user.name or "juca") "The user account.";

    fullName = mkOpt types.str "Reinaldo P Jr" "The full name of the user.";
    email = mkOpt types.str "reinaldo800@gmail.com" "The email of the user.";

    home = mkOpt (types.nullOr types.str) home-directory "The user's home directory.";
  };

  config = mkIf cfg.enable (mkMerge [
    {
      assertions = [
        {
          assertion = cfg.name != null;
          message = "${namespace}.user.name must be set";
        }
        {
          assertion = cfg.home != null;
          message = "${namespace}.user.home must be set";
        }
      ];

      home = {
        username = mkDefault cfg.name;
        homeDirectory = mkDefault cfg.home;

        sessionVariables = {
          XDG_BIN_HOME = "$HOME/.local/bin";
          XDG_CACHE_HOME = "$HOME/.cache";
          XDG_CONFIG_HOME = "$HOME/.config";
          XDG_DATA_HOME = "$HOME/.local/share";
          XDG_DESKTOP_DIR = "$HOME";
        };

        file = {
          "Desktop/.keep".text = "";
          "Documents/.keep".text = "";
          "Downloads/.keep".text = "";
          "Music/.keep".text = "";
          "Pictures/.keep".text = "";
          "Videos/.keep".text = "";
          "work/.keep".text = "";
        }
          # //
          # lib.optionalAttrs (cfg.icon != null) {
          #   ".face".source = cfg.icon;
          #   ".face.icon".source = cfg.icon;
          #   "Pictures/${cfg.icon.fileName or (builtins.baseNameOf cfg.icon)}".source = cfg.icon;
          # }
        ;
      };
    }
  ]);
}
