{ config, lib, ... }:
let
  inherit (lib) mkOption bool;
  inherit (lib.types) nullOr enum;
in
{
  imports = [
    ./alacritty
    # ./kitty
    # ./foot
    # ./wezterm
    # ./xfce4-terminal
  ];

  options = {
    system.programs.terminal = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable terminal emulator configuration.";
      };
      name = mkOption {
        type = nullOr (enum [ "alacritty" "kitty" "foot" "wezterm" "xfce4-terminal" ]);
        default = null;
        description = "The selected terminal emulator for your desktop environment.";
      };
    };
  };
}
