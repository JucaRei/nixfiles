{ pkgs, lib, config, ... }:
with lib;
with lib.hm.gvariant;
let
  cfg = config.services.aria2;
in
{
  options.services.aria2 = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    programs.aria2 = {
      enable = true;
      settings = {
        listen-port = "6881-6999";
        dht-listen-port = "6881-6999";
      };
    };
  };
}
