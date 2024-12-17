{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.documents.libreoffice;
in
{
  options = {
    desktop.apps.documents.libreoffice = {
      enable = mkEnableOption "Enables libreoffice .";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      hunspell # Required for spellcheck
      hunspellDicts.en_US # American English spellcheck dictionary
      languagetool # spelling, style. and grammer checker
      libreoffice-fresh
    ];
  };
}
