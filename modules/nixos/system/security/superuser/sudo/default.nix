{
  config,
  lib,
  username,
  ...
}:
let
  inherit (lib) mkIf;
  esc = builtins.fromJSON "\"\\u001b\"";
  groot_text = ''
      ${esc}[00;32m  \\^V//
      ${esc}[00;33m  |${esc}[01;37m. ${esc}[01;37m.${esc}[00;33m|   ${esc}[01;34m  I am (G)root!
      ${esc}[00;32m- ${esc}[00;33m\\ - / ${esc}[00;32m_
      ${esc}[00;33m \\_| |_/
      ${esc}[00;33m   \\ \\
      ${esc}[00;31m __${esc}[00;33m/${esc}[00;31m_${esc}[00;33m/${esc}[00;31m__
      ${esc}[00;31m|_______|  ${esc}[00;37m With great power comes great responsibility.
      ${esc}[00;31m \\     /   ${esc}[00;37m Use sudo wisely.
      ${esc}[00;31m  \\___/
    ${esc}[0m
  '';
  cfg = config.system.security.superuser;
  user = "${username}";
in
{
  config = mkIf (cfg.manager == "sudo") {
    security = {
      sudo = {
        enable = true;
        extraConfig = ''
          Defaults lecture = always
          Defaults lecture_file = /etc/sudoers.d/00-lecture.txt
          Defaults timestamp_type = global
          Defaults timestamp_timeout = 20
          Defaults pwfeedback
          Defaults insults
          Defaults:root,%wheel env_keep += EDITOR
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
                  options = [
                    "NOPASSWD"
                    "SETENV"
                  ];
                })
                [
                  "poweroff"
                  "shutdown"
                  "reboot"
                  "nh"
                  "nixos-rebuild"
                  "nix-env"
                  "systemctl"
                ];
            # groups = [ "wheel" ];
          }
        ];
      };
    };

    environment = {
      etc = {
        "sudoers.d/00-lecture.txt" = {
          text = groot_text;
          mode = "0444";
        };
      };
    };
  };
}
