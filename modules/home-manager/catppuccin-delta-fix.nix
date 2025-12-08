# This module disables the catppuccin delta configuration
# to work around the issue that home-manager 25.05 doesn't have programs.delta
{ config, lib, ... }:

{
  # Provide stub programs.delta options so catppuccin delta module doesn't error
  options.programs.delta = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable delta (stub option for catppuccin compatibility)";
    };
    enableGitIntegration = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable git integration (stub option for catppuccin compatibility)";
    };
    options = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = { };
      description = "Delta options (stub for catppuccin compatibility)";
    };
  };

  config = {
    # Always disable catppuccin delta
    catppuccin.delta.enable = lib.mkForce false;
  };
}
