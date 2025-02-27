{ config, pkgs, lib, username, ... }:
let
  inherit (lib) mkOption stringAfter getExe';
  inherit (lib.types) listOf enum str nullOr bool;
  cfg = config.programs.graphical.displayManager.sddm;
in
{
  options = {
    programs.graphical.displayManager.sddm = {
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
        default = false;
        description = "Enable Wayland support.";
      };
    };
  };

  config = {
    services = {
      xserver = {
        displayManager = {
          setupCommands = ''
            ln -sfn /etc/sddm.conf.d /etc/sddm.conf
          '';
        };
      };
      displayManager = {
        sddm = {
          enable = true;
          theme = cfg.sddm-theme;
          wayland = {
            enable = cfg.wayland-session;
            compositor = "kwin";
          };
          settings = {
            Theme = {
              CursorTheme = "layan-border_cursors";
            };
          };
          extraPackages =
            if cfg.sddm-theme == "sddm-astronaut"
            then [ pkgs.sddm-theme-astronaut ]
            else if cfg.sddm-theme == "catppuccin-sddm-corners"
            then [ pkgs.sddm-theme-corners ]
            else if cfg.sddm-theme == "sddm-sugar-dark"
            then [ pkgs.sddm-theme-sugar-dark ]
            else if cfg.sddm-theme == "sddm-chili-theme"
            then [ pkgs.sddm-theme-chili ]
            else if cfg.sddm-theme == "abstractdark-sddm-theme"
            then [ pkgs.sddm-theme-abstractdark ]
            else [ ];
          autoNumlock = true;
        };
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
          ${setfacl} -m u:sddm:r /home/${username}/.face.icon || true
        '';
  };
}
