{ config, pkgs, lib, ... }:
let
  inherit (lib) mkForce;
in
{
  imports = [
    ../../../modules/home-manager/system/services/ct-podman
    # ../../../modules/home-manager/programs/terminal/console
    # ../../../resources/hm-configs/console/aliases
  ];
  # i18n = {
  #   glibcLocales = pkgs.glibcLocales.override {
  #     allLocales = false;
  #     locales = [
  #       "en_US.UTF-8/UTF-8"
  #       "pt_BR.UTF-8/UTF-8"
  #     ];
  #   };
  # };
  config = {

    # programs.terminal.console.aliases.enable = true;

    console = {
      fzf.enable = true;
      starship.enable = true;
      bash.enable = true;
      # zsh.enable = true;
      fish.enable = true;
      aliases.enable = mkForce true;
    };
    system.services.ct-podman.enable = true;

    home = {
      packages = with  pkgs;
        [ nil nixpkgs-fmt ];
      keyboard = {
        layout = "br";
        variant = "abnt2";
        model = "pc105";
      };
    };
  };
}
