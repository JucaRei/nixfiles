{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkDefault
    mkEnableOption
    mkOption
    types
    optionalString
    optionals
    ;

  cfg = config.system.programs.file-manager.pcmanfm;
  shouldInstall = cfg.installPackage && !cfg.useSystemPackage && !cfg.useSystemPackages;

  preferredTerminal =
    if config.programs ? alacritty && config.programs.alacritty.enable then
      "${pkgs.alacritty}/bin/alacritty"
    else
      "x-terminal-emulator";

  # Wrapper para garantir suporte a GVfs (Samba/SMB, Rede, Lixeira, MTP, SFTP) no PCManFM
  pcmanfm-wrapped = pkgs.symlinkJoin {
    name = "pcmanfm-wrapped";
    paths = [ cfg.package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -rf $out/bin
      mkdir -p $out/bin

      for bin in ${cfg.package}/bin/*; do
        if [ -x "$bin" ]; then
          makeWrapper "$bin" "$out/bin/$(basename "$bin")" \
            --prefix GIO_EXTRA_MODULES : "${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules" \
            --prefix XDG_DATA_DIRS : "${pkgs.gvfs}/share:${pkgs.gsettings-desktop-schemas}/share:${cfg.package}/share:/usr/share"
        fi
      done
    '';
  };
in
{
  options = {
    system.programs.file-manager.pcmanfm = {
      enable = mkEnableOption "Enable PCManFM ultra-lightweight file manager with GVfs, thumbnailers, and tabbed browsing.";

      defaultFileManager = mkOption {
        type = types.bool;
        default = true;
        description = "Definir PCManFM como gerenciador de arquivos padrão no XDG MIME (inode/directory).";
      };

      installPackage = mkOption {
        type = types.bool;
        default = true;
        description = ''
          Se deve instalar o executável do PCManFM compilado via Nix/Home Manager.
          Se false, utiliza o binário da distro nativa (ex: /usr/bin/pcmanfm), mantendo configurações e dotfiles.
        '';
      };

      useSystemPackage = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Atalho conveniente: quando true, equivale a installPackage = false.
          Permite carregar apenas as configurações preservando o PCManFM do sistema hospedeiro.
        '';
      };

      useSystemPackages = mkOption {
        type = types.bool;
        default = false;
        description = "Alias para useSystemPackage.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.pcmanfm;
        description = "Pacote do PCManFM a ser utilizado.";
      };

      view = {
        viewMode = mkOption {
          type = types.enum [
            "icon"
            "compact"
            "detailed"
            "thumbnail"
          ];
          default = "detailed";
          description = "Modo de visualização padrão de arquivos.";
        };

        showHidden = mkOption {
          type = types.bool;
          default = false;
          description = "Mostrar arquivos ocultos por padrão.";
        };
      };
    };
  };

  config = mkIf cfg.enable {
    # Variáveis de sessão para suporte a GVfs
    home.sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules\${GIO_EXTRA_MODULES:+:$GIO_EXTRA_MODULES}";
    };

    # Pacotes essenciais, descompactadores e geradores de miniaturas
    home.packages =
      optionals shouldInstall [
        pcmanfm-wrapped
      ]
      ++ [
        pkgs.gvfs
        pkgs.xarchiver
        pkgs.ffmpegthumbnailer
        pkgs.webp-pixbuf-loader
        pkgs.poppler
        pkgs.libgsf
        pkgs.freetype
        pkgs.meld
        pkgs.zenity
      ];

    # Arquivo de configuração declarativo do PCManFM (~/.config/pcmanfm/default/pcmanfm.conf)
    home.file = {
      ".local/share/templates/Documento de Texto.txt".text = "";
      ".local/share/templates/Arquivo Vazio".text = "";

      ".config/pcmanfm/default/pcmanfm.conf".text = ''
        [config]
        bm_open_method=0

        [volume]
        mount_on_startup=1
        mount_removable=1
        autorun=1

        [ui]
        always_show_tabs=1
        max_tab_chars=32
        win_width=900
        win_height=560
        splitter_pos=160
        view_mode=${cfg.view.viewMode}
        show_hidden=${if cfg.view.showHidden then "1" else "0"}
        sort_type=name
        sort_by=ascending
        terminal=${preferredTerminal}
      '';
    };

    # Bridge FUSE do GVfs (/run/user/<uid>/gvfs)
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
          "PATH=/run/wrappers/bin:${pkgs.fuse3}/bin:/usr/bin:/bin"
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
  };
}
