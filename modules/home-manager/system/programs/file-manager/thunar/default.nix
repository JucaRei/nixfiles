{ config, lib, pkgs, ... }:
let
  inherit (lib) mkIf mkEnableOption optionalString;
  cfg = config.system.programs.file-manager.thunar;

  thunar-with-plugins = pkgs.thunar.override {
    thunarPlugins = [
      pkgs.thunar-volman
      pkgs.thunar-archive-plugin
      pkgs.thunar-media-tags-plugin
    ];
  };

  terminalCmd =
    if config.programs ? alacritty && config.programs.alacritty.enable
    then "${pkgs.alacritty}/bin/alacritty --working-directory %f"
    else "${pkgs.xfce4-exo}/bin/exo-open --working-directory %f --launch TerminalEmulator";
in
{
  options = {
    system.programs.file-manager.thunar = {
      enable = mkEnableOption "Enable Thunar file manager with plugins, custom actions (uca.xml), and thumbnails support.";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      thunar-with-plugins
      tumbler
      xarchiver
      file-roller
      webp-pixbuf-loader
      libgsf
      poppler
      freetype
      xfce4-exo
      catfish
      meld
      polkit
    ];

    xdg.mimeApps.defaultApplications = {
      "inode/directory" = "thunar.desktop";
    };

    home.file = {
      # Custom Actions do Thunar (uca.xml)
      ".config/Thunar/uca.xml".text = ''
        <?xml version="1.0" encoding="UTF-8"?>
        <actions>
            <action>
                <icon>utilities-terminal</icon>
                <name>Open Terminal Here</name>
                <unique-id>1612104464586264-1</unique-id>
                <command>${terminalCmd}</command>
                <description>Abrir terminal no diretório atual</description>
                <patterns>*</patterns>
                <startup-notify/>
                <directories/>
            </action>
      '' + optionalString (config.system.programs.editors.vscode.enable or false) ''
            <action>
                <icon>${config.programs.vscode.package}/share/pixmaps/vscode.png</icon>
                <name>Open VSCode Here</name>
                <unique-id>1612104464586265-1</unique-id>
                <command>code %f</command>
                <description>Abrir pasta no VSCode</description>
                <patterns>*</patterns>
                <startup-notify/>
                <directories/>
            </action>
      '' + optionalString (config.system.programs.editors.antigravity.enable or false) ''
            <action>
                <icon>code</icon>
                <name>Open in Antigravity</name>
                <unique-id>1612104464586266-1</unique-id>
                <command>antigravity %f</command>
                <description>Abrir projeto no Antigravity AI IDE</description>
                <patterns>*</patterns>
                <startup-notify/>
                <directories/>
                <text-files/>
            </action>
      '' +
      ''
            <action>
                <icon>${pkgs.meld}/share/icons/hicolor/symbolic/apps/org.gnome.Meld-symbolic.svg</icon>
                <name>Compare</name>
                <submenu></submenu>
                <unique-id>1622791692322694-4</unique-id>
                <command>${pkgs.meld}/bin/meld %F</command>
                <description>Comparar arquivos e diretórios com Meld</description>
                <range></range>
                <patterns>*</patterns>
                <directories/>
                <text-files/>
            </action>
            <action>
                <icon>system-file-manager-root</icon>
                <name>Open folder as root</name>
                <unique-id>1493475601060449-3</unique-id>
                <command>${pkgs.polkit}/bin/pkexec ${pkgs.thunar}/bin/thunar %f</command>
                <description>Abrir pasta como administrador</description>
                <patterns>*</patterns>
                <directories/>
            </action>
            <action>
                <icon>catfish</icon>
                <name>Search with catfish</name>
                <unique-id>1489089852658523-2</unique-id>
                <command>${pkgs.catfish}/bin/catfish --path=$f$d</command>
                <description>Buscar arquivos com Catfish</description>
                <patterns>*</patterns>
                <directories/>
            </action>
            <action>
                <icon>archive-extract</icon>
                <name>Extract here</name>
                <unique-id>1489091300385082-4</unique-id>
                <command>${pkgs.xarchiver}/bin/xarchiver -e %f</command>
                <description>Extrair arquivo compactado aqui</description>
                <patterns>*.tar.gz;*.tgz;*.tar.bz2;*.tbz2;*.tar.xz;*.txz;*.zip;*.7z;*.rar;*.tar.zst</patterns>
                <other-files/>
            </action>
        </actions>
      '';
    };
  };
}
