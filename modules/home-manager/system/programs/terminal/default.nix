{ config, lib, ... }: {
  imports = [
    ./alacritty
    ./kitty
    ./foot
    ./wezterm
    ./xfce4-terminal
  ];

  options = {
    system.programs.terminal = {
      enable = lib.mkOption {
        type = lib.bool;
        default = false;
        description = "Enable terminal emulator configuration.";
      };
      name = lib.mkOption {
        type = lib.nullOr (lib.enum [ "alacritty" "kitty" "foot" "wezterm" "xfce4-terminal" ]);
        default = null;
        description = "The selected terminal emulator for your desktop environment.";
      };
    };
  };
}
