{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.system.services.appimage;
in
{
  options.${namespace}.system.services.appimage = with types; {
    enable = mkBoolOpt false "Whether or not to enable appimage.";
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
    # https://wiki.nixos.org/w/index.php?title=Appimage
    # https://nixos.org/manual/nixpkgs/stable/#sec-pkgs-appimageTools
    # programs.appimage = {
    #   enable = true;
    #   binfmt = true;
    # };

    # environment.systemPackages = with pkgs; [ appimage-run ];
  };
}
