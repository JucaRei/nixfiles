{ inputs, outputs, lib, config, pkgs, hostname, platform, modulesPath, isInstall, username, isWorkstation, ... }:
let
  inherit (lib) mkIf optional optionals mkDefault mkOptionDefault;
in
{
  imports = [
    (./. + "/hosts/${hostname}/default.nix")
    ./users
    ../modules/nixos
    (modulesPath + "/installer/scan/not-detected.nix")
  ]
  ++ (with inputs; [
    nur.modules.nixos.default
    nixosModules.disko
    nixos-hardware.nixosModules.common-pc-ssd
    nixos-hardware.nixosModules.common-pc
    auto-cpufreq.nixosModules.default
    catppuccin.nixosModules.catppuccin
    nix-flatpak.nixosModules.nix-flatpak
    nix-index-database.nixosModules.nix-index
    chaotic.nixosModules.default
    sops-nix.nixosModules.sops
  ]
  ++ optional (lib.hasAttr "nixosModules" inputs.nixpkgs) inputs.nixpkgs.nixosModules.default);

  # This is the main configuration for your NixOS system.
  config = {
    documentation = mkDefault {
      enable = true;
      man = {
        enable = true;
        man-db = {
          enable = true;
        };
      };
      info.enable = false;
      doc.enable = false;
      dev.enable = false;
      nixos.enable = false;
    };

    boot = {
      binfmt = mkIf isInstall {
        emulatedSystems = mkIf isWorkstation [
          "armv5tel-linux"
          # "armv6l-linux"
          # "armv7l-linux"
          # "i686-linux"
        ]
        ++ optionals (platform == "x86_64-linux") [ "aarch64-linux" ]
        ++ optionals (platform == "aarch64-linux") [ "x86_64-linux" ];
      };
      kernelModules = [ "vhost_vsock" ];
    };

    environment = {
      systemPackages = with pkgs; [
        inputs.determinate.packages.${pkgs.system}.default
        uutils-coreutils-noprefix
        parted
        nix-output-monitor

        (pkgs.writeShellScriptBin "nixos-rebuild-half" ''
          #!/usr/bin/env bash
          set -euo pipefail

          # Compute half the logical cores (minimum 1)
          cores=$(nproc --all || echo 1)
          half_cores=$(expr $cores / 2)
          max_jobs=''${half_cores:-1}

          # Call the original nixos-rebuild with dynamic max-jobs
          exec nixos-rebuild --max-jobs "$max_jobs" "$@"
        '')
      ];
      shellAliases = {
        # update-dotfiles = "git -C $HOME/.dotfiles pull && nix flake update $HOME/.dotfiles/nixfiles && nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles";
        nix_package_size = "nix path-info --size --human-readable --recursive /run/current-system | cut -d - -f 2- | sort";
        store-path = "${pkgs.uutils-coreutils-noprefix}/bin/readlink (${pkgs.which}/bin/which $argv)";
      };
    };

    programs = {
      command-not-found.enable = false;
      nh = {
        clean = {
          enable = isInstall;
          extraArgs = "--keep-since 15d --keep 10";
        };
        enable = true;
        flake = "/home/${username}/.dotfiles/nixfiles";
      };
      nix-ld = mkIf isInstall {
        enable = true;
        libraries = with pkgs; [
          # Add any missing dynamic libraries for unpackaged
          # programs here, NOT in environment.systemPackages
        ];
      };
    };

    services = {
      system76-sheduler = {
        enable = mkIf isWorkstation true;
        assignments = {
          nix-builds = {
            nice = 10; # from -20 (high) to 19 (low)
            class = "batch"; # "idle", "batch", "other", "rr", "fifo"
            ioClass = "idle"; # "idle", "best-effort", "realtime"
            matchers = [
              "nix-daemon"
            ];
          };
        };
      };
      dbus = {
        enable = true;
        implementation = if isWorkstation then "broker" else "systemd";
      };
    };

    # Only enable sudo-rs on installs, not live media (.ISO images)
    security = lib.mkIf isInstall {
      polkit.enable = true;
      sudo.enable = false;
      sudo-rs = {
        enable = lib.mkDefault true;
      };
    };

    # Create symlink to /bin/bash
    # - https://github.com/lima-vm/lima/issues/2110
    systemd = {
      extraConfig = "DefaultTimeoutStopSec=10s";
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
        "d /var/lib/private/sops/age 0755 root root"
      ];
    };

    networking.hostName = "your-hostname";

    # TODO: Configure your system-wide user settings (groups, etc), add more users as needed.
    users.users = {
      # FIXME: Replace with your username
      your-username = {
        # TODO: You can set an initial password for your user.
        # If you do, you can skip setting a root password by passing '--no-root-passwd' to nixos-install.
        # Be sure to change it (using passwd) after rebooting!
        initialPassword = "correcthorsebatterystaple";
        isNormalUser = true;
        openssh.authorizedKeys.keys = [
          # TODO: Add your SSH public key(s) here, if you plan on using SSH to connect
        ];
        # TODO: Be sure to add any other groups you need (such as networkmanager, audio, docker, etc)
        extraGroups = [ "wheel" ];
      };
    };

    # This setups a SSH server. Very important if you're setting up a headless system.
    # Feel free to remove if you don't need it.
    services.openssh = {
      enable = true;
      settings = {
        # Opinionated: forbid root login through SSH.
        PermitRootLogin = "no";
        # Opinionated: use keys only.
        # Remove if you want to SSH using passwords
        PasswordAuthentication = false;
      };
    };
  };
}
