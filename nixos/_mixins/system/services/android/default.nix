{ pkgs, username, config, lib, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.system.services.android;
in
{
  options.system.services.android = {
    enable = mkOption {
      type = types.bool;
      default = false;
      description = "Whether enable android";
    };
  };

  config = mkIf cfg.enable {

    programs.adb.enable = true;
    services = {
      udev = {
        packages = with pkgs; [
          android-udev-rules
          adbfs-rootless
          android-file-transfer # aft-mtp-cli android-file-transfer aft-mtp-mount
          android-tools # lpadd append2simg lpmake mke2fs.android mkdtboimg simg2img lpdump lpunpack ext2simg e2fsdroid adb unpack_bootimg repack_bootimg avbtool img2simg fastboot mkbootimg lpflash
          scrcpy # Display and control Android devices over USB or TCP/IP
          waydroid # Waydroid is a container-based approach to boot a full Android system on a regular GNU/Linux system
          waydroid-ui
          # droidcam # Linux client for DroidCam app
        ];
        extraRules = ''
          # add my android device to adbusers
            SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="adbusers"
        '';
      };
    };
    virtualisation.waydroid = {
      enable = true;
    };
    users.users.${username}.extraGroups = [
      "adbusers"
    ];
    nixpkgs.config.android_sdk.accept_license = true;
  };
}
