{ pkgs, lib, config, ... }:
let
  thunar-with-plugins = with pkgs.xfce; (thunar.override {
    thunarPlugins = [ thunar-volman thunar-archive-plugin thunar-media-tags-plugin ];
  });
  vars = import ../../desktop/bspwm/vars.nix { inherit pkgs config; };
  _ = lib.getExe;
in
{
  config = {
    home = {
      packages = with pkgs.xfce;
        [
          exo
          thunar-with-plugins
          tumbler # file thumbnails
          catfish # search tool
        ]
        ++ (with pkgs; [
          mate.engrampa # archiver
          zip
          unzip
          libgsf
          ffmpegthumbnailer
        ]);

      file = {
        ".config/Thunar/accels.scm".text = lib.fileContents ../../config/thunar/accels.scm;

        ".config/Thunar/uca.xml".text = ''
          <?xml version="1.0" encoding="UTF-8"?>
          <actions>
              <action>
                  <icon>xterm</icon>
                  <name>Open Terminal Here</name>
                  <unique-id>1612104464586264-1</unique-id>
                  <command>exo-open --working-directory %f --launch alacritty</command>
                  <description>Example for a custom action</description>
                  <patterns>*</patterns>
                  <startup-notify/>
                  <directories/>
              </action>
              <action>
                  <icon>${lib.getExe pkgs.vscode}/share/pixmaps/vscode.png</icon>
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
                  <command>pkexec thunar %f</command>
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
      thunar = {
        "default-view" = "ThunarDetailsView";
        "misc-middle-click-in-tab" = true;
        "misc-open-new-window-as-tab" = true;
        "misc-single-click" = false;
        "misc-volume-management" = false;
      };
    };
  };
}


# ".config/Thunar/uca.xml".text = ''
#             <?xml version="1.0" encoding="UTF-8"?>
#             <actions>
#                 <action>
#                     <icon>xterm</icon>
#                     <name>Open Terminal Here</name>
#                     <unique-id>1612104464586264-1</unique-id>
#                     <command>${pkgs.xfce.exo}/bin/exo-open --working-directory %f --launch "${_ vars.alacritty-custom}"</command>
#                     <command>"${vars.alacritty-custom}/bin/alacritty"</command>
#                     <description>Example for a custom action</description>
#                     <patterns>*</patterns>
#                     <startup-notify/>
#                     <directories/>
#                 </action>
#                 <action>
#                     <icon>code</icon>
#                     <name>Open VSCode Here</name>
#                     <unique-id>1612104464586265-1</unique-id>
#                     <command>code %f</command>
#                     <description></description>
#                     <patterns>*</patterns>
#                     <startup-notify/>
#                     <directories/>
#                 </action>
#                 <action>
#                     <icon>bcompare</icon>
#                     <name>Compare</name>
#                     <submenu></submenu>
#                     <unique-id>1622791692322694-4</unique-id>
#                     <command>${pkgs.meld}/bin/meld %F</command>
#                     <description>Compare files and directories with  meld</description>
#                     <range></range>
#                     <patterns>*</patterns>
#                     <directories/>
#                     <text-files/>
#                 </action>
#             </actions>
#           '';
