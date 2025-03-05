{ hostname, lib, pkgs, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.system.scripts.get-rhythmbox-volume;

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
    system.scripts.get-rhythmbox-volume = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "enables rhythmbox volume script.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
