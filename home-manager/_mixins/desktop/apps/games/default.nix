{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.games;
  myRetroarch = pkgs.retroarch.override {
    cores = with pkgs.libretro; [ mgba desmume dolphin citra genesis-plus-gx ];
  };
in
{
  options = {
    desktop.apps.games = {
      enable = mkEnableOption "Enable's games";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Games
      gamehub
      myRetroarch
      airshipper
      qjoypad
      superTux
      superTuxKart
    ];
    # The following 2 declarations allow retroarch to be imported into gamehub
    # Set retroarch core directory to ~/.local/bin/libretro
    # and retroarch core info directory to ~/.local/share/libretro/info
    home.file.".local/bin/libretro".source = "${myRetroarch}/lib/retroarch/cores";
    home.file.".local/share/libretro/info".source = fetchTarball {
      url = "https://github.com/libretro/libretro-core-info/archive/refs/tags/v1.19.0.tar.gz";
      sha256 = "12p8wpfzxmz5r2cl87k554cmqjf4v1kyg0hjx2racg5i5pv1ghvl";
    };
    # To get steam to import into gamehub, first install it as a flatpak, then
    # Set steam directory to ~/.var/app/com.valvesoftware.Steam/.steam
  };
}
