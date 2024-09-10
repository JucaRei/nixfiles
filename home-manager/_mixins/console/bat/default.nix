{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.custom.console.bat;
in
{
  options.custom.console.bat = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.bat = {
      # catppuccin.enable = true;
      enable = true;
      config = {
        # theme = "Catppuccin-mocha";
        theme = "tokyo_night";
        style = "plain"; # remove line numbers
      };
      themes = {
        #   # cyberpunk-neon =
        #   #   builtins.readFile ../../config/bat/themes/cyberpunk-neon.tmTheme;
        #   # Catppuccin-mocha =
        #   #   builtins.readFile ../../config/bat/themes/Catppuccin-mocha.tmTheme;
        #   # rose_pine_moon =
        #   #   builtins.readFile ../../config/bat/themes/rose_pine_moon.tmTheme;
        tokyo_night = lib.fileContents ../../config/bat/themes/tokyo_night.tmTheme;
        #   # Catppuccin-mocha = builtins.readFile (pkgs.fetchFromGitHub
        #   #   {
        #   #     owner = "catppuccin";
        #   #     repo = "bat";
        #   #     rev = "ba4d16880d63e656acced2b7d4e034e4a93f74b1";
        #   #     sha256 = "sha256-6WVKQErGdaqb++oaXnY3i6/GuH2FhTgK0v4TN4Y0Wbw=";
        #   #   }
        #   # + "/Catppuccin-mocha.tmTheme");
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
    # home.activation.buildBatCache = "${lib.getExe pkgs.bat} cache --build";
  };
}
