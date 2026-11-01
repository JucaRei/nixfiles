{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    ;
  cfg = config.system.programs.console.bat;

  themeLib = config.desktop.theme.lib;
  themeName = config.desktop.theme.name;
  c = config.desktop.theme.colors;

  # Mapeamento de paletas do repo para temas conhecidos do bat
  themeMap = {
    catppuccin-mocha = "Catppuccin Mocha";
    catppuccin-latte = "Catppuccin Latte";
    catppuccin-frappe = "Catppuccin Frappe";
    catppuccin-macchiato = "Catppuccin Macchiato";
    dracula = "Dracula";
    nord = "Nord";
    gruvbox = "gruvbox-dark";
    solarized = "Solarized (dark)";
    tokyo-night = "tokyo_night";
    rose-pine = "rose_pine_moon";
    cyberpunk = "cyberpunk-neon";
  };

  isCustom = config.desktop.theme.custom != null || config.desktop.theme.overrides != { };
  matchedTheme = if isCustom then null else (themeMap.${themeName} or null);
  selectedTheme = if matchedTheme != null then matchedTheme else "custom-desktop-theme";

  generatedThemePkg = pkgs.writeTextDir "custom-desktop-theme.tmTheme" (
    themeLib.generateTmTheme {
      name = "CustomDesktopTheme";
      colors = c;
    }
  );
in
{
  options.system.programs.console.bat = {
    enable = lib.my.mkBool false "Enable bat cat clone with syntax highlighting.";
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      config = {
        style = "plain"; # remove line numbers
        pager = "less -FR";
      }
      // lib.optionalAttrs config.desktop.theme.targets.bat {
        theme = mkDefault selectedTheme;
      };
      themes = {
        tokyo_night = {
          src = ./themes;
          file = "tokyo_night.tmTheme";
        };
        rose_pine_moon = {
          src = ./themes;
          file = "rose_pine_moon.tmTheme";
        };
        cyberpunk-neon = {
          src = ./themes;
          file = "cyberpunk-neon.tmTheme";
        };
      }
      // lib.optionalAttrs (config.desktop.theme.targets.bat && matchedTheme == null) {
        custom-desktop-theme = {
          src = generatedThemePkg;
          file = "custom-desktop-theme.tmTheme";
        };
      };

      extraPackages = with pkgs.bat-extras; [
        batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };

    # Avoid [bat error]: The binary caches for the user-customized syntaxes and themes in
    # '/home/<user>/.cache/bat' are not compatible with this version of bat (0.25.0).
    systemd.user.services.bat-cache = {
      Unit.Description = "Build and update bat cache";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bat}/bin/bat cache --build";
      };
      Install.WantedBy = [ "default.target" ];
    };

    # home.activation.buildBatCache = "${lib.getExe pkgs.bat} cache --build";
    # home.activation.batCacheRebuild = {
    #   after = [ "linkGeneration" ];
    #   before = [ ];
    #   data = ''
    #     ${pkgs.bat}/bin/bat cache --build
    #   '';
    # };
    home = {
      sessionVariables = {
        # MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
        # MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        # MANROFFOPT = "-c";
      };
      shellAliases = {
        cat = ''bat --paging=never --style="numbers,changes" --italic-text=always''; # bat (cat)
        ct = ''bat --paging=never --style="plain" --italic-text=always''; # bat (cat)
      };
    };
  };
}
