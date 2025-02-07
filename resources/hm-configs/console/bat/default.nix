{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types mkForce;
  cfg = config.console.bat;
in
{
  options.console.bat = {
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
        theme = mkForce "tokyo_night";
        style = "plain"; # remove line numbers
        pager = "less -FR";
      };
      themes = {
        #   # cyberpunk-neon =
        #   #   builtins.readFile ../../config/bat/themes/cyberpunk-neon.tmTheme;
        #   # Catppuccin-mocha =
        #   #   builtins.readFile ../../config/bat/themes/Catppuccin-mocha.tmTheme;
        #   # rose_pine_moon =
        #   #   builtins.readFile ../../config/bat/themes/rose_pine_moon.tmTheme;
        # tokyo_night = lib.fileContents ../../../dots/bat/themes/tokyo_night.tmTheme;
        tokyo_night = {
          src = ../../../dots/bat/themes;
          file = "tokyo_night.tmTheme";
        };
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
        MANPAGER = "sh -c 'col -bx | bat -l man -p'";
        MANROFFOPT = "-c";
      };
    };
  };
}
