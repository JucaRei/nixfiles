{ config, inputs, lib, isWorkstation, modulesPath, pkgs, ... }:
with lib;
{
  imports = [
    ../../system

    inputs.auto-cpufreq.nixosModules.default
    inputs.catppuccin.nixosModules.catppuccin
    #inputs.determinate.nixosModules.default
    inputs.disko.nixosModules.disko
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nix-index-database.nixosModules.nix-index
    inputs.nix-snapd.nixosModules.default
    inputs.sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
  ] ++ lib.optional isWorkstation ./_mixins/desktop;

  boot = mkDefault {
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
    };
    kernelModules = [ "vhost_vsock" ];
    kernelParams = [ "udev.log_priority=3" ];
    kernelPackages = pkgs.linuxPackages_latest;
    # Only enable the systemd-boot on installs, not live media (.ISO images)
    # loader = lib.mkIf isInstall {
    #   efi.canTouchEfiVariables = true;
    #   systemd-boot.configurationLimit = 10;
    #   systemd-boot.consoleMode = "max";
    #   systemd-boot.enable = true;
    #   systemd-boot.memtest86.enable = true;
    #   timeout = 10;
    # };
  };

  # Only install the docs I use
  documentation = {
    enable = true;
    nixos.enable = false;
    man.enable = true;
    info.enable = false;
    doc.enable = false;
  };

  environment = {
    # Eject nano and perl from the system
    defaultPackages =
      with pkgs;
      lib.mkForce [
        coreutils-full
        micro
      ];

    systemPackages =
      with pkgs;
      [
        git
        nix-output-monitor
      ]
      ++ lib.optionals isInstall [
        inputs.nixos-needtoreboot.packages.${platform}.default
        nvd
        nvme-cli
        smartmontools
        sops
      ];

    variables = mkDefault {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };
  };
}
