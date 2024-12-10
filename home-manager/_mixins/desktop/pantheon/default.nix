{ config, lib, pkgs, ... }:
let
  inherit (lib) mkDefault;
in
{
  config = {
    custom.features = {
      mime.defaultApps = mkDefault {
        defaultBrowser = "firefox.desktop";
        # defaultFileManager = "nemo.desktop";
        # defaultAudioPlayer = "io.bassi.Amberol.desktop";
        # defaultVideoPlayer = "mpv.desktop";
        # defaultPdf = "org.pwmt.zathura.desktop";
        # defaultPlainText = "org.gnome.gedit.desktop";
        # defaultImgViewer = "xviewer.desktop";
        # defaultArchiver = "org.gnome.FileRoller.desktop";
        # defaultExcel = "calc.desktop";
        # defaultWord = "writer.desktop";
        # defaultPowerPoint = "impress.desktop";
        # defaultEmail = "org.gnome.Geary.desktop";
      };
    };

    home = {
      packages = with pkgs; [ monitor ];
      file = {
        ".local/share/plank/themes/Catppuccin-mocha/dock.theme".text = builtins.readFile ../../../../resources/dots/plank/plank-catppuccin-mocha.theme;
        "${config.xdg.configHome}/autostart/monitor.desktop".text = ''
          [Desktop Entry]
          Name=Monitor Indicators
          Comment=Monitor Indicators
          Type=Application
          Exec=/run/current-system/sw/bin/com.github.stsdc.monitor --start-in-background
          Icon=com.github.stsdc.monitor
          Categories=
          Terminal=false
          StartupNotify=false'';
      };
    };

    services = {
      gpg-agent.pinentryPackage = lib.mkForce pkgs.pinentry-gnome3;
    };

    systemd.user.services = {
      # https://github.com/tom-james-watson/emote
      emote = {
        Unit = {
          Description = "Emote";
        };
        Service = {
          ExecStart = "${pkgs.emote}/bin/emote";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "default.target" ];
        };
      };
    };
  };
}
