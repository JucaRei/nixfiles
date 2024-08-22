{ config, lib, pkgs, username, ... }:
let
  installFor = [ "juca" ];
  cfg = config.modules.apps.internet-chat;
in
{
  options.modules.apps.internet-chat = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      file = lib.mkIf (lib.elem username installFor) {
        # "${config.home.homeDirectory}/.local/share/chatterino/Themes/mocha-blue.json".text = builtins.readFile ../../../../../../resources/configs/chatterino/chatterino-mocha-blue.json;
        "${config.home.homeDirectory}/.config/halloy/themes/catppuccin-mocha.toml".text = builtins.readFile ../../../../../../resources/configs/halloy/halloy-catppuccin-mocha.toml;
      };

      packages = with pkgs; [ unstable.telegram-desktop ]
        ++ lib.optionals (lib.elem username installFor) [
        # chatterino2
        cinny-desktop
        (discord.override { withOpenASAR = true; })
      ]
        ++ lib.optionals (lib.elem username installFor) [
        # fractal
        halloy
      ];
    };

    # sops = {
    #   secrets = lib.mkIf (lib.elem username installFor) {
    #     halloy_config.path = "${config.home.homeDirectory}/.config/halloy/config.toml";
    #   };
    # };
  };
}
