{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.programs.graphical.tools.ubports-installer;
in
{
  options.${namespace}.programs.graphical.tools.ubports-installer = with types; {
    enable = mkBoolOpt false "Whether or not to enable the UBPorts Installer.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs.excalibur; [ ubports-installer ];

    services.udev.packages = with pkgs.excalibur; [ ubports-installer-udev-rules ];
  };
}
