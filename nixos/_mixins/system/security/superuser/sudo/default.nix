{ config, lib, pkgs, username, ... }:
let
  inherit (lib) mkIf;
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
  cfg = config.system.security.superuser;
  user = config.users.users.${username};
in
{
  config = mkIf (cfg.manager == "sudo") {
    security = {
      sudo = {
        enable = true;
        extraConfig =
          "# ${user}.user ALL=(ALL) NOPASSWD:ALL\n"
          + "${user}.user ALL=(ALL) NOPASSWD:${pkgs.systemd}/bin/systemctl\n"
          + "${user}.user ALL=(ALL) NOPASSWD:${pkgs.systemd}/bin/systemd-run\n"
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
            users = [ "${user}" ];
            commands =
              builtins.map
                (command: {
                  command = "/run/current-system/sw/bin/${command}";
                  options = [ "NOPASSWD" "SETENV" ];
                }) [ "poweroff" "shutdown" "reboot" "nh" "nixos-rebuild" "nix-env" "bandwhich" "dmesg" "sync" "systemctl" "usbtop" "powertop" "tlp-stat" ];
            # groups = [ "wheel" ];
          }
        ];
      };
    };

    environment = {
      etc = {
        "sudoers.d/00-lecture.txt".source = pkgs.stdenv.mkDerivation {
          name = lib.strings.sanitizeDerivationName "sudoers.d/00-lecture.txt";
          buildCommand = "echo -e '${groot_text}' > $out";
        };
      };
    };
  };
}
