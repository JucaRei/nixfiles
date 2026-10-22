{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkEnableOption
    mkOption
    types
    optionalString
    ;
  cfg = config.system.programs.file-manager.thunar;

  thunar-with-plugins = pkgs.thunar.override {
    thunarPlugins = [
      pkgs.thunar-volman
      pkgs.thunar-archive-plugin
      pkgs.thunar-media-tags-plugin
    ];
  };

  # Wrapper para garantir suporte a GVfs (Samba/SMB, Rede, Lixeira, MTP) no Thunar
  thunar-wrapped = pkgs.symlinkJoin {
    name = "thunar-with-gvfs";
    paths = [ thunar-with-plugins ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -rf $out/bin
      mkdir -p $out/bin

      for bin in ${thunar-with-plugins}/bin/*; do
        if [ -x "$bin" ]; then
          makeWrapper "$bin" "$out/bin/$(basename "$bin")" \
            --prefix GIO_EXTRA_MODULES : "${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules" \
            --prefix XDG_DATA_DIRS : "${pkgs.gvfs}/share:/usr/share"
        fi
      done
    '';
  };

  terminalCmd =
    if (config.system.programs.terminal.activeWorkingDirCommand or "") != "" then
      "${config.system.programs.terminal.activeWorkingDirCommand} %f"
    else if config.programs ? alacritty && config.programs.alacritty.enable then
      "${pkgs.alacritty}/bin/alacritty --working-directory %f"
    else
      "${pkgs.xfce4-exo}/bin/exo-open --working-directory %f --launch TerminalEmulator";
in
{
  options = {
    system.programs.file-manager.thunar = {
      enable = mkEnableOption "Enable Thunar file manager with plugins, custom actions (uca.xml), and thumbnails support.";

      rememberViewSettings = mkOption {
        type = types.bool;
        default = true;
        description = "Relembrar configurações de exibição específicas para cada pasta no Thunar (misc-directory-specific-settings).";
      };

      restoreTabs = mkOption {
        type = types.bool;
        default = true;
        description = "Restaurar abas abertas anteriormente ao iniciar o Thunar (last-restore-tabs).";
      };
    };
  };

  config = mkIf cfg.enable {
    # Configuração de preferências de visualização por pasta e restauração de abas no Thunar.
    # O arquivo ~/.config/xfce4/xfconf/xfce-perchannel-xml/thunar.xml é o backend nativo do Xfconf.
    # Evita o módulo interno xfconf.settings do Home Manager (load-xfconf) que falha com
    # 'Failed to set property' em distros standalone onde o xfconfd não está ativo durante a ativação.
    home.activation.configureThunarSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.python3}/bin/python3 -c '
import os
import xml.etree.ElementTree as ET

xml_dir = os.path.expanduser("~/.config/xfce4/xfconf/xfce-perchannel-xml")
xml_file = os.path.join(xml_dir, "thunar.xml")
os.makedirs(xml_dir, exist_ok=True)

tree = None
root = None

if os.path.isfile(xml_file):
    try:
        tree = ET.parse(xml_file)
        root = tree.getroot()
    except Exception:
        root = None

if root is None or root.tag != "channel":
    root = ET.Element("channel", attrib={"name": "thunar", "version": "1.0"})
    tree = ET.ElementTree(root)

settings = {
    "misc-directory-specific-settings": "${if cfg.rememberViewSettings then "true" else "false"}",
    "last-restore-tabs": "${if cfg.restoreTabs then "true" else "false"}",
}

for name, val in settings.items():
    prop = root.find(f"./property[@name=\"{name}\"]")
    if prop is None:
        ET.SubElement(root, "property", attrib={"name": name, "type": "bool", "value": val})
    else:
        prop.set("type", "bool")
        prop.set("value", val)

if hasattr(ET, "indent"):
    ET.indent(tree, space="  ", level=0)

tree.write(xml_file, encoding="UTF-8", xml_declaration=True)
'
      if command -v ${pkgs.xfconf}/bin/xfconf-query >/dev/null 2>&1; then
        $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c thunar -p /misc-directory-specific-settings -n -t bool -s ${if cfg.rememberViewSettings then "true" else "false"} 2>/dev/null || true
        $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c thunar -p /last-restore-tabs -n -t bool -s ${if cfg.restoreTabs then "true" else "false"} 2>/dev/null || true
      fi
    '';

    home.sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules\${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}";
    };

    home.packages = with pkgs; [
      thunar-wrapped
      gvfs
      tumbler
      xarchiver
      file-roller
      ffmpegthumbnailer
      webp-pixbuf-loader
      libgsf
      poppler
      freetype
      xfce4-exo
      catfish
      meld
    ];

    # Bridge FUSE do GVfs (/run/user/<uid>/gvfs) para compatibilidade com aplicações
    # que não possuem suporte nativo à API GIO/GVfs (como mpv, vlc, scripts bash, etc.)
    systemd.user.tmpfiles.rules = mkIf pkgs.stdenv.isLinux [
      "d %t/gvfs 0700 - - - -"
      "L+ %h/Templates - - - - .local/share/templates"
    ];

    systemd.user.services.gvfs-fuse = mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "Virtual filesystem service - GNOME FUSE daemon";
        After = [ "gvfs-daemon.service" ];
        PartOf = [ "default.target" ];
      };
      Service = {
        Type = "simple";
        Environment = [
          "PATH=/run/wrappers/bin:/usr/bin:/bin:${pkgs.fuse3}/bin"
        ];
        ExecStartPre = "-/bin/sh -c 'fusermount3 -u -z %t/gvfs 2>/dev/null || fusermount -u -z %t/gvfs 2>/dev/null || /usr/bin/fusermount3 -u -z %t/gvfs 2>/dev/null || /usr/bin/fusermount -u -z %t/gvfs 2>/dev/null || true; mkdir -p %t/gvfs'";
        ExecStart = "${pkgs.gvfs}/libexec/gvfsd-fuse -f %t/gvfs";
        ExecStop = "-/bin/sh -c 'fusermount3 -u -z %t/gvfs 2>/dev/null || fusermount -u -z %t/gvfs 2>/dev/null || /usr/bin/fusermount3 -u -z %t/gvfs 2>/dev/null || /usr/bin/fusermount -u -z %t/gvfs 2>/dev/null || true'";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
    };

    home.file = {
      # Modelos padrão para o menu "Criar Documento" do Thunar
      ".local/share/templates/Documento de Texto.txt".text = "";
      ".local/share/templates/Arquivo Vazio".text = "";

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
      ''
      + optionalString (config.system.programs.editors.vscode.enable or false) ''
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
      ''
      + optionalString (config.system.programs.editors.antigravity.enable or false) ''
        <action>
            <icon>code</icon>
            <name>Open in Antigravity</name>
            <unique-id>1612104464586266-1</unique-id>
            <command>antigravity-ide %f</command>
            <description>Abrir projeto no Antigravity AI IDE</description>
            <patterns>*</patterns>
            <startup-notify/>
            <directories/>
            <text-files/>
        </action>
      ''
      + ''
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
                <command>${thunar-wrapped}/bin/thunar admin://%f</command>
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
