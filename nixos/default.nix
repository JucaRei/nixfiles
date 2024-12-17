{ config, hostname, isInstall, isWorkstation, inputs, lib, modulesPath, outputs, pkgs, platform, stateVersion, username, ... }:
let
  inherit (lib) mkIf mkForce mkDefault optional optionals getExe';
in
{
  imports = with inputs; [
    auto-cpufreq.nixosModules.default
    catppuccin.nixosModules.catppuccin
    determinate.nixosModules.default
    disko.nixosModules.disko
    nix-flatpak.nixosModules.nix-flatpak
    nix-index-database.nixosModules.nix-index
    nix-snapd.nixosModules.default
    sops-nix.nixosModules.sops
    (modulesPath + "/installer/scan/not-detected.nix")
    (./. + "/hosts/${ hostname}")
    ./users
    ./_mixins/core
    ./_mixins/features
    ./_mixins/services
  ] ++ optional isWorkstation ./_mixins/desktop;

  config = {
    ######################
    ### Custom Modules ###
    ######################
    core = {
      # Default boot Options
      boot = {
        enable = mkDefault isInstall;
        boottype = mkDefault "efi";
        bootmanager = mkDefault "grub";
        isDualBoot = mkDefault false;
        secureBoot = mkDefault false;
        silentBoot = mkDefault isWorkstation;
        plymouth = mkDefault isWorkstation;
      };

      cpu = {
        enable = mkDefault true;
        hardenKernel = mkDefault false;
        improveTCP = mkDefault (isInstall || isWorkstation);
        enableKvm = mkDefault false;
        cpuVendor = mkDefault "intel";
      };

      optimizations.enable = true;

      # Selected default docs
      documentation = {
        enable = mkDefault true;
        doctypes = [ "man" ];
      };

      security = {
        enable = mkDefault true;
        superUser = "sudo";
      };

      network = {
        enable = true;
        networkOpt = mkDefault "network-manager";
        exclusive-locallan = mkDefault false;
        powersave = mkDefault false;
        wakeonlan = mkDefault false;
        # custom-interface = "eth0";
      };
    };

    environment = {
      # Eject nano and perl from the system
      defaultPackages =
        with pkgs; mkForce [
          coreutils-full
          parted
          micro
        ];

      shellAliases = {
        store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
        keyring-lock = ''${pkgs.systemdMinimal}/bin/busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked'';
      };

      systemPackages = with pkgs; [
        git
        nix-output-monitor
      ]
      ++ optionals isInstall [
        inputs.determinate.packages.${platform}.default
        inputs.fh.packages.${platform}.default
        inputs.nixos-needsreboot.packages.${platform}.default
        nvd
        nvme-cli
        smartmontools
        sops
      ];

      variables = {
        EDITOR = "micro";
        SYSTEMD_EDITOR = "micro";
        VISUAL = "micro";
      };
    };

    nixpkgs = {
      # You can add overlays here
      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        # Add overlays exported from other flakes:

        # Add overlays exported from other flakes:
        # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
        (_: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];

      # Configure your nixpkgs instance
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
        permittedInsecurePackages = [ "tightvnc-1.3.10" ];
        # allowInsecure = true
      };
    };

    nix =
      let
        flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
      in
      {
        # give nix-daemon the lowest priority
        daemonIOSchedClass = "idle"; # Reduce disk usage
        # Leave nix builds as a background task
        daemonCPUSchedPolicy = "idle"; # Set CPU scheduling policy for daemon processes to idle
        daemonIOSchedPriority = 7; # Set I/O scheduling priority for daemon processes to 7

        settings = {
          accept-flake-config = true;
          experimental-features = [
            "flakes"
            "nix-command"
            # "repl-flake" # repl to inspect a flake
            # "recursive-nix" # let nix invoke itself
            # "ca-derivations" # content addressed nix
            # "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
            # "cgroups" # allow nix to execute builds inside cgroups
          ];
          # auto-allocate-uids = true;
          # allowed-users = users;
          # builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.
          # use-cgroups = true; # execute builds inside cgroups
          system-features = [
            #   # Allows building v3/v4 packages
            "gccarch-x86-64-v3"
            "gccarch-x86-64-v4"
            #   "kvm"
            #   "recursive-nix"
            #   "big-parallel"
            #   "nixos-test"
          ];
          ### Avoid unwanted garbage collection when using nix-direnv
          # keep-outputs = true;
          # keep-derivations = true;
          keep-going = false;
          warn-dirty = false;
          tarball-ttl = 300; # Set the time-to-live (in seconds) for cached tarballs to 300 seconds (5 minutes)
          # Disable global registry
          flake-registry = "";
          # Workaround for https://github.com/NixOS/nix/issues/9574
          nix-path = config.nix.nixPath;
          trusted-users = [ "root" "${username}" ];
        };
        extraOptions = ''
          log-lines = 15
          # Free up to 4GiB whenever there is less than 2GiB left.
          min-free = ${toString (2048 * 1024 * 1024)}
          max-free = ${toString (4096 * 1024 * 1024)} # 4GiB
          connect-timeout = 10
        '';
        # Disable channels
        channel.enable = false;
        # Make flake registry and nix path match flake inputs
        registry = lib.mapAttrs (_: flake: { inherit flake; }) flakeInputs;
        nixPath = lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs;
      };

    nixpkgs.hostPlatform = mkDefault "${platform}";

    programs = {
      command-not-found.enable = false;
      fish = {
        enable = true;
        shellAliases = {
          nano = "micro";
        };
      };
      nano = import ../resources/nixos/scripts/nano.nix { inherit pkgs config lib; };
      nh = {
        clean = {
          enable = true;
          extraArgs = "--keep-since 7d --keep 10";
        };
        enable = true;
        flake = "/home/${username}/.dotfiles/nixfiles";
      };
      nix-index-database.comma.enable = isInstall;
      nix-ld = mkIf isInstall {
        enable = true;
        libraries = with pkgs; [
          # Add any missing dynamic libraries for unpackaged
          # programs here, NOT in environment.systemPackages
        ];
      };
    };

    services = {
      hardware.bolt.enable = true;

      dbus = {
        packages = optionals (isWorkstation) (with pkgs ; [ gnome-keyring gcr ]);
        implementation = if isWorkstation then "broker" else "dbus";
      };

      chrony = {
        # if time is wrong:
        # 1/ systemctl stop chronyd.service
        # 2/ "sudo chronyd -q 'pool pool.ntp.org iburst'"
        enable = true;

        # to correct big errors on startup
        initstepslew = {
          enabled = true;
          threshold = 100;
        };

        # we allow chrony to make big changes at
        # see https://chrony.tuxfamily.org/faq.html#_is_chronyd_allowed_to_step_the_system_clock
        extraConfig = ''
          makestep 1 -1
        '';
        servers = [
          "time.cloudflare.com"
          "time.google.com"
          "0.pool.ntp.org"
          "1.pool.ntp.org"
          "2.pool.ntp.org"
          "3.pool.ntp.org"
        ];
      };
    };

    sops = lib.mkIf (isInstall && username == "teste") {
      age = {
        keyFile = "/home/${username}/.config/sops/age/keys.txt";
        generateKey = false;
      };
      defaultSopsFile = ../secrets/secrets.yaml;
      # sops-nix options: https://dl.thalheim.io/
      secrets = {
        test-key = { };
      };
    };

    systemd = {
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash" # Create symlink to /bin/bash
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
        "d /var/lib/private/sops/age 0755 root root"
      ];

      user.extraConfig = ''
        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';

      extraConfig = ''
        DefaultTimeoutStartSec=8s
        DefaultTimeoutStopSec=10s
        DefaultDeviceTimeoutSec=8s
        DefaultTimeoutAbortSec=10s

        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';

      services = {
        "user@".serviceConfig.Delegate = true;

        nix-gc = {
          unitConfig.ConditionACPower = true; ### Nix gc when powered
        };

        nix-daemon.serviceConfig = {
          CPUWeight = 20;
          IOWeight = 20;
        };

        NetworkManager-wait-online.enable = mkForce false;
        systemd-udev-settle.enable = mkForce false;
      };

      targets = mkIf (hostname == "soyo") {
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };
    };

    system = {
      nixos.label = lib.mkIf isInstall "nixsystem";
      inherit stateVersion;

      activationScripts = {
        report-changes = ''
          PATH=$PATH:${lib.makeBinPath [pkgs.nvd pkgs.nix]}
          nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2)
          mkdir -p /var/log/activations
          _nvddate=$(date +'%Y%m%d%H%M%S')
          nvd diff $(ls -dv /nix/var/nix/profiles/system-*-link | tail -2) > /var/log/activations/$_nvddate-$(ls -dv /nix/var/nix/profiles/system-*-link | tail -1 | cut -d '-' -f 2)-$(readlink $(ls -dv /nix/var/nix/profiles/system-*-link | tail -1) | cut -d - -f 4-).log
          if grep -q "No version or selection state changes" "/var/log/activations/$_nvddate-$(ls -dv /nix/var/nix/profiles/system-*-link | tail -1 | cut -d '-' -f 2)-$(readlink $(ls -dv /nix/var/nix/profiles/system-*-link | tail -1) | cut -d - -f 4-).log" ; then
            rm -rf "/var/log/activations/$_nvddate-$(ls -dv /nix/var/nix/profiles/system-*-link | tail -1 | cut -d '-' -f 2)-$(readlink $(ls -dv /nix/var/nix/profiles/system-*-link | tail -1) | cut -d - -f 4-).log"
          fi
        '';

        nixos-needsreboot = mkIf (isInstall) {
          supportsDryActivation = true;
          text = "${lib.getExe inputs.nixos-needsreboot.packages.${pkgs.system}.default} \"$systemConfig\" || true";
        };
      };
    };
  };
}
