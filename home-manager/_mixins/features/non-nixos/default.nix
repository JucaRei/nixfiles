{ config, lib, pkgs, hostname, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) mkIf mkOption types optionals;
  cfg = config.features.nonNixOs;
  isOtherOS = if builtins.isString (builtins.getEnv "__NIXOS_SET_ENVIRONMENT_DONE") then false else true;
in
{
  options.features.nonNixOs = {
    enable = mkOption {
      default = isOtherOS;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        nixgl.auto.nixGLDefault
      ];
      # OpenGL for GUI apps
      activation = {
        linkDesktopApplications = {
          # Add Packages To System Menu by updating database
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          data = ''sudo env "PATH=$PATH" /usr/bin/update-desktop-database'';
        };
      };
      sessionPath = [ "$HOME/.local/bin" ];
    };
    xdg = {
      mime.enable = true;
      systemDirs.data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
    };
    programs = {
      home-manager.enable = true;
    };
    targets.genericLinux.enable = true;
  };
}
