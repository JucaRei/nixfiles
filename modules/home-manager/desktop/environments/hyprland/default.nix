{
  config,
  lib,
  ...
}:
{
  imports = [
    ./hyprland.nix
    ./packages.nix
  ];

  config = lib.mkIf config.desktop.hyprland.enable {
    desktop.display-servers.backend = "wayland";

    # Programas padrão do ambiente
    system.programs = {
      file-manager.thunar.enable = lib.mkDefault (
        !config.system.programs.file-manager.nautilus.enable
        && !config.system.programs.file-manager.nemo.enable
        && !config.system.programs.file-manager.pcmanfm.enable
      );
    };

    home.sessionVariables = {
      HYPRCURSOR_THEME = config.desktop.theme.cursor.name;
      HYPRCURSOR_SIZE = toString config.desktop.theme.cursor.size;
    };
  };
}
