{ config, lib, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) types mkIf mkOption;
  cfg = config.desktop.apps.chat.halloy;
in
{
  options.desktop.apps.chat.halloy = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home = {
      file = {
        "${config.home.homeDirectory}/.config/halloy/themes/catppuccin-mocha.toml".text = builtins.readFile ./halloy-catppuccin-mocha.toml;
      };

      packages = with pkgs; [
        halloy # Irc
      ];
    };

    # sops = {
    #   secrets = mkIf (lib.elem username installFor) {
    #     halloy_config.path = "${config.home.homeDirectory}/.config/halloy/config.toml";
    #   };
    # };
  };
}
