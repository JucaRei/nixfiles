{
  lib,
  pkgs,
  hostname,
  ...
}: {
  boot = {
    tmp = {
      #useTmpfs = true;
      cleanOnBoot = true;
    };
    loader = {
      efi = {
        # canTouchEfiVariables = if hostname == "air" then false else true;
        canTouchEfiVariables = true;
        efiSysMountPoint = "/boot/efi";
        # efiSysMountPoint = "/boot";
      };
      grub = {
        enable = lib.mkForce true;
        # devices = [ "nodev" ]; # "nodev" for efi only
        device = "nodev"; # "nodev" for efi only
        efiSupport = lib.mkForce true;
        # efiInstallAsRemovable = true; #  Don't depend on NVRAM state
        configurationLimit = 4;
        forceInstall = true;
        #splashMode = "stretch";
        #theme = with pkgs; [ nixos-grub2-theme libsForQt5.breeze-grub ];

        ### For encrypted boot
        # enableCryptodisk = true;

        ## If tpm is activated
        # trustedBoot.systemHasTPM = "YES_TPM_is_activated"
        # trustedBoot.enable = true;

        ## If using zfs filesystem
        # zfsSupport = true;                        # enable zfs
        # copyKernels = true;

        # useOSProber = false;
        # fsIdentifier = "provided";
        fsIdentifier = "label";
        gfxmodeEfi = "auto";
        #gfxmodeEfi = "1366x788";
        fontSize = 20;
        configurationName = "Nixos Configuration";
        extraEntries = ''
          menuentry "Reboot" {
            reboot
          }
          menuentry "Poweroff" {
            halt
          }
        '';
      };
    };
  };
}
