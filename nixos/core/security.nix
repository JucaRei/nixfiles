{ lib, isInstall, isWorkstation, ... }:
let
  inherit (lib) mkIf mkForce;
in
{
  security =
    {
      allowSimultaneousMultithreading = true; # Enables simultaneous use of processor threads.

      polkit = mkIf isInstall {
        enable = true;
        debug = true;
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
      };

      pam = mkIf isWorkstation {
        # Increase open file limit for sudoers
        # fix "too many files open" errors while writing a lot of data at once
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
}
