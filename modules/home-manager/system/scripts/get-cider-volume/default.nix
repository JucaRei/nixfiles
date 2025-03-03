{ hostname, lib, pkgs, config, ... }:
let
  # installOn = [
  #   ""
  # ];
  inherit (lib) mkIf mkOption types;
  cfg = config.scripts.get-cider-volume;

  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      bc
      coreutils-full
      gnugrep
      gnused
      playerctl
      pulseaudio
      pulsemixer
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
# lib.mkIf (builtins.elem hostname installOn) {
{
  options = {
    scripts.get-cider-volume = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "enable's cider volumes script.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
