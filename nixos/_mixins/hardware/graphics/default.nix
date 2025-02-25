{ config, lib, username, pkgs, isWorkstation, ... }:
let
  inherit (lib) mkIf mkOption types optionals;
  backend = config.programs.graphical.desktop.backend;
in
{
  imports = [
    ./cards/amd
    ./cards/nvidia
    ./cards/nvidia-legacy
    ./cards/intel
    ./cards/opengl

    # ./backend/wayland
    # ./backend/x11
  ];

  options.hardware.graphics.cards = {
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


  };

  config = {
    users.users.${username}.extraGroups = optionals (config.hardware.graphics.cards.enable && backend != null) [
      "render"
      "video"
    ];

    hardware = {
      graphics = mkIf (config.hardware.graphics.cards.enable && config.hardware.graphics.cards.acceleration) {
        # package = pkgs.unstable.mesa.drivers;
        enable = true;
        enable32Bit = true;
        extraPackages = (mkIf (config.hardware.graphics.cards.gpu == "hybrid-nvidia") (with pkgs.unstable;[
          vaapiIntel
          vaapiVdpau
        ]));
      };
    };

    environment = {
      systemPackages = with pkgs; mkIf (config.hardware.graphics.cards.enable && config.hardware.graphics.cards.gpu != null) [
        libva
        libva-utils
        vulkan-loader
        vulkan-tools
        vulkan-validation-layers
      ];

      shellAliases = {
        session-type = "${pkgs.elogind}/bin/loginctl show-session $(${pkgs.gawk}/bin/awk '/tty/ {print $1}' <(${pkgs.elogind}/bin/loginctl)) -p Type | ${pkgs.gawk}/bin/awk -F= '{print $2}'";
      };
    };
  };
}
