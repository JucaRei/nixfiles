{ config, pkgs, lib, ... }:
let
  inherit (lib) mkEnableOption mkIf;
  cfg = config.apps.graphical.file-manager.thunar;
  thunar-with-plugins = with pkgs.xfce; (thunar.override {
    thunarPlugins = [ thunar-volman thunar-archive-plugin thunar-media-tags-plugin ];
  });
  finalThunar = thunar-with-plugins;
in
{
  options = {
    apps.graphical.file-manager.thunar = {
      enable = mkEnableOption "Enable's configured thunar file manager.";
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        ### XFCE packages
        xfce.exo
        finalThunar
        xfce.tumbler # thumbnail
        xfce.catfish # search tool

        webp-pixbuf-loader # webp
        gnome.gvfs
        cifs-utils # Tools for managing Linux CIFS client filesystems
        poppler # .pdf .ps
        libgsf # .odf
        freetype # fonts
        libgepub # .epub
        ffmpegthumbnailer # videos
      ];

      sessionVariables = {
        GIO_EXTRA_MODULES =
          let
            gio = pkgs.gnome.gvfs;
          in
          "${gio}/lib/gio/modules";
      };

      file = {
        ".config/xfce4/helpers.rc".text = ''
          # TerminalEmulator=${config.programs.alacritty.package}/bin/alacritty
          TerminalEmulatorDismissed=true
        '';

        ".config/Thunar/accels.scm".text = lib.fileContents ./accels.scm;

        ".config/Thunar/uca.xml".text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <actions>
              <action>
                  <icon>xterm</icon>
                  <name>Open Terminal Here</name>
                  <unique-id>1612104464586264-1</unique-id>
                  <command>${pkgs.xfce.exo}/bin/exo-open --working-directory %f --launch TerminalEmulator</command>
                  <description>Example for a custom action</description>
                  <patterns>*</patterns>
                  <startup-notify/>
                  <directories/>
              </action>
              <action>
                  <icon>${pkgs.meld}/share/icons/hicolor/symbolic/apps/org.gnome.Meld-symbolic.svg</icon>
                  <name>Compare</name>
                  <submenu></submenu>
                  <unique-id>1622791692322694-4</unique-id>
                  <command>${pkgs.meld}/bin/meld %F</command>
                  <description>Compare files and directories with  meld</description>
                  <range></range>
                  <patterns>*</patterns>
                  <directories/>
                  <text-files/>
              </action>
              <action>
                  <icon>system-file-manager-root</icon>
                  <name>Open folder as root</name>
                  <unique-id>1493475601060449-3</unique-id>
                  <command>${pkgs.polkit}/bin/pkexec ${finalThunar}/bin/thunar %f</command>
                  <description></description>
                  <patterns>*</patterns>
                  <directories/>
              </action>
              <action>
                  <icon>catfish</icon>
                  <name>Search with catfish</name>
                  <unique-id>1489089852658523-2</unique-id>
                  <command>${pkgs.xfce.catfish}/bin/catfish --path=$f$d</command>
                  <description></description>
                  <patterns>*</patterns>
                  <directories/>
              </action>
              <action>
                  <icon>archive-extract</icon>
                  <name>Extract here</name>
                  <unique-id>1489091300385082-4</unique-id>
                  <command>tar xjf %n</command>
                  <description></description>
                  <patterns>*.tar.bz2;*.tbz2</patterns>
                  <other-files/>
              </action>
          </actions>
        ''
        +
        lib.optionalString (config.apps.graphical.editor.vscode.enable) ''
          <action>
              <icon>${config.programs.vscode.package}/share/pixmaps/vscode.png</icon>
              <name>Open VSCode Here</name>
              <unique-id>1612104464586265-1</unique-id>
              <command>${config.programs.vscode.package}/bin/code %f</command>
              <description></description>
              <patterns>*</patterns>
              <startup-notify/>
              <directories/>
          </action>
        '';
        # <command>${lib.getExe config.programs.vscode.package} %f</command>
      };
    };
  };
}
