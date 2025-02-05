{ config, lib, namespace, ... }:
let
  inherit (lib) mkIf;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.system.xkb;
  hostname = config.${namespace}.system.modules.hosts;
in
{
  options.${namespace}.system.xkb = with lib.types; {
    enable = mkBoolOpt false "Whether or not to configure xkb.";
  };

  config = mkIf cfg.enable {
    console.useXkbConfig = true;

    services.xserver = {
      xkb =
        if (hostname == "nitro") || (hostname == "scrubber") then
          {
            layout = "br";
            variant = "abnt2";
            model = "pc105";
          }
        else
          {
            layout = "us";
            variant = "mac";
            model = "pc104";
          };
    };
  };
}
