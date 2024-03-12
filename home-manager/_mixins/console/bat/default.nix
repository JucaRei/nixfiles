{ pkgs, lib, ... }: {
  programs.bat = {
    enable = true;
    config = {
      theme = "tokyo_night";
      style = "plain"; # remove line numbers
    };
    themes = {
      # cyberpunk-neon =
      #   builtins.readFile ../../config/bat/themes/cyberpunk-neon.tmTheme;
      # Catppuccin-mocha =
      #   builtins.readFile ../../config/bat/themes/Catppuccin-mocha.tmTheme;
      # rose_pine_moon =
      #   builtins.readFile ../../config/bat/themes/rose_pine_moon.tmTheme;
      tokyo_night =
        # builtins.readFile ../../config/bat/themes/tokyo_night.tmTheme;
        lib.fileContents ../../config/bat/themes/tokyo_night.tmTheme;
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
}
