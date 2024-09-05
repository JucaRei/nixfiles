{ config, lib, pkgs, hostname, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) mkIf mkOption types optionals;
  cfg = config.custom.nonNixOs;
  isOld = if (hostname == "oldarch") then false else true;
in
{
  options.custom.nonNixOs = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        nix-output-monitor
      ] ++ (with pkgs; optionals (isOld) [ nixgl.auto.nixGLDefault ]);
      # OpenGL for GUI apps
      activation = {
        linkDesktopApplications = {
          # Add Packages To System Menu by updating database
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          data = ''sudo env "PATH=$PATH" /usr/bin/update-desktop-database'';
        };
      };
    };
    targets.genericLinux.enable = true;
  };
}
