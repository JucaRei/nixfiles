# Taken from Colemickens
# https://github.com/colemickens/nixcfg/blob/93e3d13b42e2a0a651ec3fbe26f3b98ddfdd7ab9/mixins/gfx-intel.nix
{ pkgs, lib, hostname, config, ... }: {
  config = {
    environment.systemPackages = with pkgs; [ libva-utils ];
    hardware = {
      opengl = {
        driSupport = true;
        driSupport32Bit = true;
        extraPackages =
          [ ]
          ++ lib.optionals (pkgs.system == "x86_64-linux")
            (with pkgs; [
              (
                if
                  (lib.versionOlder (lib.versions.majorMinor lib.version)
                    "23.11")
                then vaapiIntel
                else intel-vaapi-driver
              )
              intel-media-driver # LIBVA_DRIVER_NAME=iHD
              # vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
              # intel-media-driver
              nvidia-vaapi-driver
              libvdpau
              libvdpau-va-gl
              intel-compute-runtime # OpenCL filter support (hardware tonemapping and subtitle burn-in)
            ]);
        extraPackages32 = with pkgs.pkgsi686Linux; [
          # intel-media-driver
          #  vaapiIntel
          vaapiVdpau
          libvdpau-va-gl
          #  libva
        ];
      };
    };

    environment.variables = {
      VDPAU_DRIVER =
        lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
      # LIBVA_DRIVER_NAME = lib.mkDefault "iHD";
    };

    nixpkgs.config.packageOverrides = pkgs: {
      vaapiIntel = pkgs.vaapiIntel.override { enableHybridCodec = true; };
    };

    services.xserver.videoDrivers = [ "i915" ];
    boot = {
      initrd.kernelModules = [ "i915" ];
      kernelParams = [ "intel_iommu=igfx_off" ];
    };
  };
}
