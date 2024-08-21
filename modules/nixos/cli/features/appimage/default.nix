{ lib, username, config, ... }:
let
  installFor = [ "juca" ];
  cfg = config.features.appimage;
in
{
  options.features.appimage = {
    enable = lib.mkEnableOption "Enable Appimage" // {
      default = false;
      type = lib.types.bool;
    };
  };
  config = {
    # https://wiki.nixos.org/w/index.php?title=Appimage
    # https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-appimageTools
    programs.appimage = {
      enable = true;
      binfmt = true;
    };
  };
}
