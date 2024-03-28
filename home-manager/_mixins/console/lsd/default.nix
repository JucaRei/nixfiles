{ lib, config, ... }:
with lib;
let
  cfg = config.services.lsd;
in
{
  options.services.lsd = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    programs.lsd = {
      enable = true;
      settings = {
        icons.separator = "  "; # double-space, first one gets consumed by nerdfont icon
        indicators = false;
        blocks = [
          "permission"
          "user"
          "group"
          "size"
          "date"
          "name"
        ];
        sorting.dir-grouping = "first";
      };
    };
  };
}
