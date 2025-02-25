{ config, hostname, isInstall, isWorkstation, inputs, lib, modulesPath, outputs, pkgs, platform, stateVersion, username, ... }:
let
  inherit (lib) mkIf mkForce mkOverride mkDefault mkOptionDefault optional optionals;
in
{
  imports = with inputs; [
    nur.modules.nixos.default
    auto-cpufreq.nixosModules.default
    catppuccin.nixosModules.catppuccin
    disko.nixosModules.disko
    nix-flatpak.nixosModules.nix-flatpak
    nix-index-database.nixosModules.nix-index
    nix-snapd.nixosModules.default
    chaotic.nixosModules.default
    sops-nix.nixosModules.sops
    nixos-hardware.nixosModules.common-pc
    nixos-hardware.nixosModules.common-pc-ssd
    (modulesPath + "/installer/scan/not-detected.nix")
    (./. + "/hosts/${hostname}")
    ./users
    ../modules/nixos/system
    ../modules/nixos/hardware
  ] ++ optional isWorkstation ../modules/nixos/programs/graphical/desktop/environment;

  config = {

    ######################
    ### Custom Modules ###
    ######################

    system = {
      boot = {
        enable = mkDefault isInstall;
        boottype = mkDefault "efi";
        bootmanager = mkDefault "grub";
        isDualBoot = mkOptionDefault false;
        secureBoot = mkOptionDefault false;
        silentBoot = mkOptionDefault isWorkstation;
        plymouth = mkOptionDefault isWorkstation;
      };

      console.enable = true;
      locales.enable = true;

      security = {
        superuser = {
          enable = mkDefault true;
          manager = mkDefault "sudo";
        };
      };

      docs = {
        enable = mkDefault true;
        doctypes = [ "man" ];
      };

      services = {
        ssh.enable = true;
      };
    };

    hardware = {
      cpu = {
        enable = mkOverride 990 true;
        hardenKernel = mkOptionDefault false;
        improveTCP = mkDefault (isInstall || isWorkstation);
        enableKvm = mkOptionDefault false;
        cpuVendor = mkDefault "intel";
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
      defaultPackages = with pkgs; mkForce [
        uutils-coreutils-noprefix
        parted
        micro
      ];

      shellAliases = {
        nix_package_size = "nix path-info --size --human-readable --recursive /run/current-system | cut -d - -f 2- | sort";
        store-path = "${pkgs.uutils-coreutils-noprefix}/bin/readlink (${pkgs.which}/bin/which $argv)";
        keyring-lock = "${pkgs.systemdMinimal}/bin/busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked";
      };

      systemPackages = with pkgs; [
        git
        nix-output-monitor
      ]
      ++ optionals isInstall [
        nvd
        cachix
        sops
      ];

      variables = {
        EDITOR = "micro";
        SYSTEMD_EDITOR = "micro";
        VISUAL = "micro";
      };

      ## Create a file in /etc/nixos-current-system-packages  Listing all Packages ###
      etc = {
        "nixos-current-system-packages" = {
          text =
            let
              packages = builtins.map (p: "${p.name}") config.environment.systemPackages;
              sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
              formatted = builtins.concatStringsSep "\n" sortedUnique;
            in
            formatted;
        };
      };
    };

    nixpkgs = {
      # You can add overlays here
      overlays = [
        # Add overlays your own flake exports (from overlays and pkgs dir):
        outputs.overlays.additions
        outputs.overlays.modifications
        outputs.overlays.unstable-packages
        outputs.overlays.oldstable-packages
        # Add overlays exported from other flakes:

        # Add overlays exported from other flakes:
        # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
        (_: super: {
          makeModulesClosure = x:
            super.makeModulesClosure (x // { allowMissing = true; });
        })
      ];

      hostPlatform = mkDefault "${platform}";
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
          extra-sandbox-paths = [ "/bin/sh=${pkgs.bash}/bin/sh" ];
          experimental-features = [
            "flakes" # flakes
            "nix-command" # experimental nix commands
            # "repl-flake" # repl to inspect a flake
            # "recursive-nix" # let nix invoke itself
            # "ca-derivations" # content addressed nix
            # "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
            # "configurable-impure-env" # allow impure environments
            # "git-hashing" # allow store objects which are hashed via Git's hashing algorithm
            # "verified-fetches" # enable verification of git commit signatures for fetchGit
            # "cgroups" # allow nix to execute builds inside cgroups
          ];
          # auto-allocate-uids = true;
          # allowed-users = users;
          # builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.
          # use-cgroups = true; # execute builds inside cgroups
          system-features = [
            #   # Allows building v3/v4 packages
            # "gccarch-x86-64-v3"
            # "gccarch-x86-64-v4"
            #   "kvm"
            #   "recursive-nix"
            # "big-parallel"
            #   "nixos-test"
          ];
          ### Avoid unwanted garbage collection when using nix-direnv
          keep-outputs = true;
          keep-derivations = true;
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
          extraArgs = "--keep-since 5d --keep 7";
        };
        enable = true;
        flake = "/home/${username}/.dotfiles/nixfiles";
      };
      nix-index-database = {
        comma.enable = isInstall;
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
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root" # Create dirs for home-manager
        "d /var/lib/private/sops/age 0755 root root"

        "d /var/log/nix 0755 ${username} users"
      ];

      user.extraConfig = ''
        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';

      extraConfig = ''
        # DefaultTimeoutStartSec=s
        DefaultTimeoutStopSec=10s
        # DefaultDeviceTimeoutSec=8s
        # DefaultTimeoutAbortSec=10s

        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';

      services = {
        "user@".serviceConfig.Delegate = true;
        systemd-user-sessions.enable = false;


        # https://github.com/NotAShelf/nyx/blob/d407b4d6e5ab7f60350af61a3d73a62a5e9ac660/modules/core/common/system/nix/module.nix#L236-L244
        nix-gc = {
          unitConfig.ConditionACPower = true; ### Nix gc when powered
        };

        nix-daemon.serviceConfig = {
          CPUWeight = 20;
          IOWeight = 20;
        };

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
        diff = {
          supportsDryActivation = true;
          text = ''
            BLUE=$(${pkgs.ncurses}/bin/tput setaf 4)
            CLEAR=$(${pkgs.ncurses}/bin/tput sgr0)

            if [[ -e /run/current-system ]]; then
              echo "$BLUE   $CLEAR System Diff Report $BLUE   $CLEAR"
              echo "#"
              ${pkgs.nvd}/bin/nvd --color=always --nix-bin-dir=${config.nix.package}/bin diff $(${pkgs.coreutils}/bin/readlink "/run/current-system") "$systemConfig" | tee /var/log/nix/nix-changelog
              echo "#"
              echo "$BLUE                $CLEAR"
            fi
          '';
        };

      };

      switch = {
        # enable = true; # false; # Perl
        enableNg = true; # Rust-based re-implementation of the original Perl switch-to-configuration
      };
    };
  };
}
