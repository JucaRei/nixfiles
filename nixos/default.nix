{ inputs, outputs, lib, config, pkgs, hostname, platform, modulesPath, isISO, isInstall, username, isWorkstation, ... }:
let
  inherit (lib) mkIf optionals mkDefault;

  # Only enable zram swap if no swap devices are configured
  usezramSwap = builtins.length config.swapDevices == 0;
in
{
  imports = [
    (./. + "/hosts/${hostname}/default.nix")
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
    # inputs.chaotic.nixosModules.default
    inputs.lanzaboote.nixosModules.lanzaboote
  ];

  # This is the main configuration for your NixOS system.
  config = {
    documentation = {
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

    i18n = {
      defaultLocale = mkDefault "en_US.UTF-8";
      extraLocaleSettings = {
        LANG = "en_US.UTF-8";
        LC_CTYPE = "pt_BR.UTF-8"; # Fix ç in us-intl.
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

    system = {
      boot = mkDefault {
        bootType = "efi";
        bootManager = "grub";
        plymouth = isWorkstation;
        silentBoot = isWorkstation;
      };
      # console.options = isWorkstation;
      security = mkDefault {
        superuser = {
          enable = true;
          # manager = mkDefault "sudo";
        };
        pam = {
          enable = isInstall;
        };
      };
    };

    boot = {
      binfmt = mkIf (isInstall) {
        emulatedSystems = mkIf (isWorkstation && config.system.services.virt-manager.enable) (
          [
            "armv5tel-linux"
            # "armv6l-linux"
            # "armv7l-linux"
            # "i686-linux"
          ]
          ++ optionals (platform == "x86_64-linux") [ "aarch64-linux" ]
          ++ optionals (platform == "aarch64-linux") [ "x86_64-linux" ]
        );
      };
      kernelModules = mkIf (config.system.services.virt-manager.enable) [ "vhost_vsock" ];
      kernel = {
        sysctl = mkIf (usezramSwap) { "vm.page-cluster" = 1; };
      };
    };

    hardware = {
      bluetooth = {
        enable = mkIf (isInstall) true;
        package = pkgs.unstable.bluez-experimental;
        powerOnBoot = false;
        settings = {
          General = mkIf isWorkstation {
            Name = config.networking.hostName;
            Enable = "Source,Sink,Media,Socket"; # Enable A2DP sink
            JustWorksRepairing = "always";
            MultiProfile = "multiple";
            ControllerMode = "bredr";
            FastConnectable = true;
            Privacy = "device";
            Experimental = true;
          };
        };
      };
    };

    system.activationScripts = {
      rfkillUnblockBluetooth = mkIf config.hardware.bluetooth.enable {
        text = ''
          # Unblock Bluetooth on activation
          ${pkgs.util-linux}/bin/rfkill unblock bluetooth || true
        '';
      };
    };

    environment = {
      defaultPackages = with pkgs; [ parted uutils-coreutils-noprefix ];
      systemPackages = with pkgs; [ nix-output-monitor ]
        ++ optionals isInstall [
        inputs.determinate.packages.${pkgs.system}.default
        # (pkgs.writeShellScriptBin "nixos-rebuild-half" ''
        #   #!/usr/bin/env bash
        #   set -euo pipefail

        #   # Compute half the logical cores (minimum 1)
        #   cores=$(nproc --all || echo 1)
        #   half_cores=$(expr $cores / 2)
        #   max_jobs=''${half_cores:-1}

        #   # Call the original nixos-rebuild with dynamic max-jobs
        #   exec nixos-rebuild --max-jobs "$max_jobs" "$@"
        # '')
      ];
      shellAliases = {
        # update-dotfiles = "git -C $HOME/.dotfiles pull && nix flake update $HOME/.dotfiles/nixfiles && nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles";
        nix_package_size = "nix path-info --size --human-readable --recursive /run/current-system | cut -d - -f 2- | sort";
        store-path = "${pkgs.uutils-coreutils-noprefix}/bin/readlink (${pkgs.which}/bin/which $argv)";
        keyring-lock = ''${pkgs.systemdMinimal}/bin/busctl --user get-property org.freedesktop.secrets /org/freedesktop/secrets/collection/login org.freedesktop.Secret.Collection Locked'';
      };

      etc = {
        ## Create a file in /etc/nixos-current-system-packages  Listing all Packages ###
        "nixos-current-system-packages" = {
          text =
            let
              packages =
                builtins.map (p: "${p.name}") config.environment.systemPackages;
              sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
              formatted = builtins.concatStringsSep "\n" sortedUnique;
            in
            formatted;
        };
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
    };

    services = {
      # system76-sheduler = {
      #   enable = mkIf isWorkstation true;
      #   # assignments = {
      #   #   nix-builds = {
      #   #     nice = 10; # from -20 (high) to 19 (low)
      #   #     class = "batch"; # "idle", "batch", "other", "rr", "fifo"
      #   #     ioClass = "idle"; # "idle", "best-effort", "realtime"
      #   #     matchers = [
      #   #       "nix-daemon"
      #   #     ];
      #   #   };
      #   # };
      # };

      fprintd = {
        enable = mkDefault false;
      };

      dbus = {
        enable = true;
        implementation = if isWorkstation then "broker" else "systemd";
      };

      openssh = {
        enable = true;
        settings = {
          PasswordAuthentication = mkDefault true;
          PermiRootLogin = if isISO then true else false;
        };
        startWhenNeeded = true;
        banner = ''
          ⣿⣿⣿⣿⣿⣿⣿⣿⡿⠿⠛⠛⠛⠋⠉⠈⠉⠉⠉⠉⠛⠻⢿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⡿⠋⠁⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠉⠛⢿⣿⣿⣿⣿
          ⣿⣿⣿⣿⡏⣀⠀⠀⠀⠀⠀⠀⠀⣀⣤⣤⣤⣄⡀⠀⠀⠀⠀⠀⠀⠀⠙⢿⣿⣿
          ⣿⣿⣿⢏⣴⣿⣷⠀⠀⠀⠀⠀⢾⣿⣿⣿⣿⣿⣿⡆⠀⠀⠀⠀⠀⠀⠀⠈⣿⣿
          ⣿⣿⣟⣾⣿⡟⠁⠀⠀⠀⠀⠀⢀⣾⣿⣿⣿⣿⣿⣷⢢⠀⠀⠀⠀⠀⠀⠀⢸⣿
          ⣿⣿⣿⣿⣟⠀⡴⠄⠀⠀⠀⠀⠀⠀⠙⠻⣿⣿⣿⣿⣷⣄⠀⠀⠀⠀⠀⠀⠀⣿
          ⣿⣿⣿⠟⠻⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠶⢴⣿⣿⣿⣿⣿⣧⠀⠀⠀⠀⠀⠀⣿
          ⣿⣁⡀⠀⠀⢰⢠⣦⠀⠀⠀⠀⠀⠀⠀⠀⢀⣼⣿⣿⣿⣿⣿⡄⠀⣴⣶⣿⡄⣿
          ⣿⡋⠀⠀⠀⠎⢸⣿⡆⠀⠀⠀⠀⠀⠀⣴⣿⣿⣿⣿⣿⣿⣿⠗⢘⣿⣟⠛⠿⣼
          ⣿⣿⠋⢀⡌⢰⣿⡿⢿⡀⠀⠀⠀⠀⠀⠙⠿⣿⣿⣿⣿⣿⡇⠀⢸⣿⣿⣧⢀⣼
          ⣿⣿⣷⢻⠄⠘⠛⠋⠛⠃⠀⠀⠀⠀⠀⢿⣧⠈⠉⠙⠛⠋⠀⠀⠀⣿⣿⣿⣿⣿
          ⣿⣿⣧⠀⠈⢸⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠟⠀⠀⠀⠀⢀⢃⠀⠀⢸⣿⣿⣿⣿
          ⣿⣿⡿⠀⠴⢗⣠⣤⣴⡶⠶⠖⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣀⡸⠀⣿⣿⣿⣿
          ⣿⣿⣿⡀⢠⣾⣿⠏⠀⠠⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠛⠉⠀⣿⣿⣿⣿
          ⣿⣿⣿⣧⠈⢹⡇⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⣰⣿⣿⣿⣿
          ⣿⣿⣿⣿⡄⠈⠃⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣴⣾⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣧⡀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣠⣾⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣷⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⠀⢀⣴⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⣦⣄⣀⣀⣀⣀⠀⠀⠀⠀⠘⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣷⡄⠀⠀⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣧⠀⠀⠀⠙⣿⣿⡟⢻⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⣿⠇⠀⠁⠀⠀⠹⣿⠃⠀⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⣿⣿⣿⣿⡿⠛⣿⣿⠀⠀⠀⠀⠀⠀⠀⠀⢐⣿⣿⣿⣿⣿⣿⣿⣿⣿
          ⣿⣿⣿⣿⠿⠛⠉⠉⠁⠀⢻⣿⡇⠀⠀⠀⠀⠀⠀⢀⠈⣿⣿⡿⠉⠛⠛⠛⠉⠉
          ⣿⡿⠋⠁⠀⠀⢀⣀⣠⡴⣸⣿⣇⡄⠀⠀⠀⠀⢀⡿⠄⠙⠛⠀⣀⣠⣤⣤⠄⠀
        '';
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

    # Create symlink to /bin/bash
    # - https://github.com/lima-vm/lima/issues/2110
    systemd = {
      extraConfig = ''
        DefaultTimeoutStopSec=10s
        DefaultCPUAccounting=yes
        DefaultMemoryAccounting=yes
        DefaultIOAccounting=yes
      '';
      tmpfiles.rules = [
        "L+ /bin/bash - - - - ${pkgs.bash}/bin/bash"
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
      ];

      services = {
        "mglru" = mkIf (usezramSwap) {
          enable = true;
          wantedBy = [ "basic.target" ];
          script = ''${pkgs.uutils-coreutils-noprefix}/bin/echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms'';
          serviceConfig = {
            Type = "oneshot";
          };
          unitConfig = {
            ConditionPathExists = "/sys/kernel/mm/lru_gen/enabled";
            Description = "Configure Enable Multi-Gen LRU";
          };
        };
      };
    };

    zramSwap = {
      algorithm = "zstd";
      enable = usezramSwap;
      memoryPercent = 100;
    };
  };
}
