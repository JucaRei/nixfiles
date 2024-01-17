{ inputs, ... }:
# _:
{
  imports = [
    inputs.flatpaks.homeManagerModules.default
  ];
  # config.services.flatpak.enableModule.enable = true;

  services.flatpak.enableModule = true;
  # services.flatpak.enable = true;

  # home = {
  #   packages = [ pkgs.flatpak ];
  #   sessionVariables = {
  #     XDG_DATA_DIRS = "$XDG_DATA_DIRS:/usr/share:/var/lib/flatpak/exports/share:$HOME/.local/share/flatpak/exports/share"; # lets flatpak work
  #   };
  # };

  #services.flatpak.enable = true;
  #services.flatpak.packages = [ { appId = "com.kde.kdenlive"; origin = "flathub";  } ];
  #services.flatpak.update.onActivation = true;
}
