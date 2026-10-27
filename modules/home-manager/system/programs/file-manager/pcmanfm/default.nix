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
            --prefix XDG_DATA_DIRS : "${pkgs.gvfs}/share:${pkgs.gsettings-desktop-schemas}/share:${cfg.package}/share:${pkgs.tumbler}/share:${pkgs.shared-mime-info}/share:/usr/share"
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
    home = {
      # Pacotes essenciais, descompactadores e geradores de miniaturas
      packages =
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
      file = {
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
    };
  };
}
