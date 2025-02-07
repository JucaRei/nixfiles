{ config, lib, username, pkgs, isWorkstation, ... }:
let
  inherit (lib) mkIf mkOption types optionals;
in
{
  imports = [
    ./cards/amd
    ./cards/nvidia
    ./cards/nvidia-legacy
    ./cards/intel
    ./cards/opengl

    ./backend/wayland
    ./backend/x11
  ];

  options.features.graphics = {
    enable = mkOption {
      type = types.bool;
      default = isWorkstation;
      description = "Enable graphics for selected device.";
    };

    acceleration = mkOption {
      default = false;
      type = with types; bool;
      description = "Enables graphics acceleration";
    };

    gpu = mkOption {
      type = types.enum [
        "amd"
        "intel"
        "nvidia"
        "nvidia-legacy"
        "hybrid-nvidia"
        "hybrid-amd"
        "integrated-amd"
        "pi"
        "mali-gpu"
        null
      ];
      default = null;
      description = "Manufacturer/type of the primary system GPU";
    };

    backend = mkOption {
      type = types.enum [ "x11" "wayland" null ];
      default = null;
      description = "Default backend for the system";
    };
  };

  config = {
    users.users.${username}.extraGroups = optionals (config.features.graphics.enable && config.features.graphics.backend != null) [
      "render"
      "video"
    ];

    hardware = {
      graphics = mkIf (config.features.graphics.enable && config.features.graphics.acceleration) {
        # package = pkgs.unstable.mesa.drivers;
        enable = true;
        enable32Bit = true;
        extraPackages = (mkIf (config.features.graphics.gpu == "hybrid-nvidia") (with pkgs.unstable;[
          vaapiIntel
          vaapiVdpau
        ]));
      };
    };

    environment = {
      systemPackages = with pkgs; mkIf (config.features.graphics.enable && config.features.graphics.gpu != null) [
        libva
        libva-utils
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
      ];
    };
  };
}
