{ config, lib, pkgs, ... }:
let
  inherit (lib) optionalString getExe;
  thunar-with-plugins = (pkgs.thunar or pkgs.xfce.thunar).override {
    thunarPlugins = [
      (pkgs.thunar-volman or pkgs.xfce.thunar-volman)
      (pkgs.thunar-archive-plugin or pkgs.xfce.thunar-archive-plugin)
      (pkgs.thunar-media-tags-plugin or pkgs.xfce.thunar-media-tags-plugin)
    ];
  };
  finalThunar = thunar-with-plugins;
in
{
  config = {
    desktop.display-servers.backend = "x11";

    home = let gio = pkgs.gnome.gvfs; in {
      packages = with pkgs; [
        # File Manager
        (pkgs.xfce4-exo or pkgs.exo or pkgs.xfce.exo)
        finalThunar
        (pkgs.tumbler or pkgs.xfce.tumbler)
        (pkgs.catfish or pkgs.xfce.catfish)

        xarchiver
        webp-pixbuf-loader
        zip
        unzip
        poppler # .pdf .ps
        libgsf # .odf
        freetype # fonts
        libgepub # .epub
        ffmpegthumbnailer # videos

        gnome-keyring
        gparted
        galculator

      ];

      sessionVariables = {
        GIO_EXTRA_MODULES = "${gio}/lib/gio/modules";
      };

      file = {
        ".config/xfce4/helpers.rc".text =
          let
            terminal = getExe config.programs.alacritty.package;
          in
          ''
            # TerminalEmulator=${terminal}
              TerminalEmulatorDismissed=true
          '';

        # ".config/Thunar/accels.scm".text = lib.fileContents ./accels.scm;

        ".config/Thunar/uca.xml".text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <actions>
              <action>
                  <icon>xterm</icon>
                  <name>Open Terminal Here</name>
                  <unique-id>1612104464586264-1</unique-id>
                  <command>${pkgs.xfce4-exo or pkgs.exo or pkgs.xfce.exo}/bin/exo-open --working-directory %f --launch TerminalEmulator</command>
                  <description>Example for a custom action</description>
                  <patterns>*</patterns>
                  <startup-notify/>
                  <directories/>
              </action>
        '' + optionalString config.system.programs.editors.vscode.enable ''
          <action>
              # <icon>${pkgs.vscode}/share/pixmaps/vscode.png</icon>
              <icon>${config.programs.vscode.package}/share/pixmaps/vscode.png</icon>
              <name>Open VSCode Here</name>
              <unique-id>1612104464586265-1</unique-id>
              <command>code %f</command>
              <description></description>
              <patterns>*</patterns>
              <startup-notify/>
              <directories/>
          </action>
        '' +
        ''
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
                  <command>${pkgs.catfish or pkgs.xfce.catfish}/bin/catfish --path=$f$d</command>
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
        '';
      };
    };
  };
}
