{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.scripts.template;

  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [ coreutils-full ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    scripts.template = {
      enable = mkOption {
        default = false;
        type = types.bool;
        description = "enables template.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
