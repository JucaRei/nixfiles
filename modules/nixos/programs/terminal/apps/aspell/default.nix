{ lib, pkgs, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.programs.terminal.apps.aspell;
in
{
  options = {
    programs.terminal.apps.aspell = {
      enable = mkEnableOption "Install aspell.";
    };
  };
  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.pt_BR
        hunspellDicts.en_US
        hunspellDicts.pt_BR
      ];

      etc = {
        "aspell.conf".text = ''
          master en_US
          add-extra-dicts en-computers.rws
          add-extra-dicts pt_BR.rws
        '';
      };
    };
  };
}
