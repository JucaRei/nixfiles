{ pkgs, lib, config, ... }:
let
  inherit (lib) mkIf mkForce mkEnableOption concatMapStringsSep;
  cfg = config.programs.graphical.apps.file-manager.thunar;

  thunar-with-plugins = with pkgs.xfce; (thunar.override {
    thunarPlugins = [ thunar-volman thunar-archive-plugin thunar-media-tags-plugin ];
  });
  finalThunar = thunar-with-plugins;
in
{
  options = {
    programs.graphical.apps.file-manager.thunar = {
      enable = mkEnableOption "Enable's thunar with configurations.";
    };
  };
  config = mkIf cfg.enable {
    home =
      let
        gio = pkgs.gnome.gvfs;
      in
      {
        packages = with pkgs.xfce; [
          exo
          finalThunar
          tumbler # file thumbnails
          catfish # search tool
        ]
        ++ (with pkgs; [
          xarchiver # archiver
          webp-pixbuf-loader # .webp
          gio # Virtual Filesystem support library
          cifs-utils # Tools for managing Linux CIFS client filesystems
          zip
          unzip
          poppler # .pdf .ps
          libgsf # .odf
          freetype # fonts
          libgepub # .epub
          ffmpegthumbnailer # videos
        ]);

        sessionVariables = {
          GIO_EXTRA_MODULES = "${gio}/lib/gio/modules";
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
                    <icon>gitahead</icon>
                    <name>Open with gitahead</name>
                    <unique-id>1587287434852027-1</unique-id>
                    <command>gitahead %F</command>
                    <description>Open with gitahead</description>
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
          '';
        };
      };

    xfconf.settings = {
      thunar =
        let
          commaList = concatMapStringsSep "," (lib.escape [ "," ]);
          listToCommaStringList = l: commaList (map builtins.toString l);
        in
        {
          # last-menubar-visible = false;
          # last-separator-position = 181;
          last-restore-tabs = true;

          # last-image-preview-visible = false;
          # last-toolbar-item-order = "0,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20";
          # last-toolbar-visible-buttons = "0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0";
          last-statusbar-visible = false;
          # last-location-bar = "void";

          misc-full-path-in-tab-title = false;

          # View defaults: compact view
          last-compact-view-zoom-level = "THUNAR_ZOOM_LEVEL_50_PERCENT";

          # View defaults: details view
          last-details-view-zoom-level = "THUNAR_ZOOM_LEVEL_38_PERCENT";

          # Display > View settings
          misc-folders-first = true; # Sort folders before files
          misc-file-size-binary = true;

          # Display > Icon view
          misc-text-beside-icons = true;

          # Display > Window icon
          misc-change-window-icon = false;
          misc-full-path-in-window-title = true; # hidden

          # Advaned > Volume management
          misc-volume-management = false;

          last-details-view-column-order = commaList [
            "THUNAR_COLUMN_NAME"
            "THUNAR_COLUMN_DATE_MODIFIED"
            "THUNAR_COLUMN_PERMISSIONS"
            "THUNAR_COLUMN_SIZE"
            "THUNAR_COLUMN_MIME_TYPE"

            "THUNAR_COLUMN_TYPE"
            "THUNAR_COLUMN_OWNER"
            "THUNAR_COLUMN_GROUP"
            "THUNAR_COLUMN_SIZE_IN_BYTES"
            "THUNAR_COLUMN_LOCATION"
            "THUNAR_COLUMN_DATE_CREATED"
            "THUNAR_COLUMN_DATE_ACCESSED"
            "THUNAR_COLUMN_RECENCY"
            "THUNAR_COLUMN_DATE_DELETED"
          ];

          last-details-view-visible-columns = commaList [
            "THUNAR_COLUMN_NAME"
            "THUNAR_COLUMN_DATE_MODIFIED"
            "THUNAR_COLUMN_PERMISSIONS"
            "THUNAR_COLUMN_SIZE"
            "THUNAR_COLUMN_MIME_TYPE"
          ];

          last-sort-column = "THUNAR_COLUMN_NAME";
          last-sort-order = "GTK_SORT_ASCENDING";
          misc-case-sensitive = true; # Use case sensitive sorting (and thus show hidden files first)

          last-details-view-fixed-columns = false; # Column sizing > Automatically expand columns as needed
          misc-folder-item-count = "THUNAR_FOLDER_ITEM_COUNT_ALWAYS"; # Column sizing > Size column of folders > Show number of containing items: Always

          # View defaults: icon view
          last-icon-view-zoom-level = "THUNAR_ZOOM_LEVEL_150_PERCENT";
          misc-highlighting-enabled = true; # Use different highlight style (hidden)

          # View defaults: default view
          default-view = "void"; # View new folders using "last active view"
          last-view = "ThunarCompactView"; # "ThunarIconView";
          last-show-hidden = true;

          # Display > Date
          # misc-date-style = "THUNAR_DATE_STYLE_ISO";
          misc-date-style = "THUNAR_DATE_STYLE_CUSTOM";
          misc-date-custom-style = "%Y-%m-%d %I:%M:%S %p";

          # Advanced > Search
          misc-recursive-search = "THUNAR_RECURSIVE_SEARCH_ALWAYS"; # Include subfolders

          # Advanced > File transfer
          misc-parallel-copy-mode = "THUNAR_PARALLEL_COPY_MODE_ONLY_LOCAL"; # Transfer files in parallel
          misc-transfer-use-partial = "THUNAR_USE_PARTIAL_MODE_REMOTE"; # Use intermediate file on copy
          misc-transfer-verify-file = "THUNAR_VERIFY_FILE_MODE_NEVER"; # Don't verify file checksums on copy

          # Side pane > Image preview
          misc-image-preview-mode = "THUNAR_IMAGE_PREVIEW_MODE_STANDALONE"; # "THUNAR_IMAGE_PREVIEW_MODE_EMBEDDED";

          # Display > View settings
          misc-confirm-close-multiple-tabs = false;
          misc-open-new-window-as-tab = true;

          # Display > Thumbnails
          misc-thumbnail-mode = "THUNAR_THUMBNAIL_MODE_ONLY_LOCAL"; # Local files only
          misc-thumbnail-draw-frames = true;
          misc-thumbnail-max-file-size = 1048576 * 100; # Only show thumbnails for files smaller than 100MiB

          last-location-bar = "ThunarLocationEntry"; # View > Location selector > Buttons style
          last-side-pane = "void"; # View > Side pane
          last-menubar-visible = false; # View > Menubar

          misc-middle-click-in-tab = true;
          misc-single-click = false;
          misc-show-delete-action = true;

          # Toolbar items
          last-toolbar-item-order = listToCommaStringList [
            14 # Location bar
            10 # Icon view
            11 # Details view
            12 # Compact view
            0 # Show menubar

            1
            2
            3
            4
            5
            6
            7
            8
            9
            15
            13
            16
            17
          ];
          last-toolbar-visible-buttons = listToCommaStringList [
            1 # Location bar
            1 # Icon view
            1 # Details view
            1 # Compact view
            0 # Show menubar

            0
            0
            0
            0
            0
            0
            0
            0
            0
            0
            0
            0
            0
          ];

          # Status bar information
          misc-status-bar-active-info = 31; # Size, Size in bytes, Filetype, Display name, Last modified
          misc-image-size-in-statusbar = true;

          misc-show-about-templates = false; # Don't show "about templates" dialog

          hidden-bookmarks = [
            "file://${config.home.homeDirectory}/Desktop"
            "computer:///"
            "network:///"
          ];

          shortcuts-icon-size = "THUNAR_ICON_SIZE_16";
          shortcuts-icon-emblems = true;
          tree-icon-size = "THUNAR_ICON_SIZE_16";
          tree-icon-emblems = true;
        };
    };

    # Use monospace in Thunar's details view
    # gtk.gtk3.extraCss = ''
    #   window.thunar grid paned paned grid paned notebook scrolledwindow treeview {
    #     font: monospace;
    #     font-size: 10pt;
    #   }
    # '';

    # xdg.mimeApps = mkForce {
    #   defaultApplications = { "inode/directory" = [ "thunar.desktop" ]; };
    #   associations.added = { "inode/directory" = [ "thunar.desktop" ]; };
    # };

    system.services.defaultApps = {
      enable = true;
      defaultFileManager = "thunar.desktop";
    };

    systemd.user.services.thunar = {
      Unit = {
        Description = "Thunar file manager";
        Documentation = "man:Thunar(1)";
      };
      Service = {
        Type = "dbus";
        ExecStart = "${finalThunar}/bin/Thunar --daemon";
        WantedBy = [ "graphical-session.target" ];
        BusName = "org.xfce.FileManager";
        KillMode = "process";
        # NOTE: PATH is necessary for when thunar is launched by browsers
        PassEnvironment = [ "PATH" ];
      };
    };
  };
}
