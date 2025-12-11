{ config, pkgs, lib, username, desktop, ... }:
let
  inherit (lib) mkIf mkOption stringAfter getExe';
  inherit (lib.types) listOf enum str nullOr bool;
  cfg = config.desktop.display-manager;
in
{
  options = {
    desktop.display-manager.sddm = {
      sddm-theme = mkOption {
        type = enum [
          "sddm-astronaut"
          "catppuccin-sddm-corners"
          "sddm-sugar-dark"
          "sddm-chili-theme"
          "abstractdark-sddm-theme"
        ];
        default = "sddm-astronaut";
        description = "The SDDM theme to use.";
      };
      wayland-session = mkOption {
        type = bool;
        default = if (config.desktop.backend == "wayland") then true else false;
        description = "Enable Wayland support.";
      };
    };
  };

  config = mkIf (cfg.chosen == "sddm") {
    services = {
      xserver = {
        displayManager = {
          setupCommands = ''
            ln -sfn /etc/sddm.conf.d /etc/sddm.conf
          '';
        };
      };
      displayManager.sddm = {
        enable = true;
        theme = cfg.sddm.sddm-theme;
        wayland = {
          enable = cfg.sddm.wayland-session;
          compositor = if (desktop == "plasma") then "kwin" else "weston";
        };
        settings = {
          Theme = {
            CursorTheme = "layan-border_cursors";
          };
        };
        extraPackages = [ ];
        autoNumlock = true;
      };
    };

    system.activationScripts.postInstallSddm =
      let
        setfacl = lib.getExe' pkgs.acl "setfacl";
      in
      stringAfter [ "users" ] # bash
        ''
          echo "Setting sddm permissions for user icon"
          ${setfacl} -m u:sddm:x /home/${username}
        '';
  };
}
