{ options, config, pkgs, lib, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.apps.dev.go;
in
{
  options.${namespace}.apps.dev.go = with types; {
    enable = mkBoolOpt false "Whether or not to enable Go support.";
  };

  config = mkIf cfg.enable {
    environment = {
      systemPackages = with pkgs; [
        go
        gopls
      ];
      sessionVariables = {
        GOPATH = "$HOME/.libraries/go";
      };
    };
  };
}
