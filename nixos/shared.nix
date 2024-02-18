{ hostid, hostname, username, config, lib, pkgs, stateVersion, inputs, ... }: {
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
        text = ''
          if [[ -e /run/current-system ]]; then
            echo "--- changed packages"
            ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
            echo "---"
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
      wpa_supplicant.restartIfChanged = false;

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
      implementation = lib.mkDefault "dbus";
    };
    udev = { enable = true; };
  };

  environment = {
    # --------------------------------------------------------------------
    # Permit Insecure Packages && Allow unfree packages
    # --------------------------------------------------------------------
    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";

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
