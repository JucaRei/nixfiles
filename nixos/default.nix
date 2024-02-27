{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs
, stateVersion, username, hostid, ... }: {
  # Import host specific boot and hardware configurations.
  # Only include desktop components if one is supplied.
  # - https://nixos.wiki/wiki/Nix_Language:_Tips_%26_Tricks#Coercing_a_relative_path_with_interpolated_variables_to_an_absolute_path_.28for_imports.29
  imports = [
    # inputs.home-manager.nixosModules.home-manager
    inputs.vscode-server.nixosModules.default
    inputs.disko.nixosModules.disko
    (modulesPath + "/installer/scan/not-detected.nix")
    (./. + "/hosts/${hostname}")
    ./_mixins/services/network/openssh.nix
    ./_mixins/services/tools/smartmon.nix
    ./_mixins/common
    ./users/root
  ] ++ lib.optional (builtins.pathExists (./. + "/users/${username}"))
    ./users/${username} ++ lib.optional (desktop != null) ./_mixins/desktop
    ++ lib.optional (hostname != "rasp3" || "air")
    ./_mixins/services/tools/kmscon.nix;

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
      (_: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      inputs.agenix.overlays.default
      inputs.nixd.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })

      ## Testing
      (self: super: {
        # libsForQt5 = super.libsForQt5.overrideScope (qt5self: qt5super: {
        #   sddm = qt5super.sddm.overrideAttrs (old: {
        #     patches = (old.patches or [ ]) ++ [
        #       (pkgs.fetchpatch {
        #         url =
        #           "https://github.com/sddm/sddm/commit/1a78805be83449b1b9c354157320f7730fcc9f36.diff";
        #         sha256 = "sha256-JNsVTJNZV6T+SPqPkaFf3wg8NDqXGx8NZ4qQfZWOli4=";
        #       })
        #     ];
        #   });
        # });

        tor-browser-bundle-bin = super.symlinkJoin {
          name = super.tor-browser-bundle-bin.name;
          paths = [ super.tor-browser-bundle-bin ];
          buildInputs = [ super.makeWrapper ];
          postBuild = ''
            wrapProgram "$out/bin/tor-browser" \
              --set MOZ_ENABLE_WAYLAND 1
          '';
        };

        mpv =
          super.mpv.override { scripts = with super.mpvScripts; [ mpris ]; };
        # vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
        deadbeef = super.deadbeef.override { wavpackSupport = true; };
        deadbeef-with-plugins = super.deadbeef-with-plugins.override {
          plugins = with super.deadbeefPlugins; [ mpris2 statusnotifier ];
        };
      })
    ];
    # Configure your nixpkgs instance
    config = {
      allowBroken = true;
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Accept the joypixels license
      joypixels.acceptLicense = true;
      allowUnsupportedSystem = true;
      permittedInsecurePackages = [ "openssl-1.1.1w" "electron-19.1.9" ];

      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;

      # allowUnfreePredicate = pkg:
      #   builtins.elem (lib.getName pkg) [
      #     "nvidia-settings"
      #     "nvidia-x11"
      #     "spotify"
      #     "steam"
      #     "steam-original"
      #     "steam-run"
      #     "vscode"
      #     # "dubai"

      #     # they got fossed recently so idk
      #     "Anytype"
      #   ];
    };
  };

  nix = {
    checkConfig = true;
    checkAllErrors = true;

    # 🍑 smooth rebuilds
    # give nix-daemon the lowest priority
    # Reduce disk usage
    daemonIOSchedClass = "idle";
    # Leave nix builds as a background task
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7; # only used by "best-effort"

    gc = {
      automatic = true;
      options = "--delete-older-than 5d";
      dates = "00:00";
    };

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!

    # nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}")
    #   config.nix.registry;

    # Add nixpkgs input to NIX_PATH
    # This lets nix2 commands still use <nixpkgs>
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];

    optimise.automatic = true;
    package = pkgs.unstable.nix;
    settings = {
      accept-flake-config = true;
      sandbox = "relaxed";
      show-trace = true;
      auto-optimise-store = true;
      flake-registry = "/etc/nix/registry.json";

      # for direnv GC roots
      keep-derivations = false;
      keep-outputs = true;
      keep-going = lib.mkForce false;

      experimental-features = [
        # "auto-allocate-uids"
        "nix-command"
        "flakes"
        "repl-flake"
        # "ca-derivations"
        # "cgroups"
      ];
      # Allow to run nix
      allowed-users = [ "root" "@wheel" ];
      builders-use-substitutes =
        true; # Avoid copying derivations unnecessary over SSH.

      trusted-users = [ "root" "@wheel" ];

      substituters = [
        "https://cache.nixos.org"
        "https://nix-community.cachix.org"
        "https://hyprland.cachix.org"
        "https://cachix.cachix.org"

      ];

      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "cachix.cachix.org-1:eWNHQldwUO7G2VkjpnjDbWwy4KQ/HNxht7H4SSoMckM="
      ];
    };
    extraOptions = ''
      log-lines = 15

      # If set to true, Nix will fall back to building from source if a binary substitute fails.
      #fallback = true

      # Free up to 4GiB whenever there is less than 2GiB left.
      min-free = ${toString (2048 * 1024 * 1024)}
      max-free = ${toString (4096 * 1024 * 1024)}
      # Free up to 4GiB whenever there is less than 512MiB left.
      #min-free = ${toString (512 * 1024 * 1024)}
      #min-free = 1073741824 # 1GiB
      #max-free = 4294967296 # 4GiB
      #builders-use-substitutes = true

      connect-timeout = 10
    '';

    # distributedBuilds = true;
  };

  #############################################
  ### Keep nixos and home-manager separated ###
  #############################################
  # User Specific home-manager Profile
  # home-manager = {
  #   useUserPackages = true;
  #   useGlobalPkgs = true;
  # };

  #########################################################
  ### Use passed hostname to configure basic networking ###
  #########################################################

  networking = {
    extraHosts = ''
      192.168.1.35  nitro
      192.168.1.50  nitro
      192.168.1.45  rocinante
      192.168.1.76  dongle
      192.168.1.228 rocinante
      192.168.1.230 air
      192.168.1.200 DietPi
    '';
    hostName = hostname;
    hostId = hostid;
    useDHCP = lib.mkDefault true;
    firewall = { enable = true; };
  };

  system = {
    activationScripts = {
      diff = {
        supportsDryActivation = true;
        # text = ''
        #   if [[ -e /run/current-system ]]; then
        #     echo "--- changed packages"
        #     ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        #     echo "---"
        #   fi
        # '';

        text = ''
          if [[ -e /run/current-system ]]; then
            echo -e "\n***            ***          ***           ***           ***\n"
            ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig" | grep -w "→" | grep -w "KiB" | column --table --separator " ,:" | ${pkgs.choose}/bin/choose 0:1 -4:-1 | ${pkgs.gawk}/bin/awk '{s=$0; gsub(/\033\[[ -?]*[@-~]/,"",s); print s "\t" $0}' | sort -k5,5gr | ${pkgs.choose}/bin/choose 6:-1 | column --table
            echo -e "\n***            ***          ***           ***           ***\n"
          fi
        '';
      };
      # Write out a warning if kernel version has changed.
      requires-reboot = {
        supportsDryActivation = true;
        text = ''
          if [[ -e /run/current-system ]]; then
            var1="`realpath /run/booted-system/{initrd,kernel,kernel-modules}`"
            var2="`realpath $systemConfig/{initrd,kernel,kernel-modules}`"

            if [[ $var1 != $var2 ]]; then
              >&2 echo "WARN: Kernel version has changed, system should be rebooted!"
            fi
          fi
        '';
      };
      fixboot.text = ''
        ln -sfn "$(readlink -f "$systemConfig")" /run/current-system
      '';
    };

    extraSystemBuilderCmds = ''
      ln -sv ${pkgs.path} $out/nixpkgs
    '';

    stateVersion = stateVersion;

    autoUpgrade = {
      enable = false;
      allowReboot = false;
      channel = "https://nixos.org/channels/nixos-unstable";
      flake = inputs.self.outPath;
      flags = [
        "--update-input"
        "nixpkgs"
        "-L" # print build logs
      ];
      dates = "monthly";
      randomizedDelaySec = "45min";
    };
  };

  systemd = {
    user = {
      extraConfig = ''
        DefaultTimeoutStopSec=15s
        DefaultTimeoutAbortSec=8s
      '';
    };
    tmpfiles.rules = [
      "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
      "d /mnt/snapshot/${username} 0755 ${username} users"
    ];

    # Reduce default service stop timeouts for faster shutdown
    # Default timeout for stopping services managed by systemd to 15 seconds
    extraConfig = ''
      DefaultTimeoutStartSec=15s
      DefaultTimeoutStopSec=15s
      DefaultDeviceTimeoutSec=15s
      DefaultTimeoutAbortSec=15s
    '';

    # When a program crashes, systemd will create a core dump file, typically in the /var/lib/systemd/coredump/ directory.
    # coredump.enable = true;

    # systemd's out-of-memory daemon
    # oomd = {
    #   enable = lib.mkDefault true;
    #   enableSystemSlice = true;
    #   enableUserServices = true;
    # };

    services = {
      # ---------------------------------------------------------------------
      # Do not restart these, since it messes up the current session
      # Idea's used from previous fedora woe's
      # ---------------------------------------------------------------------
      NetworkManager.restartIfChanged = false;
      display-manager.restartIfChanged = false;
      libvirtd.restartIfChanged = false;
      polkit.restartIfChanged = false;
      systemd-logind.restartIfChanged = false;
      # wpa_supplicant.restartIfChanged = false;

      # lock-before-sleeping = {
      #   restartIfChanged = false;
      #   unitConfig = {
      #     Description = "Helper service to bind locker to sleep.target";
      #   };

      #   serviceConfig = {
      #     ExecStart = "${pkgs.slock}/bin/slock";
      #     Type = "simple";
      #   };

      #   before = [ "pre-sleep.service" ];
      #   wantedBy = [ "pre-sleep.service" ];

      #   environment = {
      #     DISPLAY = ":0";
      #     XAUTHORITY = "/home/${username}/.Xauthority";
      #   };
      # };

      #---------------------------------------------------------------------
      # Modify autoconnect priority of the connection of my home network
      #---------------------------------------------------------------------
      # modify-autoconnect-priority = {
      #   description = "Modify autoconnect priority of Matrix_5g connection";
      #   script = ''
      #     nmcli connection modify Matrix_5g connection.autoconnect-priority 1
      #   '';
      # };

      #---------------------------------------------------------------------
      # Make nixos boot a tad faster by turning these off during boot
      #---------------------------------------------------------------------
      # Workaround https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = lib.mkForce false;
      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      systemd-udev-settle.enable = lib.mkForce false;
      # systemd-user-sessions.enable = false;
    };
  };

  services = {
    journald = {
      extraConfig = lib.mkDefault ''
        SystemMaxUse=10M
        SystemMaxFileSize=10M
        RuntimeMaxUse=10M
        RuntimeMaxFileSize=10M
        MaxFileSec=7day
        SystemMaxFiles=5
      '';
      rateLimitBurst = 800;
      rateLimitInterval = "5s";
    };
    dbus = {
      # Enable the D-Bus service, which is a message bus system that allows
      # communication between applications.
      enable = true;
      implementation = if hostname == "nitro" then "broker" else "dbus";
    };
  };

  environment = {
    # --------------------------------------------------------------------
    # Permit Insecure Packages && Allow unfree packages
    # --------------------------------------------------------------------
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";

      FLAKE = "/home/${username}/.dotfiles/nixfiles";
    };
    # Create file /etc/current-system-packages with List of all Packages
    etc = {
      "current-system-packages" = {
        text = let
          packages =
            builtins.map (p: "${p.name}") config.environment.systemPackages;
          sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
          formatted = builtins.concatStringsSep "\n" sortedUnique;
        in formatted;
      };
    };
  };

  hardware.enableRedistributableFirmware = true;

}
