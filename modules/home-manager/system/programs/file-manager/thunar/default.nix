{
  config,
  lib,
  pkgs,
  ...
}:
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
    if config.programs ? alacritty && config.programs.alacritty.enable then
      "${pkgs.alacritty}/bin/alacritty --working-directory %f"
    else
      "${pkgs.xfce4-exo}/bin/exo-open --working-directory %f --launch TerminalEmulator";
in
{
  options = {
    system.programs.file-manager.thunar = {
      enable = mkEnableOption "Enable Thunar file manager with plugins, custom actions (uca.xml), and thumbnails support.";
    };
  };

  config = mkIf cfg.enable {
    home.sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules\${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}";
    };

    home.packages = with pkgs; [
      thunar-wrapped
      gvfs
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

    # Bridge FUSE do GVfs (/run/user/<uid>/gvfs) para compatibilidade com aplicações
    # que não possuem suporte nativo à API GIO/GVfs (como mpv, vlc, scripts bash, etc.)
    systemd.user.tmpfiles.rules = mkIf pkgs.stdenv.isLinux [
      "d %t/gvfs 0700 - - - -"
    ];

    systemd.user.services.gvfs-fuse = mkIf pkgs.stdenv.isLinux {
      Unit = {
        Description = "Virtual filesystem service - GNOME FUSE daemon";
        After = [ "gvfs-daemon.service" ];
        PartOf = [ "default.target" ];
      };
      Service = {
        Type = "simple";
        ExecStartPre = "-/bin/sh -c 'type -p fusermount3 >/dev/null && fusermount3 -u -z %t/gvfs 2>/dev/null || type -p fusermount >/dev/null && fusermount -u -z %t/gvfs 2>/dev/null || true; mkdir -p %t/gvfs'";
        ExecStart = "${pkgs.gvfs}/libexec/gvfsd-fuse -f %t/gvfs";
        ExecStop = "-/bin/sh -c 'type -p fusermount3 >/dev/null && fusermount3 -u -z %t/gvfs 2>/dev/null || type -p fusermount >/dev/null && fusermount -u -z %t/gvfs 2>/dev/null || true'";
        Restart = "on-failure";
        RestartSec = 3;
      };
      Install = {
        WantedBy = [ "default.target" ];
      };
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
                <command>${pkgs.polkit}/bin/pkexec ${thunar-wrapped}/bin/thunar %f</command>
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
