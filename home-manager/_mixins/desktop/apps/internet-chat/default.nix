{ config, lib, pkgs, username, ... }:
let
  installFor = [ "juca" ];
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) types mkIf mkOption;
  cfg = config.desktop.apps.blackbox;
in
{
  options.desktop.apps.blackbox = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    home = {
      file = mkIf (lib.elem username installFor) {
        "${config.home.homeDirectory}/.config/halloy/themes/catppuccin-mocha.toml".text = builtins.readFile ./halloy-catppuccin-mocha.toml;
      };

      packages = with pkgs; [ unstable.telegram-desktop ]
        ++ optionals (lib.elem username installFor) [
        (discord.override { withOpenASAR = true; })
      ]
        # Halloy is installed via homebrew on Darwin
        ++ optionals (lib.elem username installFor && isLinux) [
        fractal # Matrix client
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
