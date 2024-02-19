{ pkgs, lib, ... }: {
  programs.bat = {
    enable = true;
    config = { theme = "tokyo_night"; };
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
