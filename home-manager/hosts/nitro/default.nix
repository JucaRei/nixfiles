{ pkgs, ... }:
let
  fhd = { width = 1920; height = 1080; refresh = 60; };
  pt = "pt_BR.UTF-8";
  en = "en_US.UTF-8";
in
{
  config = {
    desktop.monitors = [
      (fhd // { name = "HDMI-1-0"; x = 0;    y = 0; primary = false; })
      (fhd // { name = "HDMI-1-1"; x = 0;    y = 0; primary = false; })
      (fhd // { name = "eDP-1";    x = 1920; y = 0; primary = true;  })
    ];

    system.programs = {
      console    = { bat.enable = true; eza.enable = true; };
      browsers   = { firefox.enable = true; };
      editors    = { antigravity.enable = true; };
      terminal   = { enable = true; name = "alacritty"; };
    };

    home = {
      packages = with pkgs; [ git duf fzf ripgrep htop btop ];

      sessionPath = [ "/usr/sbin" "/sbin" ];

      sessionVariables = {
        NIX_REMOTE = "daemon";
        LC_ALL     = "";
      };

      language = {
        base = en; messages = en;
        ctype = pt; time = pt; numeric = pt; monetary = pt;
        paper = pt; name = pt; address = pt;
        telephone = pt; measurement = pt;
      };
    };

    programs.antigravity-cli.enable = true;
  };
}
