{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      kitty # terminal
      mako # notification daemon
      libsForQt5.polkit-kde-agent # polkit agent
    ];
  };
  wayland = {
    windowManager = {
      hyprland = {
        enable = true;
        enableNvidiaPatches = true;
        package = pkgs.hyprland;
        # extraConfig = '''';
        # finalPackage = '''';
        # plugins = [];
        # settings = {};
        systemd = {
          enable = true;
          # extraCommands = "";
          # variable = [];
        };
        xwayland.enable = true;
      };
    };
  };
}
