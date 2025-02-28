{ config, hostname, isLima, isWorkstation, lib, pkgs, username, ... }:
let
  # installFor = [ "juca" ];
  inherit (lib) mkOption mkIf mkForce;
  inherit (lib.bool) bool;
  inherit (pkgs.stdenv) isLinux;
  cfg = config.system.services.sync;
in
# lib.mkIf (lib.elem username installFor && isLinux && !isLima) {
{
  options = {
    system.services.sync = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable's syncthing.";
      };
    };
  };
  config = mkIf cfg.enable {
    home = {
      file."/Syncthing/.keep".text = "";
      packages = with pkgs; [ stc-cli ];
    };
    programs.fish.shellAliases = {
      stc = "${pkgs.stc-cli}/bin/stc -homedir \"${config.home.homeDirectory}/Syncthing/Devices/${hostname}\"";
    };
    services.syncthing = {
      enable = true;
      extraOptions = [
        "--config=${config.home.homeDirectory}/Syncthing/Devices/${hostname}"
        "--data=${config.home.homeDirectory}/Syncthing/DB/${hostname}"
        "--no-default-folder"
        "--no-browser"
      ];
      tray = lib.mkIf isWorkstation {
        enable = true;
        package = pkgs.syncthingtray;
      };
    };

    sops = {
      # sops-nix options: https://dl.thalheim.io/
      secrets = {
        syncthing_apikey = { };
        syncthing_user = { };
        syncthing_pass = { };
      };
    };

    # Workaround for Failed to restart syncthingtray.service: Unit tray.target not found.
    # - https://github.com/nix-community/home-manager/issues/2064
    systemd.user = {
      targets.tray = mkIf isWorkstation {
        Unit = {
          Description = "Home Manager System Tray";
          Wants = [ "graphical-session-pre.target" ];
        };
      };
      services.syncthingtray = {
        Service.ExecStart = mkForce "${pkgs.syncthingtray}/bin/syncthingtray --wait";
      };
    };
  };
}
