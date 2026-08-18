{ inputs, lib, config, pkgs, hostname, platform, modulesPath, isInstall, isISO ? false, username, isWorkstation, ... }:
let
  inherit (lib) mkIf mkDefault optionals;
in
{
  imports = [
    (if isISO then ./hosts/iso/default.nix else ./. + "/hosts/${hostname}/default.nix")
    ./users
    ../modules/nixos
    (modulesPath + "/installer/scan/not-detected.nix")
  ]
  ++ [
    inputs.nur.modules.nixos.default
    inputs.disko.nixosModules.disko
    inputs.nixos-hardware.nixosModules.common-pc-ssd
    inputs.nixos-hardware.nixosModules.common-pc
    inputs.auto-cpufreq.nixosModules.default
    inputs.catppuccin.nixosModules.catppuccin
    inputs.nix-flatpak.nixosModules.nix-flatpak
    inputs.nix-index-database.nixosModules.nix-index
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  # Main configuration for the NixOS base profile
  config = {
    # --- Localization & Language ---
    i18n = {
      defaultLocale = mkDefault "en_US.UTF-8";
      extraLocaleSettings = {
        LANG = "en_US.UTF-8";
        LC_CTYPE = "pt_BR.UTF-8"; # Fix ç in us-intl
        LC_ADDRESS = "pt_BR.UTF-8";
        LC_IDENTIFICATION = "en_US.UTF-8";
        LC_MEASUREMENT = "pt_BR.UTF-8";
        LC_MONETARY = "pt_BR.UTF-8";
        LC_NAME = "pt_BR.UTF-8";
        LC_NUMERIC = "pt_BR.UTF-8";
        LC_PAPER = "pt_BR.UTF-8";
        LC_TELEPHONE = "pt_BR.UTF-8";
        LC_TIME = "pt_BR.UTF-8";
      };
    };

    # --- Documentation (optimized for speed and disk space) ---
    documentation = {
      enable = true;
      man = {
        enable = true;
        man-db.enable = true;
      };
      info.enable = false;
      doc.enable = false;
      dev.enable = false;
      nixos.enable = false;
    };

    # --- System Defaults ---
    system = {
      boot = mkDefault {
        bootType = "efi";
        bootManager = "grub";
        plymouth = isWorkstation;
        silentBoot = isWorkstation;
      };
      security = mkDefault {
        superuser.enable = true;
        pam.enable = isInstall;
      };
    };

    # --- Boot & Virtualization helpers ---
    boot = {
      zfs.forceImportRoot = mkDefault false;
      binfmt = mkIf isInstall {
        emulatedSystems = mkIf (isWorkstation && (config.nixos.services.virt-manager.enable or false)) (
          [ "armv5tel-linux" ]
          ++ optionals (platform == "x86_64-linux") [ "aarch64-linux" ]
          ++ optionals (platform == "aarch64-linux") [ "x86_64-linux" ]
        );
      };
      kernelModules = mkIf (config.nixos.services.virt-manager.enable or false) [ "vhost_vsock" ];
    };

    # --- Environment & Packages ---
    environment = {
      defaultPackages = with pkgs; [ parted uutils-coreutils-noprefix ];
      systemPackages = with pkgs; [ nix-output-monitor ]
        ++ optionals (isInstall && inputs ? determinate) [
        inputs.determinate.packages.${pkgs.stdenv.hostPlatform.system}.default
      ];
      shellAliases = {
        nix_package_size = "nix path-info --size --human-readable --recursive /run/current-system | cut -d - -f 2- | sort";
        store-path = "${pkgs.uutils-coreutils-noprefix}/bin/readlink (${pkgs.which}/bin/which $argv)";
        keyring-lock = ''${pkgs.systemdMinimal}/bin/busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked'';
      };

      etc."nixos-current-system-packages".text =
        let
          packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
          sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
        in
        builtins.concatStringsSep "\n" sortedUnique;
    };

    # --- Programs & CLI Tools ---
    programs = {
      command-not-found.enable = false;
      zsh.enable = mkDefault true;

      nh = {
        enable = true;
        flake = "/home/${username}/.dotfiles/nixfiles";
        clean = {
          enable = isInstall;
          extraArgs = "--keep-since 15d --keep 10";
        };
      };
    };

    # --- Core System Services ---
    services = {
      fprintd.enable = mkDefault false;
      dbus = {
        enable = true;
        implementation = if isWorkstation then "broker" else "dbus";
      };
    };

    # --- Systemd Tuning & Filesystem Structure ---
    systemd = {
      settings.Manager = {
        DefaultTimeoutStopSec = "10s";
        DefaultCPUAccounting = true;
        DefaultMemoryAccounting = true;
        DefaultIOAccounting = true;
      };
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
      ];
    };
  };
}
