{ pkgs,  ... }:
{
  xsession = {
    windowManager = {
      awesome = {
        enable = true;
        package = pkgs.awesome;
      };
    };
  };
  home = {
    packages = with pkgs; [
      awesome-git
      lua5_4_compat
      gruvbox
      # phocus
      st
      mpd
      ncmpcpp
      imagemagick
      mpdris2
      ncmpcpp
      mpd
      neofetch
      brightnessctl
      inotify-tools
      # uptime
      brillo
      picom
      redshift
      wezterm
    ];

    file = {
      ".config/awesome" = {
        source = ./crystal;
        recursive = true;
      };
      ".local/bin/lock" = {
        executable = true;
        text = ''
          #!/bin/sh
          playerctl pause
          sleep 0.2
          awesome-client "awesome.emit_signal('toggle::lock')"
        '';
      };
    };
  };
}
