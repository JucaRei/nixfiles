{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.nixfmt-plus;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      deadnix
      nixfmt-rfc-style
      statix
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.nixfmt-plus = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's nixfmt-plus script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
