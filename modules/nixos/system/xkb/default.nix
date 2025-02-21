{ config, lib, namespace, ... }:
let
  inherit (lib) mkIf mkOption mdDoc;
  inherit (lib.types) nullOr enum;
  inherit (lib.${namespace}) mkBoolOpt;

  cfg = config.${namespace}.system.xkb;
  hostname = config.${namespace}.system.modules.hosts;
in
{
  options.${namespace}.system.xkb = {
    enable = mkBoolOpt false "Whether or not to configure xkb.";
    keyboards = mkOption {
      type = nullOr (enum [ "ptBR" "ptUS" ]);
      default = "ptBR";
      description = mdDoc "The default keyboard enabled.";
    };
  };

  config = mkIf cfg.enable {
    console.useXkbConfig = true;

    services.xserver =
      let
        conf = config.${namespace}.system.xkb.keyboards;
      in
      {
        xkb =
          if conf == "ptBR" then
            {
              layout = "br";
              variant = "abnt2";
              model = "pc105";
            }
          else if (conf == "ptUS") then
            {
              layout = "us";
              variant = "mac";
              model = "pc104";
            }
          else {
            layout = "us";
            # variant = "mac";
            model = "pc105";
          }
        ;
      };
  };
}
