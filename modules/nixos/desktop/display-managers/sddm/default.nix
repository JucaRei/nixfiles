{
  config,
  pkgs,
  lib,
  username,
  ...
}:
let
  inherit (lib)
    mkIf
    mkOption
    stringAfter
    getExe'
    ;
  inherit (lib.types)
    listOf
    enum
    str
    nullOr
    bool
    ;
  cfg = config.desktop.display-managers.sddm;
in
{
  options = {
    desktop.display-managers.sddm = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable SDDM as the display manager.";
      };
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

  config = mkIf cfg.enable {
    services = {
      displayManager = {
        sddm = {
          enable = true;
          theme = cfg.sddm-theme;
          wayland = {
            enable = cfg.wayland-session;
            # compositor = "kwin";
          };
          settings = {
            Theme = {
              CursorTheme = "layan-border_cursors";
            };
          };
          extraPackages =
            if cfg.sddm-theme == "sddm-astronaut" && pkgs ? sddm-astronaut-theme then
              [ pkgs.sddm-astronaut-theme ]
            else if cfg.sddm-theme == "sddm-astronaut" && pkgs ? sddm-theme-astronaut then
              [ pkgs.sddm-theme-astronaut ]
            else if cfg.sddm-theme == "catppuccin-sddm-corners" && pkgs ? sddm-theme-corners then
              [ pkgs.sddm-theme-corners ]
            else if cfg.sddm-theme == "catppuccin-sddm-corners" && pkgs ? catppuccin-sddm-corners then
              [ pkgs.catppuccin-sddm-corners ]
            else if cfg.sddm-theme == "sddm-sugar-dark" && pkgs ? sddm-sugar-dark then
              [ pkgs.sddm-sugar-dark ]
            else if cfg.sddm-theme == "sddm-sugar-dark" && pkgs ? sddm-theme-sugar-dark then
              [ pkgs.sddm-theme-sugar-dark ]
            else if cfg.sddm-theme == "sddm-chili-theme" && pkgs ? sddm-chili-theme then
              [ pkgs.sddm-chili-theme ]
            else if cfg.sddm-theme == "sddm-chili-theme" && pkgs ? sddm-theme-chili then
              [ pkgs.sddm-theme-chili ]
            else if cfg.sddm-theme == "abstractdark-sddm-theme" && pkgs ? sddm-theme-abstractdark then
              [ pkgs.sddm-theme-abstractdark ]
            else
              [ ];
          autoNumlock = true;
        };
      };
      xserver = {
        displayManager = {
          setupCommands = ''
            ln -sfn /etc/sddm.conf.d /etc/sddm.conf
          '';
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
