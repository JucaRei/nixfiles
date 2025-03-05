{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.picom_toogle;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      procps
      killall
      libnotify
      picom
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.picom_toogle = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's picom_toogle script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
