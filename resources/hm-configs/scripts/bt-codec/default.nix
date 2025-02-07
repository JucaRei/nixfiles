{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.scripts.bt-codec;

  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      gnugrep
      gnused
      jq
      pulseaudio
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    scripts.bt-codec = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "enables bt-codec script.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
