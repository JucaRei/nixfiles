{ config
, lib
, namespace
, pkgs
, ...
}:
let
  inherit (lib) mkIf mkForce mkDefault;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.security.sudo;

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
in
{
  options.${namespace}.security.sudo = {
    enable = mkBoolOpt false "Whether or not to enable sudo.";
  };
  config = mkIf cfg.enable {
    # copied from this Gist https://gist.github.com/nikopol/9e9409b0d1a6cd2ed7e89be1849e0724
    environment.etc."sudoers.d/00-lecture.txt".source = pkgs.stdenv.mkDerivation {
      name = lib.strings.sanitizeDerivationName "sudoers.d/00-lecture.txt";
      buildCommand = "echo -e '${groot_text}' > $out";
    };

    security = {
      sudo = {
        enable = true;

        execWheelOnly = mkForce true;
        wheelNeedsPassword = mkDefault false;

        extraConfig = ''
          Defaults pwfeedback # password input feedback - makes typed password visible as asterisks
          Defaults env_keep += "EDITOR PATH DISPLAY" # variables that will be passed to the root account
          Defaults timestamp_timeout = 300 # makes sudo ask for password less often
        '';

        configFile = ''
          # Defaults lecture = never # rollback results in sudo lectures after each reboot, it's somewhat useless anyway
          Defaults lecture = always
          Defaults lecture_file=/etc/sudoers.d/00-lecture.txt
        '';

        extraRules =
          let
            sudoRules = with pkgs; [
              {
                package = coreutils;
                command = "sync";
              }
              {
                package = hdparm;
                command = "hdparm";
              }
              {
                package = nix;
                command = "nix-collect-garbage";
              }
              {
                package = nix;
                command = "nix-store";
              }
              {
                package = nixos-rebuild;
                command = "nixos-rebuild";
              }
              {
                package = nvme-cli;
                command = "nvme";
              }
              {
                package = systemd;
                command = "poweroff";
              }
              {
                package = systemd;
                command = "reboot";
              }
              {
                package = systemd;
                command = "shutdown";
              }
              {
                package = systemd;
                command = "systemctl";
              }
              {
                package = util-linux;
                command = "dmesg";
              }
            ];

            addcommands = builtins.map
              (command: {
                command = "/run/current-system/sw/bin/${command}";
              }) [
              "bandwhich"
              "mic-light-on"
              "mic-light-off"
            ];

            mkSudoRule = rule: {
              command = lib.getExe' rule.package rule.command ++ addcommands;
              options = [ "NOPASSWD" "SETENV" ];
            };

            sudoCommands = map mkSudoRule sudoRules;
          in
          [
            {
              groups = [ "wheel" ];
              commands = sudoCommands;
            }
          ];
      };
    };
  };
}
