# This module disables the catppuccin delta configuration
# to work around the issue that home-manager 25.05 doesn't have programs.delta
{ config, lib, ... }:

{
  # Provide a stub programs.delta.enable option so catppuccin delta module doesn't error
  options.programs.delta = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable delta (stub option for catppuccin compatibility)";
    };
  };

  config = {
    # Always disable catppuccin delta
    catppuccin.delta.enable = lib.mkForce false;
  };
}
