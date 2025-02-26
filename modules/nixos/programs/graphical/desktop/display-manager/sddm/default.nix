{ config, pkgs, lib, username, ... }:
let
  inherit (lib) stringAfter getExe';
  inherit (lib.types) listOf enum str bool;
  cfg = config.programs.graphical.displayManager.sddm;
in
{
  options = {
    programs.graphical.displayManager.sddm = {
      theme = {
        type = listOf (enum str [
          "sddm-astronaut"
          "catppuccin-sddm-corners"
          "sddm-sugar-dark"
          "sddm-chili-theme"
          "abstractdark-sddm-theme"
        ]);
        default = "sddm-astronaut";
        description = "The SDDM theme to use.";
      };
      isWayland = {
        type = bool;
        default = false;
        description = "Enable Wayland support.";
      };
    };
  };

  config = {
    services = {
      displayManager = {
        sddm = {
          enable = true;
          theme = cfg.theme;
          setupCommands = ''
            ln -sfn /etc/sddm.conf.d /etc/sddm.conf
          '';
          wayland = {
            enable = cfg.isWayland;
          };
          package = pkgs.sddm.override {
            extraConfig = ''
              [General]
              Numlock=on
            '';
          };
          settings = {
            Theme = {
              CursorTheme = "layan-border_cursors";
            };
          };
          extraPackages =
            if cfg.theme == "sddm-astronaut"
            then [ pkgs.sddm-theme-astronaut ]
            else if cfg.theme == "catppuccin-sddm-corners"
            then [ pkgs.sddm-theme-corners ]
            else if cfg.theme == "sddm-sugar-dark"
            then [ pkgs.sddm-theme-sugar-dark ]
            else if cfg.theme == "sddm-chili-theme"
            then [ pkgs.sddm-theme-chili ]
            else if cfg.theme == "abstractdark-sddm-theme"
            then [ pkgs.nur.repos.fortuneteller2k.impure.sddm-theme-abstractdark ]
            else [ ];
          autoNumlock = true;
        };
      };
    };

    system.activationScripts.postInstallSddm =
      stringAfter [ "users" ] # bash
        ''
          echo "Setting sddm permissions for user icon"
          ${getExe' pkgs.acl "setfacl"} -m u:sddm:x /home/${username}
          ${getExe' pkgs.acl "setfacl"} -m u:sddm:r /home/${username}/.face.icon || true
        '';
  };
}
