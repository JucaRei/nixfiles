{ username, pkgs, config, lib, isInstall, isWorkstation, ... }:
let
  groot_text = ''

      \033[00;32m  \\^V//
      \033[00;33m  |\033[01;37m. \033[01;37m.\033[00;33m|   \033[01;34m  I am (G)root!
      \033[00;32m- \033[00;33m\\ - / \033[00;32m_
      \033[00;33m \\_| |_/
      \033[00;33m   \\ \\
      \033[00;31m __\033[00;33m/\033[00;31m_\033[00;33m/\033[00;31m__
      \033[00;31m|_______|  \033[00;37m With great power comes great responsibility.
      \033[00;31m \\     /   \033[00;37m Use sudo wisely.
      \033[00;31m  \\___/
    \033[0m
  '';

  inherit (lib) mkIf mkDefault mkOption types;
  cfg = config.core.security;
in
{
  options.core.security = {
    enable = mkOption {
      default = false;
      type = with types; bool;
      description = "Enables the default security tools.";
    };
    superUser = mkOption {
      type = types.enum [ "sudo" "doas" ];
      default = "sudo";
      description = "Select the default super user security privileges tool.";
    };
  };

  config = mkIf cfg.enable {
    security = {

      # User namespaces are required for sandboxing. Better than nothing imo.
      allowUserNamespaces = true;

      # Disable unprivileged user namespaces, unless containers are enabled
      unprivilegedUsernsClone = config.features.container-manager.enable;

      sudo = {
        enable = if (cfg.superUser == "doas") then false else true;

        # Stops sudo from timing out.
        extraConfig =
          "# ${username} ALL=(ALL) NOPASSWD:ALL\n"
          + "${username} ALL=(ALL) NOPASSWD:${pkgs.systemd}/bin/systemctl\n"
          + "${username} ALL=(ALL) NOPASSWD:${pkgs.systemd}/bin/systemd-run\n"
          # + "Defaults env_reset,timestamp_timeout=-1"
          # + "Defaults:insults,root,%wheel timestamp_timeout=30"
          #+ "Defaults editor=${pkgs.neovim}/bin/nvim";
          # + "Defaults env_keep += EDITOR PATH\n"
          + "Defaults timestamp_type=global\n"  # share sudo session between terminal sessions
          + "Defaults timestamp_timeout=20\n"  # set sudo timeout from 10 to 20 minutes
          + "Defaults pwfeedback\n"  # display stars when typing characters
          # + "Defaults passprompt=[31m sudo: password for %p@%h, running as %U:[0m "
          + "Defaults insults\n"
          + "Defaults:root,%wheel env_keep+=EDITOR" # Enables sudo-prepended programs like `systemctl edit ...` to use the specified default editor https://github.com/NixOS/nixpkgs/issues/276778
        ;
        configFile = ''
          Defaults lecture = always
          Defaults lecture_file=/etc/sudoers.d/00-lecture.txt
        '';
        execWheelOnly = true;
        wheelNeedsPassword = true;
        extraRules = [
          # {
          #   commands = [
          #     { command = "${pkgs.tailscale}/bin/tailscale up --accept-routes --accept-dns=false"; options = [ "NOPASSWD" "SETENV" ]; }
          #     { command = "${pkgs.tailscale}/bin/tailscale down"; options = [ "NOPASSWD" "SETENV" ]; }
          #   ];
          # }
          {
            users = [ "${username}" ];
            commands =
              builtins.map
                (command: {
                  command = "/run/current-system/sw/bin/${command}";
                  options = [ "NOPASSWD" "SETENV" ];
                }) [ "poweroff" "shutdown" "reboot" "nh" "nixos-rebuild" "nix-env" "bandwhich" "mic-light-on" "mic-light-off" "systemctl" "usbtop" "powertop" "tlp-stat" ];
            groups = [ "wheel" ];
          }
        ];
      };

      ############
      ### DOAS ###
      ############
      doas = mkIf (cfg.superUser == "doas") {
        enable = true;
        # extraConfig = ''
        # permit nopass :wheel
        # '';
        extraRules = [
          {
            users = [ "${username}" ];
            # noPass = true;
            keepEnv = true;
            persist = true;
          }
          {
            users = [ "${username}" ];
            cmd = "tee";
            noPass = true;
          }
        ];
        wheelNeedsPassword = true;
      };

      allowSimultaneousMultithreading = true; # Enables simultaneous use of processor threads.

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
        '' + ''
          /* Log authorization checks. */
          polkit.addRule(function(action, subject) {
            polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
          });
        '' + ''
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

    environment = {
      # systemPackages = mkIf (cfg.superUser == "doas") [
      # (pkgs.writeScriptBin "sudo" ''exec doas "$@"'')
      # (pkgs.writeScriptBin "sudo" ''doas "$@"'')
      # ];

      shellAliases = mkIf (cfg.superUser == "doas") {
        sudo = "doas -u";
        #   sudo = "doas $@";
      };

      etc = mkIf (cfg.superUser == "sudo") {
        "sudoers.d/00-lecture.txt".source = pkgs.stdenv.mkDerivation {
          name = lib.strings.sanitizeDerivationName "sudoers.d/00-lecture.txt";
          buildCommand = "echo -e '${groot_text}' > $out";
        };
      };
    };

    users.users.${username} = {
      extraGroups = [
        "systemd-journal"
        # "proc" # Enable full /proc access and systemd-status
      ];
    };

    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/" # symlink executable's to normal linux path
    ];
  };
}
