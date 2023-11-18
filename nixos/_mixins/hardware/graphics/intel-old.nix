# Taken from Colemickens
# https://github.com/colemickens/nixcfg/blob/93e3d13b42e2a0a651ec3fbe26f3b98ddfdd7ab9/mixins/gfx-intel.nix
{ pkgs, config, lib, ... }: {

  config = {
    boot.kernelParams = [ "intel_iommu=igfx_off" ];
    hardware = {
      opengl = {
        driSupport = true;
        driSupport32Bit = true;
        extraPackages = with pkgs; [
          #intel-media-driver # LIBVA_DRIVER_NAME=iHD
          vaapiIntel # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
          vaapiVdpau
          libvdpau-va-gl
        ];
        #driSupport32Bit = true;
        #extraPackages32 = with pkgs.pkgsi686Linux;
        # [
        #  intel-media-driver
        #    vaapiIntel
        #  vaapiVdpau
        #  libvdpau-va-gl
        #  libva
        # ];
      };
      enableRedistributableFirmware = true;
    };



    # services.hardware.bolt.enable = true;
    # # Allow usb controllers via HDMI
    # services.udev.extraRules = ''KERNEL=="hidraw*", ATTRS{idVendor}=="20d6", ATTRS{idProduct}=="a711", MODE="0660", TAG+="uaccess"'';


    services.xserver.videoDrivers = [ "intel" "i965" ];
    # services.xserver.videoDrivers = [ "intel" ];

    ### INTEL FIX SCREEN TEARING ###
    environment = {

      systemPackages = with pkgs; [ libva-utils ];

      etc."X11/xorg.conf.d/20-intel.conf" = {
        text = ''
          Section         "Device"
            Identifier    "Intel Graphics"
            Option        "intel"
            Option        "TearFree"          "true"
            Option        "AccelMethod"       "sna"
            Option        "SwapbuffersWait"   "true"
            Option        "TripleBuffer"      "true"
            Option        "VariableRefresh"   "true"
            Option        "DRI"               "2"
            # Option        "DRI"               "3"
          EndSection
        '';
      };

      variables = {
        VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
      };

      sessionVariables = {
        LIBVA_DRIVER_NAME = "i965";
      };
    };

  };
}
