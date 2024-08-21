{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.modules.bat;
in
{
  options.modules.bat = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;
      # catppuccin.enable = true;
      config = {
        theme = "tokyo_night";
        style = "plain"; # remove line numbers
      };
      themes = {
        # cyberpunk-neon =
        #   builtins.readFile ../../../../resources/configs/bat/themes/cyberpunk-neon.tmTheme;
        # Catppuccin-mocha =
        #   builtins.readFile ../../../../resources/configs/bat/themes/Catppuccin-mocha.tmTheme;
        # rose_pine_moon =
        #   builtins.readFile ../../../../resources/configs/bat/themes/rose_pine_moon.tmTheme;
        tokyo_night =
          # builtins.readFile ../../../../resources/configs/bat/themes/tokyo_night.tmTheme;
          lib.fileContents ../../../../resources/configs/bat/themes/tokyo_night.tmTheme;
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
    systemd.user.services.bat-cache = {
      Unit.Description = "Build and update bat cache";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bat}/bin/bat cache --build";
      };
      Install.WantedBy = [ "default.target" ];
    };
    home.shellAliases = {
      cat = ''${pkgs.bat}/bin/bat --paging=never --theme=tokyo_night --style="numbers,changes" --italic-text=always''; # bat (cat)
      ct = ''${pkgs.bat}/bin/bat --paging=never --theme=tokyo_night --style="plain" --italic-text=always''; # bat (cat)
    };
  };
}
