{ config, lib, pkgs, inputs, nixGLWrapper ? (x: x), useNixGL ? false, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.editors.vscode;
in
{
  options = {
    system.programs.editors.vscode = {
      enable = mkEnableOption "Enable VS Code (automatically wrapped with nixGL when useNixGL = true (on host hm-config)).";
    };
  };

  config = mkIf cfg.enable {
    # nixpkgs = {
    #   overlays = [
    #     inputs.nix-vscode-extensions.overlays.default
    #   ];
    # };

    programs.vscode = {
      enable = true;
      # - NixOS (useNixGL = false) → pure vscode
      # - Debian/Ubuntu/etc. (useNixGL = true) → nixGL-wrapped vscode
      package = nixGLWrapper pkgs.vscode;

    };
  };
}

