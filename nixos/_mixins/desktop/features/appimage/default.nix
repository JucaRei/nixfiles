{ lib, config, pkgs, isWorkstation, desktop, ... }:
let
  inherit (lib) mkOption types mkIf;
  cfg = config.desktop.features.appimage;
in
{
  options = {
    desktop.features.appimage = {
      enable = mkOption {
        default = isWorkstation && desktop != null;
        type = types.bool;
        description = "Enables Support for executing AppImages";
      };
    };
  };

  config = mkIf cfg.enable {
    boot.binfmt.registrations.appimage = {
      wrapInterpreterInShell = false;
      interpreter = "${pkgs.appimage-run}/bin/appimage-run";
      recognitionType = "magic";
      offset = 0;
      mask = ''\xff\xff\xff\xff\x00\x00\x00\x00\xff\xff\xff'';
      magicOrExtension = ''\x7fELF....AI\x02'';
    };
  };
  # https://wiki.nixos.org/w/index.php?title=Appimage
  # https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-appimageTools
  # programs.appimage = {
  #   enable = true;
  #   binfmt = true;
  # };
}
