{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.gpg-restore;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      coreutils-full
      findutils
      gnupg
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.gpg-restore = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's gpg-restore script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ shellApplication ];
  };
}
