{
  config,
  lib,
  username,
  pkgs,
  isWorkstation,
  ...
}:
let
  inherit (lib)
    mkIf
    optionals
    ;
  backend = config.desktop.display-servers.backend or null;
in
{
  imports = [
    ./cards/amd
    ./cards/nvidia
    ./cards/nvidia-legacy
    ./cards/intel
  ];

  options.hardware.graphics.cards = {
    enable = lib.my.mkBool isWorkstation "Enable graphics for selected device.";

    acceleration = lib.my.mkBool false "Enables graphics acceleration";

    gpu = lib.my.mkOpt (lib.types.nullOr (
      lib.types.enum [
        "amd"
        "intel"
        "nvidia"
        "nvidia-legacy"
        "hybrid-nvidia"
        "hybrid-amd"
        "integrated-amd"
        # "pi"
        # "mali-gpu"
      ]
    )) null "Manufacturer/type of the primary system GPU";
  };

  config = {
    users.users.${username}.extraGroups =
      optionals (config.hardware.graphics.cards.enable && backend != null)
        [
          "render"
          "video"
        ];
    hardware = {
      graphics =
        mkIf (config.hardware.graphics.cards.enable && config.hardware.graphics.cards.acceleration)
          {
            # package = pkgs.unstable.mesa.drivers;
            enable = true;
            enable32Bit = true;
            extraPackages = optionals (config.hardware.graphics.cards.gpu == "hybrid-nvidia") (
              with pkgs.unstable;
              [
                intel-vaapi-driver
                libva-vdpau-driver
              ]
            );
          };
    };

    environment = {
      systemPackages =
        with pkgs;
        mkIf (config.hardware.graphics.cards.enable && config.hardware.graphics.cards.gpu != null) [
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
