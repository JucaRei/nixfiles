{ config, lib, pkgs, osConfig ? null, isWorkstation, ... }:
let
  inherit (lib) mkIf;
  isNixOS = osConfig != null;
in
{
  imports = [
    ./bspwm
    ./xfce4
    ../display-servers
  ];

  config = {

    home = {

      packages = mkIf (!isNixOS) [
        pkgs.nixgl.auto.nixGLDefault
      ] ++ (with pkgs;[
        font-search # show existent fonts
        (nerdfonts.override {
          fonts = [
            "NerdFontsSymbolsOnly"
          ];
        })
      ]);

      activation = {
        linkDestopApplications = mkIf (!isNixOS) {
          # Add Packages To System Menu by updating database
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          data = "${pkgs.desktop-file-utils}/bin/update-desktop-database";
        };

        "user-dirs" = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
          rm -f $VERBOSE_ARG "$HOME/.config/user-dirs.dirs.old"
        '';
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    xdg = {
      mimeApps.enable = true;
      mime.enable = true;
      systemDirs = {
        data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
        config = [ "/etc/xdg" ];
      };
    };

    targets.genericLinux.enable = mkIf (!isNixOS) true;
  };
}
