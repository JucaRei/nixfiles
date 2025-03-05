{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.mic-mute;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      gnused
      notify-desktop
      pulseaudio
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.mic-mute = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's mic-mute script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
