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

  isDark = (config.desktop.theme.variant or "dark") == "dark";
  themeName =
    if config.desktop.theme ? gtk && config.desktop.theme.gtk ? name then
      config.desktop.theme.gtk.name
    else if config.gtk ? theme && config.gtk.theme ? name then
      config.gtk.theme.name
    else
      "";
  themePackage =
    if config.desktop.theme ? gtk && config.desktop.theme.gtk ? package then
      config.desktop.theme.gtk.package
    else if config.gtk ? theme && config.gtk.theme ? package then
      config.gtk.theme.package
    else
      null;
  iconPackage =
    if config.desktop.theme ? icons && config.desktop.theme.icons ? package then
      config.desktop.theme.icons.package
    else if config.gtk ? iconTheme && config.gtk.iconTheme ? package then
      config.gtk.iconTheme.package
    else
      null;

  themeDataDir = lib.optionalString (themePackage != null) "${themePackage}/share:";
  iconDataDir = lib.optionalString (iconPackage != null) "${iconPackage}/share:";

  # Wrapper para garantir suporte a GVfs (Samba/SMB, Rede, Lixeira, MTP), temas GTK e integração completa no Thunar
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
            --prefix XDG_DATA_DIRS : "$out/share:${thunar-with-plugins}/share:${pkgs.gvfs}/share:${pkgs.tumbler}/share:${pkgs.xfconf}/share:${pkgs.shared-mime-info}/share:${themeDataDir}${iconDataDir}${config.home.homeDirectory}/.local/share:${config.home.homeDirectory}/.nix-profile/share:/usr/local/share:/usr/share" \
            --set-default GTK_APPLICATION_PREFER_DARK_THEME "${if isDark then "1" else "0"}" \
            --run '
              _clean_theme="''${GTK_THEME%%:*}"
              if [ -z "$_clean_theme" ] || [ ! -d "$HOME/.themes/$_clean_theme" -a ! -d "$HOME/.local/share/themes/$_clean_theme" -a ! -d "/usr/share/themes/$_clean_theme" ]; then
                export GTK_THEME="${themeName}${if isDark then ":dark" else ""}"
              fi
            '
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

      package = mkOption {
        type = types.package;
        default = thunar-wrapped;
        description = "Pacote do Thunar empacotado com plugins, GVfs e temas.";
      };

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
    xdg.dataFile = {
      "dbus-1/services/org.xfce.Xfconf.service".text = ''
        [D-BUS Service]
        Name=org.xfce.Xfconf
        Exec=${pkgs.xfconf}/lib/xfce4/xfconf/xfconfd
      '';
    };

    systemd.user = mkIf pkgs.stdenv.isLinux {
      services.xfconfd = {
        Unit = {
          Description = "Xfce Configuration Daemon";
          PartOf = [ "graphical-session.target" ];
        };
        Service = {
          Type = "dbus";
          BusName = "org.xfce.Xfconf";
          ExecStart = "${pkgs.xfconf}/lib/xfce4/xfconf/xfconfd";
          Restart = "on-failure";
          RestartSec = 3;
          Environment = [
            "XDG_DATA_DIRS=${pkgs.xfconf}/share:/usr/local/share:/usr/share"
          ];
        };
        Install = {
          WantedBy = [
            "graphical-session.target"
            "default.target"
          ];
        };
      };
    };

    home = {
      packages = with pkgs; [
        cfg.package
        gvfs
        xfconf
        xarchiver
        file-roller
        xfce4-exo
        catfish
        meld
      ];

      # Configuração de preferências de visualização por pasta, restauração de abas e sincronização de tema no Thunar.
      activation.configureThunarSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
              # Encerra instâncias ativas do Thunar para aplicar mudanças de canal e recarregar conexão com xfconfd
              $DRY_RUN_CMD ${pkgs.thunar}/bin/thunar -q 2>/dev/null || true
              $DRY_RUN_CMD ${pkgs.procps}/bin/pkill -9 -i -f thunar 2>/dev/null || true

              # Escreve a configuração declarativa diretamente no XML dos canais Thunar e Xsettings
              $DRY_RUN_CMD ${pkgs.python3}/bin/python3 -c '
        import os
        import xml.etree.ElementTree as ET

        xml_dir = os.path.expanduser("~/.config/xfce4/xfconf/xfce-perchannel-xml")
        os.makedirs(xml_dir, exist_ok=True)

        def load_or_create(channel):
            xml_file = os.path.join(xml_dir, f"{channel}.xml")
            tree = None
            root = None
            if os.path.isfile(xml_file):
                try:
                    tree = ET.parse(xml_file)
                    root = tree.getroot()
                except Exception:
                    root = None
            if root is None or root.tag != "channel":
                root = ET.Element("channel", attrib={"name": channel, "version": "1.0"})
                tree = ET.ElementTree(root)
            return tree, root, xml_file

        # Canal thunar.xml
        t_tree, t_root, t_file = load_or_create("thunar")
        t_settings = {
            "misc-directory-specific-settings": "${if cfg.rememberViewSettings then "true" else "false"}",
            "last-restore-tabs": "${if cfg.restoreTabs then "true" else "false"}",
        }
        for name, val in t_settings.items():
            prop = t_root.find(f"./property[@name=\"{name}\"]")
            if prop is None:
                ET.SubElement(t_root, "property", attrib={"name": name, "type": "bool", "value": val})
            else:
                prop.set("type", "bool")
                prop.set("value", val)

        if hasattr(ET, "indent"):
            ET.indent(t_tree, space="  ", level=0)
        t_tree.write(t_file, encoding="UTF-8", xml_declaration=True)

        # Canal xsettings.xml (Tema GTK, ícones, cursor e fonte para apps XFCE como Thunar)
        x_tree, x_root, x_file = load_or_create("xsettings")
        def set_nested(root_node, path, ptype, pvalue):
            parts = path.strip("/").split("/")
            curr = root_node
            for i, part in enumerate(parts):
                is_leaf = (i == len(parts) - 1)
                node = curr.find(f"./property[@name=\"{part}\"]")
                if node is None:
                    attrs = {"name": part}
                    if is_leaf:
                        attrs["type"] = ptype
                        attrs["value"] = str(pvalue)
                    else:
                        attrs["type"] = "empty"
                    node = ET.SubElement(curr, "property", attrib=attrs)
                else:
                    if is_leaf:
                        node.set("type", ptype)
                        node.set("value", str(pvalue))
                curr = node

        theme_name = "${themeName}"
        icon_name = "${if config.desktop.theme ? icons && config.desktop.theme.icons ? name then config.desktop.theme.icons.name else config.gtk.iconTheme.name or ""}"
        cursor_name = "${config.desktop.theme.cursor.name or ""}"
        cursor_size = "${toString (config.desktop.theme.cursor.size or 24)}"
        font_name = "${config.desktop.theme.font.name or "Inter"} ${
          toString (config.desktop.theme.font.size or 10)
        }"

        if theme_name:
            set_nested(x_root, "Net/ThemeName", "string", theme_name)
            set_nested(x_root, "Gtk/ThemeName", "string", theme_name)
        if icon_name:
            set_nested(x_root, "Net/IconThemeName", "string", icon_name)
        if cursor_name:
            set_nested(x_root, "Gtk/CursorThemeName", "string", cursor_name)
            set_nested(x_root, "Gtk/CursorThemeSize", "int", cursor_size)
        if font_name:
            set_nested(x_root, "Gtk/FontName", "string", font_name)
        set_nested(x_root, "Gtk/DecorationLayout", "string", ":minimize,maximize,close")
        set_nested(x_root, "Gtk/ApplicationPreferDarkTheme", "int", "${if isDark then "1" else "0"}")

        if hasattr(ET, "indent"):
            ET.indent(x_tree, space="  ", level=0)
        x_tree.write(x_file, encoding="UTF-8", xml_declaration=True)
        '

              # Reinicia o xfconfd caso o systemd do usuário esteja ativo nesta sessão
              if systemctl --user is-active --quiet xfconfd.service 2>/dev/null; then
                $DRY_RUN_CMD systemctl --user restart xfconfd.service 2>/dev/null || true
              fi

              # Aplica as opções diretamente no barramento Xfconf caso o daemon esteja respondendo
              if command -v ${pkgs.xfconf}/bin/xfconf-query >/dev/null 2>&1; then
                $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c thunar -p /misc-directory-specific-settings -n -t bool -s ${
                  if cfg.rememberViewSettings then "true" else "false"
                } 2>/dev/null || true
                $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c thunar -p /last-restore-tabs -n -t bool -s ${
                  if cfg.restoreTabs then "true" else "false"
                } 2>/dev/null || true
                ${lib.optionalString (themeName != "") ''
                  $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Net/ThemeName -n -t string -s "${themeName}" 2>/dev/null || true
                  $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Gtk/ThemeName -n -t string -s "${themeName}" 2>/dev/null || true
                  $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Gtk/ApplicationPreferDarkTheme -n -t int -s ${if isDark then "1" else "0"} 2>/dev/null || true
                ''}
                ${lib.optionalString (config.gtk ? iconTheme && config.gtk.iconTheme ? name) ''
                  $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Net/IconThemeName -n -t string -s "${config.gtk.iconTheme.name}" 2>/dev/null || true
                ''}
                ${lib.optionalString (config.desktop ? theme && config.desktop.theme ? cursor) ''
                  $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Gtk/CursorThemeName -n -t string -s "${config.desktop.theme.cursor.name}" 2>/dev/null || true
                  $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Gtk/CursorThemeSize -n -t int -s "${toString config.desktop.theme.cursor.size}" 2>/dev/null || true
                ''}
                ${lib.optionalString (config.desktop ? theme && config.desktop.theme ? font) ''
                  $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Gtk/FontName -n -t string -s "${config.desktop.theme.font.name} ${toString config.desktop.theme.font.size}" 2>/dev/null || true
                ''}
                $DRY_RUN_CMD ${pkgs.xfconf}/bin/xfconf-query -c xsettings -p /Gtk/DecorationLayout -n -t string -s ":minimize,maximize,close" 2>/dev/null || true
              fi
      '';

      file = {
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
  };
}
