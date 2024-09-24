{ pkgs, username, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.features.bluetooth;
in
{
  options.features.android = {
    enable = mkEnableOption "Whether enable android";
    default = false;
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
          droidcam # Linux client for DroidCam app
          waydroid # Waydroid is a container-based approach to boot a full Android system on a regular GNU/Linux system
        ];
        extraRules = ''
          # add my android device to adbusers
            SUBSYSTEM=="usb", ATTR{idVendor}=="04e8", MODE="0666", GROUP="adbusers"
        '';
      };
    };
    users.users.${username}.extraGroups = [
      "adbusers"
    ];
    nixpkgs.config.android_sdk.accept_license = true;
  };
}
