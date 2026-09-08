{ config, lib, ... }:
let
  inherit (lib) mkIf mkForce;
in
{
  config = {
    desktop = {
      display-servers.backend = "wayland";
      display-managers.name = "regreet";
    };

    environment = {
      pathsToLink = [
        "share/thumbnailers" # Enable HEIC image previews in Nautilus
      ];
      homeBinInPath = true;
      sessionVariables = {
        # Make sure the cursor size is the same in all environments
        HYPRCURSOR_SIZE = 24;
        # HYPRCURSOR_THEME = "catppuccin-mocha-blue-cursors";
        NIXOS_OZONE_WL = 1;
        QT_WAYLAND_DISABLE_WINDOWDECORATION = 1;
        DISPLAY = ":0";
      };
    };

    programs = {
      hyprland = {
        enable = true;
      };
    };

    nix = {
      settings = {
        substituters = [ "https://hyprland.cachix.org" ];
        trusted-substituters = [ "https://hyprland.cachix.org" ];
        trusted-public-keys = [ "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc=" ];
      };
    };
  };
}
