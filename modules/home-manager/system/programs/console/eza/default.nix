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
    "kanagawa" = ./themes/kanagawa-wave.yml;
    "catppuccin-mocha" = ./themes/catppuccin-mocha.yml;
    "catppuccin-macchiato" = ./themes/catppuccin-mocha.yml;
    "catppuccin" = ./themes/catppuccin-mocha.yml;
    "tokyonight" = ./themes/tokyonight.yml;
    "tokyo-night" = ./themes/tokyonight.yml;
    "dracula" = ./themes/dracula.yml;
    "nord" = ./themes/nord.yml;
    "gruvbox-dark" = ./themes/gruvbox-dark.yml;
    "gruvbox" = ./themes/gruvbox-dark.yml;
  };

  selectedTheme =
    if cfg.theme == "auto" then (config.desktop.theme.name or "kanagawa-wave") else cfg.theme;

  normalizedTheme =
    if builtins.isString selectedTheme then
      toLower (builtins.replaceStrings [ " " "_" ] [ "-" "-" ] selectedTheme)
    else
      null;

  dynamicThemeText =
    let
      c = config.desktop.theme.colors;
    in
    ''
      colourful: true
      filekinds:
        normal: { foreground: "${c.fg}" }
        directory: { foreground: "${c.blue}" }
        symlink: { foreground: "${c.cyan}" }
        pipe: { foreground: "${c.fgSubtle}" }
        block_device: { foreground: "${c.orange}" }
        char_device: { foreground: "${c.orange}" }
        socket: { foreground: "${c.fgSubtle}" }
        special: { foreground: "${c.purple}" }
        executable: { foreground: "${c.green}" }
        mount_point: { foreground: "${c.teal}" }
      perms:
        user_read: { foreground: "${c.cyan}" }
        user_write: { foreground: "${c.orange}" }
        user_execute_file: { foreground: "${c.green}" }
        user_execute_other: { foreground: "${c.green}" }
        group_read: { foreground: "${c.cyan}" }
        group_write: { foreground: "${c.yellow}" }
        group_execute: { foreground: "${c.green}" }
        other_read: { foreground: "${c.fgSubtle}" }
        other_write: { foreground: "${c.red}" }
        other_execute: { foreground: "${c.green}" }
      size:
        major: { foreground: "${c.fgSubtle}" }
        minor: { foreground: "${c.cyan}" }
        number_byte: { foreground: "${c.fg}" }
        number_kilo: { foreground: "${c.cyan}" }
        number_mega: { foreground: "${c.blue}" }
        number_giga: { foreground: "${c.purple}" }
        number_huge: { foreground: "${c.pink}" }
      git:
        new: { foreground: "${c.green}" }
        modified: { foreground: "${c.yellow}" }
        deleted: { foreground: "${c.red}" }
        renamed: { foreground: "${c.purple}" }
    '';
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
        default = if (config.desktop.theme ? name) then config.desktop.theme.name else "kanagawa-wave";
        type = nullOr (either str (attrsOf anything));
        description = ''
          Theme for eza. Defaults to the active desktop.theme.name (e.g. "tokyo-night", "tokyonight",
          "kanagawa-wave", "catppuccin-mocha", "dracula", "nord", "gruvbox-dark"). Set to null to disable custom theming.
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
      enableNushellIntegration = mkIf (
        config.system.programs.shells.default == "nu" || config.system.programs.shells.default == "nushell"
      ) true;
      extraOptions = [
        "--color=always"
        "--icons"
        "--group-directories-first"
        "--header"
        "--time-style=long-iso"
        "-l"
      ];
    };

    xdg.configFile."eza/theme.yml" = mkIf (normalizedTheme != null && normalizedTheme != "") (
      if predefinedThemes ? ${normalizedTheme} then
        { source = predefinedThemes.${normalizedTheme}; }
      else
        { text = dynamicThemeText; }
    );

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
