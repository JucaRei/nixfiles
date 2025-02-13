{ config, pkgs, ... }:

{
  home = {
    sessionVariables = {
      # XDG_CURRENT_DESKTOP = "KDE";
      # XDG_SESSION_DESKTOP = "KDE";
    };
    packages = with pkgs; [
      neofetch
    ];
  };
}
