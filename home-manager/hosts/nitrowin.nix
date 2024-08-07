{ config
, lib
, pkgs
, ...
}:
with lib.hm.gvariant; {
  imports = [
    ../_mixins/non-nixos
    ../_mixins/console/fish
  ];
  # dconf.settings = {
  #   "org/gnome/desktop/background" = {
  #     picture-options = "zoom";
  #     # picture-uri = "file://${config.home.homeDirectory}/Pictures/Determinate/DeterminateColorway-3440x1440.png";
  #   };
  # };

  config = {
    home = {
      packages = with pkgs; [
        util-linux
        cloneit
        unstable.nix
        nixpkgs-fmt
        nil
        deadnix
        nix-direnv
        nix-output-monitor
        cachix
      ];
    };
    services.nonNixOs.enable = true;
    # nix.settings = {
    #   extra-substituters = [ "https://nitro.cachix.org" ];
    #   extra-trusted-public-keys = [ "nitro.cachix.org-1:Z4AoDBOqfAdBlAGBCoyEZuwIQI9pY+e4amZwP94RU0U=" ];
    # };
  };
}
