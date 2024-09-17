{
  excalibur = {
    user = {
      enable = true;
      name = "juca";
    };

    roles = {
      desktop.enable = true;
    };

    programs = {
      terminal = {
        emulators.alacritty.enable = true;

        tools = {
          go.enable = true;
          yazi.enable = true;
        };
      };

      graphical = {
        apps = {
          discord.enable = true;
          spotify.enable = true;
        };

        editors.vscode = {
          enable = true;
          declarativeConfig = false;
        };

        wms.hyprland.enable = true;
      };
    };

    services.mpd = {
      enable = true;
      musicDirectory = "/home/juca/.local/share/mpd/music";
    };
  };

  home.stateVersion = "23.11";
}
