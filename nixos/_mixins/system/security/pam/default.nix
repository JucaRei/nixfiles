{ config, lib, isInstall, isWorkstation, ... }:
let
  inherit (lib) mkEnableOption mkDefault mkIf;
  inherit (lib.types) bool;
  cfg = config.system.security.pam;
in
{
  options.system.security.pam = {
    enable = mkEnableOption "Enable optimizations module.";
  };

  config = mkIf cfg.enable {
    security = {

      # User namespaces are required for sandboxing. Better than nothing imo.
      allowUserNamespaces = true;

      # Disable unprivileged user namespaces, unless containers are enabled
      unprivilegedUsernsClone = config.features.container-manager.enable;

      # Enables simultaneous use of processor threads.
      allowSimultaneousMultithreading = true;

      polkit = mkIf (isInstall && isWorkstation) {
        enable = true;
        debug = true;
        # the below configuration depends on security.polkit.debug being set to true
        # so we have it written only if debugging is enabled
        extraConfig = ''
          polkit.addRule(function (action, subject) {
            if (subject.isInGroup('wheel'))
              return polkit.Result.YES;
          });
        ''
        +
        ''
          /* Log authorization checks. */
          polkit.addRule(function(action, subject) {
            polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
          });
        ''
        +
        ''
          polkit.addRule(function(action, subject) {
            if (
              subject.isInGroup("users")
                && (
                  action.id == "org.freedesktop.login1.reboot" ||
                  action.id == "org.freedesktop.login1.reboot-multiple-sessions" ||
                  action.id == "org.freedesktop.login1.power-off" ||
                  action.id == "org.freedesktop.login1.power-off-multiple-sessions" ||
                  action.id == "org.freedesktop.login1.suspend" ||
                  action.id == "org.freedesktop.login1.suspend-multiple-sessions"
                )
              )
            {
              return polkit.Result.YES;
            }
          })
        '';
      };

      pam = mkIf (isInstall) {
        # Increase open file limit for sudoers
        # fix "too many files open" errors while writing a lot of data at once
        loginLimits = [
          {
            domain = "@wheel";
            item = "nofile";
            type = "soft";
            value = "524288";
          }
        ];

        services =
          let
            ttyAudit = {
              enable = true;
              enablePattern = "*";
            };
          in
          {
            # Allow screen lockers such as Swaylock or gtklock) to also unlock the screen.
            # swaylock.text = "auth include login";
            # gtklock.text = "auth include login";

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
            login.startSession = mkDefault isWorkstation;
          };
      };

      virtualisation = {
        #  flush the L1 data cache before entering guests
        flushL1DataCache = "always";
      };
    };
  };
}
