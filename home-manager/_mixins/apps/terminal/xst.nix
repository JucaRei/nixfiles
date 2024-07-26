{ config, lib, pkgs, ... }:
{

  # xst-256color isn't supported over ssh, so revert to a known one
  # modules.shell.zsh.rcInit = ''
  #   [ "$TERM" = xst-256color ] && export TERM=xterm-256color
  # '';

  home = {
    packages = with pkgs; [
      xst # st + nice-to-have extensions
      (makeDesktopItem {
        name = "xst";
        desktopName = "Suckless Terminal";
        genericName = "Default terminal";
        icon = "utilities-terminal";
        exec = "${xst}/bin/xst";
        categories = [ "Development" "System" "Utility" ];
      })
    ];
    sessionVariables = {
      "$TERM" = "xst-256color";
      "export" = "TERM=xterm-256color";
    };
  };
}
