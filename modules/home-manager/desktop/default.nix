{ config, lib, pkgs, desktop, osConfig ? null, ... }:
let
  inherit (lib) optionals mkIf mkForce;
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
        linkDesktopApplications = mkIf (!isNixOS) {
          # Add Packages To System Menu by updating database
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          data = ''
            rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
            rm -rf ${config.home.homeDirectory}/.icons/nix-icons
            mkdir -p ${config.home.homeDirectory}/.local/share/applications/home-manager
            mkdir -p ${config.home.homeDirectory}/.icons
            ln -sf ${config.home.homeDirectory}/.nix-profile/share/icons ${config.home.homeDirectory}/.icons/nix-icons

            # Check if the cached desktop files list exists
            if [ -f ${config.home.homeDirectory}/.cache/current_desktop_files.txt ]; then
              current_files=$(cat ${config.home.homeDirectory}/.cache/current_desktop_files.txt)
            else
              current_files=""
            fi

            # Symlink new desktop entries
            for desktop_file in ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop; do
              if ! echo "$current_files" | grep -q "$(basename $desktop_file)"; then
                ln -sf "$desktop_file" ${config.home.homeDirectory}/.local/share/applications/home-manager/$(basename $desktop_file)
              fi
            done

            # Update desktop database
            ${pkgs.desktop-file-utils}/bin/update-desktop-database ${config.home.homeDirectory}/.local/share/applications
          '';
        };

        "user-dirs" = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
          rm -f $VERBOSE_ARG "$HOME/.config/user-dirs.dirs.old"
        '';
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    programs.bash.profileExtra = lib.mkAfter ''
      rm -rf ${config.home.homeDirectory}/.local/share/applications/home-manager
      rm -rf ${config.home.homeDirectory}/.icons/nix-icons
      ls ${config.home.homeDirectory}/.nix-profile/share/applications/*.desktop > ${config.home.homeDirectory}/.cache/current_desktop_files.txt
    '';

    xdg = {
      enable = mkForce true;
      mimeApps.enable = true;
      mime.enable = true;
      # systemDirs = {
      #   data =
      #     if isNixOS then [ "${config.home.homeDirectory}/.nix-profile/share/applications" ]
      #     else [ "${config.home.homeDirectory}/.local/share/applications" ];
      #   config = [ "/etc/xdg" ];
      # };
      # desktopEntries.enable = true;
    };

    targets.genericLinux.enable = !isNixOS;
  };
}
