{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf;
  cfg = config.features.graphics;
  acceleration = config.features.graphics.acceleration;
  gpu = cfg.gpu;
in
{
  config = mkIf cfg.enable {
    nixpkgs.config.packageOverrides = (mkIf
      (gpu == "hybrid-nvidia")
      (pkgs: {
        vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
      })
    );

    hardware = {
      graphics = mkIf (cfg.enable && (acceleration == true)) {
        # package = pkgs.unstable.mesa.drivers;
        enable = true;
        enable32Bit = true;
        extraPackages =
          if (gpu == "intel" || gpu == "hybrid-nvidia") then
            with pkgs.unstable; [
              intel-compute-runtime
              intel-media-driver
              libvdpau-va-gl
              vaapiIntel
              vaapiVdpau
            ] else with pkgs.unstable; [
            mesa.drivers
          ];
      };
    };
  };
}
