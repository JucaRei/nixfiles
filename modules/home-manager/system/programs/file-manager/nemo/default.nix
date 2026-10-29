{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib)
    mkIf
    mkMerge
    mkEnableOption
    optionals
    ;

  cfg = config.system.programs.file-manager.nemo;
  shouldInstall = cfg.installPackage && !cfg.useSystemPackage && !cfg.useSystemPackages;

  isVscodeEnabled =
    (config.system.programs.editors.vscode.enable or false) || (config.programs.vscode.enable or false);

  isAntigravityEnabled = config.system.programs.editors.antigravity.enable or false;

  preferredTerminal =
    if config.programs ? alacritty && config.programs.alacritty.enable then
      "${pkgs.alacritty}/bin/alacritty --working-directory %F"
    else
      "x-terminal-emulator";

  # Wrapper para garantir suporte a GVfs (Samba/SMB, Rede, Lixeira, MTP, SFTP) no Nemo
  nemo-wrapped = pkgs.symlinkJoin {
    name = "nemo-wrapped";
    paths = [ cfg.package ];
    nativeBuildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      rm -rf $out/bin
      mkdir -p $out/bin

      for bin in ${cfg.package}/bin/*; do
        if [ -x "$bin" ]; then
          makeWrapper "$bin" "$out/bin/$(basename "$bin")" \
            --prefix GIO_EXTRA_MODULES : "${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules" \
            --prefix XDG_DATA_DIRS : "${pkgs.gvfs}/share:${pkgs.gsettings-desktop-schemas}/share:${pkgs.cinnamon-desktop}/share:${cfg.package}/share:${pkgs.tumbler}/share:${pkgs.shared-mime-info}/share:/usr/share"
        fi
      done
    '';
  };
in
{
  options = {
    system.programs.file-manager.nemo = {
      enable = mkEnableOption "Enable Nemo file manager (Cinnamon) with GVfs, thumbnailers, extensions, and custom actions.";

      installPackage = lib.my.mkBool true ''
        Se deve instalar o executável do Nemo compilado via Nix/Home Manager.
        Se false, utiliza o binário da distro nativa (ex: /usr/bin/nemo), mantendo ações, configurações e dotfiles.
      '';

      useSystemPackage = lib.my.mkBool false ''
        Atalho conveniente: quando true, equivale a installPackage = false.
        Permite carregar apenas configurações e ações preservando o Nemo nativo do sistema.
      '';

      useSystemPackages = lib.my.mkBool false "Alias para useSystemPackage.";

      package = lib.my.mkPkg pkgs.nemo-with-extensions "Pacote do Nemo a ser utilizado (padrão com extensões compiladas).";

      view = {
        defaultView = lib.my.mkEnum [
          "icon-view"
          "compact-view"
          "list-view"
        ] "icon-view" "Modo de visualização padrão no Nemo.";

        showHiddenFiles = lib.my.mkBool false "Exibir arquivos ocultos por padrão.";

        showFullPathTitles = lib.my.mkBool true "Exibir caminho completo no título da janela.";
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      # Pacotes essenciais, geradores de miniaturas e integração
      packages =
        optionals shouldInstall [
          nemo-wrapped
        ]
        ++ [
          pkgs.gvfs
          pkgs.file-roller
          pkgs.ffmpegthumbnailer
          pkgs.webp-pixbuf-loader
          pkgs.poppler
          pkgs.libgsf
          pkgs.freetype
          pkgs.meld
          pkgs.zenity
          pkgs.imagemagick
          pkgs.qrencode
        ];

      # Modelos e Nemo Actions personalizadas (~/.local/share/nemo/actions/)
      file = mkMerge [
        {
          ".local/share/templates/Documento de Texto.txt".text = "";
          ".local/share/templates/Arquivo Vazio".text = "";

          # Ações de Contexto do Nemo
          ".local/share/nemo/actions/open-terminal.nemo_action".text = ''
            [Nemo Action]
            Active=true
            Name=Abrir no Terminal
            Comment=Abrir pasta atual no terminal
            Exec=${preferredTerminal}
            Icon-Name=utilities-terminal
            Selection=Any
            Extensions=dir;
          '';

          ".local/share/nemo/actions/open-as-root.nemo_action".text = ''
            [Nemo Action]
            Active=true
            Name=Abrir como Administrador
            Comment=Abrir diretório com privilégios de root
            Exec=pkexec env DISPLAY="$DISPLAY" XAUTHORITY="$XAUTHORITY" WAYLAND_DISPLAY="$WAYLAND_DISPLAY" nemo %F
            Icon-Name=system-file-manager-root
            Selection=Any
            Extensions=dir;
          '';

          ".local/share/nemo/actions/compare-meld.nemo_action".text = ''
            [Nemo Action]
            Active=true
            Name=Comparar com Meld
            Comment=Comparar arquivos ou diretórios selecionados
            Exec=${pkgs.meld}/bin/meld %F
            Icon-Name=org.gnome.Meld
            Selection=Any
            Extensions=any;
          '';

          ".local/share/nemo/actions/checksum.nemo_action".text = ''
            [Nemo Action]
            Active=true
            Name=Verificar Checksum (SHA256)
            Comment=Calcular hash SHA256 do arquivo selecionado
            Exec=sh -c 'H=$(sha256sum "%F" | awk "{print \$1}"); if command -v zenity >/dev/null; then echo "$H" | zenity --text-info --title="Checksum SHA256" --width=500 --height=200; else notify-send "SHA256" "$H"; fi'
            Icon-Name=dialog-information
            Selection=s
            Extensions=nodirs;
          '';
        }
        (mkIf isVscodeEnabled {
          ".local/share/nemo/actions/open-vscode.nemo_action".text = ''
            [Nemo Action]
            Active=true
            Name=Abrir no VSCode
            Comment=Abrir no Visual Studio Code
            Exec=code %F
            Icon-Name=code
            Selection=Any
            Extensions=any;
          '';
        })
        (mkIf isAntigravityEnabled {
          ".local/share/nemo/actions/open-antigravity.nemo_action".text = ''
            [Nemo Action]
            Active=true
            Name=Abrir no Antigravity IDE
            Comment=Abrir no Antigravity AI IDE
            Exec=antigravity-ide %F
            Icon-Name=code
            Selection=Any
            Extensions=any;
          '';
        })
      ];
    };

    # Configurações dconf / GSettings para Nemo
    dconf.settings = {
      "org/nemo/preferences" = {
        show-hidden-files = cfg.view.showHiddenFiles;
        show-full-path-titles = cfg.view.showFullPathTitles;
        show-advanced-permissions = true;
        confirm-trash = true;
        default-folder-viewer = cfg.view.defaultView;
        date-format = "iso";
        show-compact-view-icon-toolbar = true;
      };

      "org/nemo/list-view" = {
        default-zoom-level = "small";
      };

      "org/nemo/icon-view" = {
        default-zoom-level = "standard";
      };
    };
  };
}
