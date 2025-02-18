{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.tools.appimage;
in
{
  options.${namespace}.programs.graphical.tools.appimage = with types; {
    enable = mkBoolOpt false "Whether or not to enable appimage.";
  };

  config = mkIf cfg.enable {
    excalibur.home.configFile."wgetrc".text = "";

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
