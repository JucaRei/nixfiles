{ config, lib, isInstall, hostname, username, stateVersion, isWorkstation, pkgs, ... }:
let
  inherit (lib) mkForce mkIf mkDefault mkOption mkEnableOption types;
  cfg = config.sys.tweaks;
in
{
  options.sys.tweaks = {
    enable = mkEnableOption "Default system tweaks configuration." // { default = true; };
  };

  config = mkIf cfg.enable {
    ##############
    ### Tweaks ###
    ##############
    system = {
      nixos = {
        label = mkIf (isInstall) (builtins.concatStringsSep "-" [ "${hostname}-" ] + config.system.nixos.version);
        tags = mkIf (isInstall) [ "NixOS" ];
      };
      stateVersion = stateVersion;
    };

    systemd = {
      tmpfiles.rules = [
        "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
      ];

      extraConfig = ''
        DefaultTimeoutStartSec=8s
        DefaultTimeoutStopSec=10s
        DefaultDeviceTimeoutSec=8s
        DefaultTimeoutAbortSec=10s
      '';

      services = {
        nix-gc = {
          unitConfig.ConditionACPower = true; ### Nix gc when powered
        };

        NetworkManager-wait-online.enable = lib.mkForce false;
        systemd-udev-settle.enable = lib.mkForce false;
      };

      targets = lib.mkIf (hostname == "soyo") {
        hibernate.enable = false;
        hybrid-sleep.enable = false;
      };

      # enable cgroups=v2 as default
      enableUnifiedCgroupHierarchy = mkForce isInstall;
    };

    security = {
      allowSimultaneousMultithreading = true; # Enables simultaneous use of processor threads.

      polkit = mkIf isInstall {
        enable = true;
        # the below configuration depends on security.polkit.debug being set to true
        # so we have it written only if debugging is enabled
        extraConfig = ''
          polkit.addRule(function (action, subject) {
            if (subject.isInGroup('wheel'))
              return polkit.Result.YES;
          });
        '' + ''
          /* Log authorization checks. */
          polkit.addRule(function(action, subject) {
            polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
          });
        '';
        debug = true;
      };

      pam = {
        # Increase open file limit for sudoers
        loginLimits = [{
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
          {
            domain = "@wheel";
            item = "nofile";
            type = "hard";
            value = "1048576";
          }];

        services =
          let
            ttyAudit = {
              enable = true;
              enablePattern = "*";
            };
          in
          {
            # Allow screen lockers such as Swaylock or gtklock) to also unlock the screen.
            swaylock.text = "auth include login";
            gtklock.text = "auth include login";

            login = {
              inherit ttyAudit;
              setLoginUid = true;
            };

            sshd = {
              inherit ttyAudit;
              setLoginUid = true;
            };

            sudo = {
              inherit ttyAudit;
              setLoginUid = true;
            };


            # Enable pam_systemd module to set dbus environment variable.
            login.startSession = mkForce isWorkstation;
          };
      };
    };

    services = {
      fwupd = {
        enable = isInstall;
      };

      dbus = {
        packages = mkIf isWorkstation (with pkgs; [ gnome-keyring gcr ]);
        # implementation = mkDefault "broker";
        implementation = mkOption {
          type = types.nullOr (types.enum [ "dbus" "broker" ]);
          default = "broker";
          description = "Default dbus implementation.";
        };
      };
    };
  };
}
