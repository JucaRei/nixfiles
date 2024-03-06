{
  config,
  pkgs,
  modulesPath,
  lib,
  ...
}: {
  imports = [
    "${modulesPath}/installer/sd-card/sd-image-aarch64.nix"
    ../../_mixins/services/security/sudo.nix
    # ../../_mixins/hardware/graphics/open/gpu-rpi3.nix
    # ../../_mixins/virtualization/docker.nix
  ];
  boot = {
    # Make sure not to use the latest kernel because it is not supported on NixOS RPI
    # kernelPackages = lib.mkForce pkgs.linuxPackages;
    kernelPackages = pkgs.linuxPackages_rpi3;
    # kernelPackages = pkgs.linuxPackages_latest;
    initrd = {availableKernelModules = [];};
    kernelModules = ["ahci"];

    # A bunch of boot parameters needed for optimal runtime on RPi 3b+
    kernelParams = [
      # "cma=128M"
      "cma=256M"
      # "cma=32M"
      # "console=ttyAMA0,115200"
      # "console=tty1"
    ];
    loader = {
      # NixOS wants to enable GRUB by default
      grub.enable = lib.mkForce false;
      generic-extlinux-compatible = {enable = lib.mkOverride 5 false;};
      raspberryPi = {
        enable = true;
        version = 3;
        uboot.enable = lib.mkForce true;
        firmwareConfig = ''
          gpu_mem=256
          dtparam=audio=on
          avoid_warnings=1
        '';
        # gpu_mem=128
        # hdmi_safe=1 # needed for the small portable HDMI display to work
      };
    };
  };
  environment.systemPackages = with pkgs; [
    libraspberrypi
    diskrsync
    partclone
    ntfsprogs
    ntfs3g
  ];

  # File systems configuration for using the installer's partition layout
  fileSystems = {
    "/boot" = {
      device = "/dev/disk/by-label/BOOT";
      fsType = "vfat";
      options = ["nofail" "noatime" "nodiratime"];
    };
    "/" = {
      device = lib.mkDefault "/dev/disk/by-label/NIXOS-SD";
      fsType = "ext4";
    };
  };

  swapDevices = [
    {
      device = "/swapfile";
      size = 1024;
    }
  ];

  systemd.services.btattach = {
    before = ["bluetooth.service"];
    after = ["dev-ttyAMA0.device"];
    wantedBy = ["multi-user.target"];
    serviceConfig = {
      ExecStart = "${pkgs.bluez}/bin/btattach -B /dev/ttyAMA0 -P bcm -S 3000000";
    };
  };

  # system.build.firmware = pkgs.runCommand "firmware" { } ''
  #   mkdir firmware $out

  #   ${config.sdImage.populateFirmwareCommands}

  #   cp -r firmware/* $out
  # '';

  # sdImage = lib.mkForce {
  #   populateFirmwareCommands =
  #     let
  #       configTxt = pkgs.writeText "config.txt" ''
  #         [pi3]
  #         kernel=u-boot-rpi3.bin
  #         hdmi_force_hotplug=1
  #         [pi02]
  #         kernel=u-boot-rpi3.bin
  #         [pi4]
  #         kernel=u-boot-rpi4.bin
  #         enable_gic=1
  #         armstub=armstub8-gic.bin
  #         # Otherwise the resolution will be weird in most cases, compared to
  #         # what the pi3 firmware does by default.
  #         disable_overscan=1
  #         # Supported in newer board revisions
  #         arm_boost=1
  #         [cm4]
  #         # Enable host mode on the 2711 built-in XHCI USB controller.
  #         # This line should be removed if the legacy DWC2 controller is required
  #         # (e.g. for USB device mode) or if USB support is not required.
  #         otg_mode=1
  #         [all]
  #         # Boot in 64-bit mode.
  #         arm_64bit=1
  #         # U-Boot needs this to work, regardless of whether UART is actually used or not.
  #         # Look in arch/arm/mach-bcm283x/Kconfig in the U-Boot tree to see if this is still
  #         # a requirement in the future.
  #         enable_uart=1
  #         # Prevent the firmware from smashing the framebuffer setup done by the mainline kernel
  #         # when attempting to show low-voltage or overtemperature warnings.
  #         avoid_warnings=1
  #       '';
  #     in
  #     ''
  #       (cd ${pkgs.raspberrypifw}/share/raspberrypi/boot && cp bootcode.bin fixup*.dat start*.elf $NIX_BUILD_TOP/firmware/)
  #       # Add the config
  #       cp ${configTxt} firmware/config.txt
  #       # Add pi3 specific files
  #       cp ${pkgs.ubootRaspberryPi3_64bit}/u-boot.bin firmware/u-boot-rpi3.bin
  #       # Add pi4 specific files
  #       cp ${pkgs.ubootRaspberryPi4_64bit}/u-boot.bin firmware/u-boot-rpi4.bin
  #       cp ${pkgs.raspberrypi-armstubs}/armstub8-gic.bin firmware/armstub8-gic.bin
  #       cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-4-b.dtb firmware/
  #       cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-400.dtb firmware/
  #       cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4.dtb firmware/
  #       cp ${pkgs.raspberrypifw}/share/raspberrypi/boot/bcm2711-rpi-cm4s.dtb firmware/
  #     '';
  #   populateRootCommands = ''
  #     mkdir -p ./files/boot
  #     ${config.boot.loader.generic-extlinux-compatible.populateCmd} -c ${config.system.build.toplevel} -d ./files/boot
  #   '';
  # };

  # Configure basic SSH access
  services.openssh.enable = true;
  # services.openssh.permitRootLogin = "yes";

  # Use 1GB of additional swap memory in order to not run out of memory
  # when installing lots of things while running other things at the same time.
  # swapDevices = [{
  #   device = "/swapfile";
  #   size = 2048;
  # }];

  # zramSwap = {
  #   enable = true;
  #   swapDevices = 5;
  #   memoryPercent = 40; # 20% of total memory
  #   algorithm = "lz4";
  # };

  hardware = {
    pulseaudio.enable = true;
    enableRedistributableFirmware = true;
  };

  sound.enable = true;

  services.journald.extraConfig = lib.mkForce ''
    Storage = volatile
    RuntimeMaxFileSize = 10M;
  '';

  ## Enable X11 windowing system
  # services.xserver.enable = true;
  # services.xserver.videoDrivers = [ "modesetting" ];
  ## Enable Kodi
  # services.xserver.desktopManager.kodi.enable = true;
  ## Enable slim autologin
  # services.xserver.displayManager.lightdm.enable = true;
  # services.xserver.displayManager.lightdm.autoLogin.enable = true;
  # services.xserver.displayManager.lightdm.autoLogin.user = "kodi";

  nixpkgs = {
    # localSystem.system = "aarch64-linux";
    buildPlatform.system = "x86_64-linux";
    hostPlatform = lib.mkForce "aarch64-linux";
  };
}
