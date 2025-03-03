{ hostname, lib, pkgs, config, ... }:
let
  # installOn = [
  #   "nitro"
  #   "rocinante"
  # ];
  inherit (lib) mkOption mkIf types;
  cfg = config.scripts.get-rhythmbox-volume;

  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      bc
      coreutils-full
      rhythmbox
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
# lib.mkIf (builtins.elem hostname installOn) {

{
  options = {
    scripts.get-rhythmbox-volume = {
      enable = mkOption {
        # default = mkIf (config.desktop.apps.audio.rhythmbox.enable);
        default = false;
        type = types.bool;
        description = "enables rhythmbox volume script.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
