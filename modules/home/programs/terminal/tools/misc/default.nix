{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.terminal.tools.misc;
in
{
  options.${namespace}.programs.terminal.tools.misc = with types; {
    enable = mkBoolOpt false "Whether or not to enable common utilities.";
  };

  config = mkIf cfg.enable {
    excalibur.home.configFile."wgetrc".text = "";

    home.packages = with pkgs; [
      fzf
      killall
      unzip
      file
      jq
      clac
      glow
    ];
  };
}
