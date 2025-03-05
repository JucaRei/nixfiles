{ hostname, config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.music-volume;
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
{
  options = {
    system.scripts.music-volume = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's music-volume script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
