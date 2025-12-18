{ config, lib, pkgs, desktop, osConfig ? null, ... }:
let
  inherit (lib) optionals mkIf;
  isNixOS = osConfig != null;
in
{
  imports = [
    ./backend
  ] ++
  optionals (builtins.pathExists (./. + "/environment/${desktop}")) [
    (./. + "/environment/${desktop}")
  ];

  config = {
    home = {
      packages = (with pkgs; [
        font-search # show existent fonts
        nerd-fonts.symbols-only
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
        data =
          if isNixOS then [ "${config.home.homeDirectory}/.nix-profile/share/applications" ]
          else [ "${config.home.homeDirectory}/.local/share/applications" ];
        config = [ "/etc/xdg" ];
      };
      # desktopEntries.enable = true;
    };

    targets.genericLinux.enable = !isNixOS;
  };
}
