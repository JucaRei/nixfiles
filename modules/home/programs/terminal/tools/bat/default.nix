{
  config,
  lib,
  pkgs,
  namespace,
  ...
}:
let
  inherit (lib) getExe mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.programs.terminal.tools.bat;
in
{
  options.${namespace}.programs.terminal.tools.bat = {
    enable = mkBoolOpt false "Whether or not to enable bat.";
  };

  config = mkIf cfg.enable {
    programs.bat = {
      enable = true;

      config = {
        style = "auto,header-filesize";
        theme = "tokyo_night";
      };

      themes = {
        # cyberpunk-neon =
        #   builtins.readFile ./themes/cyberpunk-neon.tmTheme;
        # Catppuccin-mocha =
        #   builtins.readFile ./themes/Catppuccin-mocha.tmTheme;
        # rose_pine_moon =
        #   builtins.readFile ./themes/rose_pine_moon.tmTheme;
        tokyo_night =
          # builtins.readFile ./themes/tokyo_night.tmTheme;
          lib.fileContents ./themes/tokyo_night.tmTheme;
      };

      extraPackages = with pkgs.bat-extras; [
        # FIXME: broken nixpkg
        # batdiff
        batgrep
        batman
        batpipe
        batwatch
        prettybat
      ];
    };

    home.shellAliases = {
      cat = "${getExe pkgs.bat} --style=plain";
    };

    systemd.user.services.bat-cache = {
      Unit.Description = "Build and update bat cache";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bat}/bin/bat cache --build";
      };
      Install.WantedBy = [ "default.target" ];
    };
  };
}
