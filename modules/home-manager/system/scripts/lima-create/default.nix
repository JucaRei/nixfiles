{ lib, config, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.system.scripts.lima-create;
  name = builtins.baseNameOf (builtins.toString ./.);
  shellApplication = pkgs.writeShellApplication {
    inherit name;
    runtimeInputs = with pkgs; [
      bc
      coreutils-full
      gawk
      gnused
      lima-bin
      procps
    ];
    text = builtins.readFile ./${name}.sh;
  };
in
{
  options = {
    system.scripts.lima-create = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's lima-create script.";
      };
    };
  };
  config = mkIf cfg.enable {
    home = {
      file = {
        "${config.home.homeDirectory}/.lima/_templates/ubuntu-24.yml".text = builtins.readFile ./ubuntu-24.yml;
        "${config.home.homeDirectory}/.lima/_templates/ubuntu-22.yml".text = builtins.readFile ./ubuntu-22.yml;
      };
      packages = with pkgs; [ shellApplication ];
    };
    programs.fish.shellAliases = {
      create-grozbok = "lima-create grozbok";
      create-zeta = "lima-create zeta";
      grozbok = "limactl shell grozbok";
      zeta = "limactl shell zeta";
    };
  };
}
