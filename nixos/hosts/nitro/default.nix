{ config, lib, pkgs, inputs, username, ... }: {
  imports = [
    # ../../_mixins/hardware/graphics/nvidia/nvidia-offload.nix
    ../../_mixins/hardware/other/usb.nix
    ../../_mixins/services/security/sudo.nix
    ../../_mixins/virtualization/virtual-manager/testing.nix
    (import ./disks-btrfs.nix { })
    # (import ./disks-bcachefs.nix { })
    ./hardware.nix
    ./filesystem.nix
  ];
  config = {
    programs.gnupg.agent.enable = true;

    nixpkgs = {
      hostPlatform = lib.mkDefault "x86_64-linux";
    };

    environment = {
      systemPackages = with pkgs; [
        btdu
        btrfs-progs
        compsize
        cloneit
        gparted
        lm_sensors
        os-prober

        floorp
        vscode-fhs
        nil
        nixpkgs-fmt
        duf
        htop
        neofetch
        spotube
      ];
      sessionVariables = { };
    };

    services = {
      # virtualisation.kvm.enable = true;

      ### Touchpad
      libinput = {
        enable = true;
        touchpad = {
          accelProfile = "adaptive";
          accelSpeed = "0.6";
          tapping = true;
          scrollMethod = "twofinger";
          disableWhileTyping = true;
          clickMethod = "clickfinger";
          naturalScrolling = true;
          # natural scrolling for touchpad only, not mouse
          additionalOptions = ''
            MatchIsTouchpad "on"
          '';
        };
        mouse = {
          naturalScrolling = false;
          disableWhileTyping = true;
          accelProfile = "adaptive";
          accelSpeed = "0.3";
        };
      };

      virtualisation.kvm.enable = true;

      acpid = {
        enable = true;
      };
      power-profiles-daemon.enable = lib.mkDefault true;
      btrfs = {
        autoScrub = {
          enable = true;
          interval = "weekly";
        };
      };
    };

    systemd = {
      oomd = {
        enable = false;
      };
      services = {
        zswap = {
          description = "Enable ZSwap, set to LZ4 and Z3FOLD";
          enable = true;
          wantedBy = [ "basic.target" ];
          path = [ pkgs.bash ];
          serviceConfig = {
            ExecStart = ''
              ${pkgs.bash}/bin/bash -c 'cd /sys/module/zswap/parameters&& \
                    echo 1 > enabled&& \
                    echo 20 > max_pool_percent&& \
                    echo lz4hc > compressor&& \
                    echo z3fold > zpool'
            '';
            Type = "simple";
          };
        };

        nix-daemon = {
          ### Limit resources used by nix-daemon
          serviceConfig = {
            MemoryMax = "8G";
            MemorySwapMax = "12G";
          };
        };
      };

      sleep.extraConfig = ''
        AllowHibernation=yes
        AllowSuspend=yes
        AllowSuspendThenHibernate=yes
        AllowHybridSleep=yes
      '';
    };
    nix.settings = {
      extra-substituters = [ "https://nitro.cachix.org" ];
      extra-trusted-public-keys = [ "nitro.cachix.org-1:Z4AoDBOqfAdBlAGBCoyEZuwIQI9pY+e4amZwP94RU0U=" ];
    };
  };
}
