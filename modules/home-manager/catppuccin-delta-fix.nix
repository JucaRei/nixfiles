# This module is a compatibility shim for catppuccin
# When catppuccin is disabled, this provides stub options to avoid errors
{ config, lib, ... }:

{
  # Provide stub programs.delta options so catppuccin delta module (if imported) doesn't error
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

  # Provide stub catppuccin options when it's not imported
  options.catppuccin = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable Catppuccin theme (stub for compatibility)";
    };
  };

  config = {
    # Disable catppuccin delta if it's somehow enabled
    catppuccin.delta.enable = lib.mkForce false;
  };
}
