{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.documents.libreoffice;
in
{
  options = {
    system.programs.documents.libreoffice = {
      enable = mkEnableOption "Enables libreoffice.";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs.unstable; [
        hunspell # Required for spellcheck
        hunspellDicts.en_US # American English spellcheck dictionary
        hunspellDicts.pt_BR
        languagetool # spelling, style. and grammer checker
        libreoffice-fresh
      ];
    };
  };
}
