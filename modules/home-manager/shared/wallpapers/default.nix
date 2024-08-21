{ lib, config, pkgs, ... }:
let
  cfg = config.modules.wallpapers;
  walls = pkgs.fetchgit {
    url = "https://github.com/D3Ext/aesthetic-wallpapers";
    rev = "060c580dcc11afea2f77f9073bd8710920e176d8";
    sha256 = "5MnW630EwjKOeOCIAJdSFW0fcSSY4xmfuW/w7WyIovI=";
  };
in
{
  options.modules.wallpapers = {
    enable = lib.mkOption {
      default = false;
      type = lib.types.bool;
    };
  };
  config = lib.mkIf cfg.enable {
    home.file."Pictures/wallpapers".source = lib.mkForce "${walls}/images";
    # "${config.home.homeDirectory}/Pictures/wallpapers" = lib.mkDefault {
    #   source = ../../_mixins/config/wallpapers;
    #   recursive = true;
    # };
  };
}
