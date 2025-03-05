{ config, lib, pkgs, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkOption mkIf;
  cfg = config.system.scripts.flatpak-theme;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      dconf
      flatpak
      gnused
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.flatpak-theme = {
      enable = mkOption {
        default = false;
        type = lib.types.bool;
        description = "enables flatpak-theme script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
