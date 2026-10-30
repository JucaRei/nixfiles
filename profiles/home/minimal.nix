{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  config = {
    system.programs = {
      console = {
        bat.enable = mkDefault true;
        eza.enable = mkDefault true;
      };
      shells = {
        default = mkDefault "zsh";
      };
    };

    home.packages = [
      pkgs.git
      pkgs.duf
      pkgs.ripgrep
      pkgs.htop
    ];
  };
}
