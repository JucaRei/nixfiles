{ config, isLima, isWorkstation, lib, pkgs, username, ... }:
let
  # installFor = [ "${username}" ];
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkOption mkIf optionals;
  inherit (lib.types) bool;
  cfg = config.system.services.keybase-io;
in

# lib.mkIf (lib.elem username installFor && isLinux && !isLima) {
{
  options = {
    system.services.keybase-io = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's keybase messaging";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      "${config.xdg.configHome}/keybase/autostart_created" = {
        text = ''
          This file is created the first time Keybase starts, along with
          ~/.config/autostart/keybase_autostart.desktop. As long as this
          file exists, the autostart file won't be automatically recreated.
        '';
      };
    };
    home = {
      packages = with pkgs; [ keybase ] ++ optionals isWorkstation [ keybase-gui ];
    };
    services = {
      kbfs = {
        enable = true;
        mountPoint = "Keybase";
      };
      keybase = {
        enable = true;
      };
    };
    # Workaround kbfs not working properly
    # - https://github.com/nix-community/home-manager/issues/4722
    systemd.user.services.kbfs.Service.PrivateTmp = lib.mkForce false;
  };
}
