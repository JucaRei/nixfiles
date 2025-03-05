{ config, hostname, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.mic-loopback;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      gnugrep
      gnused
      pipewire
      procps
      pulsemixer
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{

  options = {
    system.scripts.mic-loopback = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's mic-loopback script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
