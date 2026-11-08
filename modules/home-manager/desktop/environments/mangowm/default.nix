# What it is: MangoWM Wayland compositor (dwl-based lightweight tiling window manager).
# How to enable: Set `desktop = "mangowm";` in hosts.nix or `desktop.mangowm.enable = true;`.
# Example: desktop.mangowm.enable = true;
{
  config,
  lib,
  ...
}:
{
  imports = lib.my.importDir ./.;

  config = lib.mkIf config.desktop.mangowm.enable {
    desktop.display-servers.backend = "wayland";

    # Programas padrão do ambiente
    system.programs = {
      file-manager.thunar.enable = lib.mkDefault (
        !config.system.programs.file-manager.nautilus.enable
        && !config.system.programs.file-manager.nemo.enable
        && !config.system.programs.file-manager.pcmanfm.enable
      );
    };
  };
}
