{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.editors.vscode;
in
{
  options.${namespace}.programs.graphical.editors.vscode = with types; {
    enable = mkBoolOpt false "Whether or not to enable vscode.";
  };

  config = mkIf cfg.enable { home.packages = with pkgs; [ vscode ]; };
}
