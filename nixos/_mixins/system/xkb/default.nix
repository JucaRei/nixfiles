{ config, lib, namespace, ... }:
let
  inherit (lib) mkIf mkOption mdDoc;
  inherit (lib.types) nullOr enum bool;

  cfg = config.system.xkb;
  hostname = config.system.modules.hosts;
in
{
  options.system.xkb = {
    enable = {
      type = bool;
      default = false;
      description = "Whether or not to configure xkb.";
    };
    keyboards = mkOption {
      type = nullOr (enum [ "ptBR" "mac_us" ]);
      default = "ptBR";
      description = mdDoc "The default keyboard enabled.";
    };
  };

  config = mkIf cfg.enable {
    # config = mkIf (cfg.enable && cfg.backend == "x11") {
    console.useXkbConfig = true;

    services.xserver =
      let
        conf = config.system.xkb.keyboards;
      in
      {
        xkb =
          if conf == "ptBR" then
            {
              layout = "br";
              variant = "abnt2";
              model = "pc105";
            }
          else if (conf == "mac_us") then
            {
              layout = "us";
              variant = "mac";
              model = "pc104";
            }
          else {
            layout = "us";
            model = "pc105";
          }
        ;
      };
  };
}
