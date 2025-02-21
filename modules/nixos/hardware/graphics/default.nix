{ options, config, lib, pkgs, namespace, ... }:
with lib;
with (lib.${namespace});
let
  user = config.${namespace}.user.name;
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

  options.${namespace}.hardware.graphics = {
    enable = mkOption {
      type = types.bool;
      default = false;
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
    users.users.${user}.extraGroups = optionals (config.${namespace}.hardware.graphics && config.${namespace}.hardware.graphics.backend != null) [
      "render"
      "video"
    ];

    hardware = {
      graphics = mkIf (config.${namespace}.hardware.graphics.enable && config.${namespace}.hardware.graphics.acceleration) {
        # package = pkgs.unstable.mesa.drivers;
        enable = true;
        enable32Bit = true;
        extraPackages = (mkIf (config.${namespace}.hardware.graphics.gpu == "hybrid-nvidia") (with pkgs.unstable;[
          vaapiIntel
          vaapiVdpau
        ]));
      };
    };

    environment = {
      systemPackages = with pkgs; mkIf (config.${namespace}.hardware.graphics.enable && config.${namespace}.hardware.graphics.gpu != null) [
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
