{ config, lib, ... }:
let
  inherit (lib)
    mkOption
    mkIf
    getExe
    toLower
    concatStringsSep
    ;
  inherit (lib.types)
    bool
    str
    nullOr
    either
    attrsOf
    anything
    ;
  cfg = config.system.programs.console.eza;

  predefinedThemes = {
    "kanagawa-wave" = ./themes/kanagawa-wave.yml;
    "catppuccin-mocha" = ./themes/catppuccin-mocha.yml;
    "tokyonight" = ./themes/tokyonight.yml;
  };

  normalizedTheme =
    if builtins.isString cfg.theme then
      toLower (builtins.replaceStrings [ " " "_" ] [ "-" "-" ] cfg.theme)
    else
      null;
in
{
  options = {
    system.programs.console.eza = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enable's eza.";
      };

      theme = mkOption {
        default = "kanagawa-wave";
        type = nullOr (either str (attrsOf anything));
        description = ''
          Theme for eza. Can be a predefined theme name (e.g. "kanagawa-wave" / "Kanagawa Wave",
          "catppuccin-mocha", "tokyonight") or a custom YAML attrset. Set to null to disable custom theming.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      git = true;
      icons = "auto";
      colors = "always";
      theme = if builtins.isAttrs cfg.theme then cfg.theme else { };
      enableBashIntegration = mkIf (config.system.programs.shells.default == "bash") true;
      enableFishIntegration = mkIf (config.system.programs.shells.default == "fish") true;
      enableZshIntegration = mkIf (config.system.programs.shells.default == "zsh") true;
      extraOptions = [
        "--color=always"
        "--icons"
        "--group-directories-first"
        "--header"
        "--time-style=long-iso"
        "-l"
      ];
    };

    xdg.configFile."eza/theme.yml" = mkIf (normalizedTheme != null && normalizedTheme != "") {
      source =
        predefinedThemes.${normalizedTheme}
          or (throw "Unknown eza theme: '${cfg.theme}'. Available: ${concatStringsSep ", " (builtins.attrNames predefinedThemes)}");
    };

    home = {
      shellAliases = {
        l2 = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso -l -T -h -L=2";
        lt = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso -a -h";
        lla = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso -l -a";
        tree = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso --tree -l";
        la = "${getExe config.programs.eza.package} --color=always --icons --header --time-style=long-iso -l -h -a";
      };
    };
  };
}
