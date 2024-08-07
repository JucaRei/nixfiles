{ config, lib, pkgs, hostname, username, inputs, ... }:
with lib;
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  cfg = config.services.nonNixOs;
  isOld = if (hostname == "oldarch") then false else true;
in
{
  options.services.nonNixOs = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        # niv
        # nix
        # nixgl.auto.nixGLDefault
        nix-output-monitor
        nixpkgs-fmt
        nil
        # alejandra
        # rnix-lsp
        # base-packages
        # fzf
        # tmux
      ] ++ (with pkgs; optionals (isOld) [ nixgl.auto.nixGLDefault ]);
      # OpenGL for GUI apps


      # file.".config/nix/nix.conf".text = ''
      #   experimental-features = nix-command flakes
      # '';
      # extraProfileCommands = ''
      #   if [[ -d "$out/share/applications" ]] ; then
      #     ${pkgs.desktop-file-utils}/bin/update-desktop-database $out/share/applications
      #   fi
      # '';

      activation = {
        linkDesktopApplications = {
          # Add Packages To System Menu by updating database
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          # data = "sudo --preserve-env=PATH env /usr/bin/update-desktop-database";
          # data = "${pkgs.desktop-file-utils}/bin/update-desktop-database";
          data = "sudo /usr/bin/update-desktop-database";
          # data = ''
          #   rm -rf ${config.xdg.dataHome}/"applications/home-manager"
          #   mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
          #   cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
          # '';
        };
      };
    };
    targets.genericLinux.enable = true;

    # Attempt to work around dbus user service not including ~/.nix-profile/share
    # in XDG_DATA_DIRS
    # xdg = {
    #   systemDirs.data = [ "/home/${username}/.nix-profile/share" ]; # Add Nix Packages to XDG_DATA_DIRS

    #   configFile.dbus-xdg-data-dir-env-override = {
    #     target = "systemd/user/dbus.service.d/override.conf";
    #     text = ''
    #       [Service]
    #       Environment="XDG_DATA_DIRS=/home/${config.home.username}/.local/share/flatpak/exports/share:/var/lib/flatpak/exports/share:/home/${config.home.username}/.nix-profile/share:/etc/profiles/per-user/${config.home.username}/share:/nix/var/nix/profiles/default/share:/run/current-system/sw/share"
    #     '';
    #   };
    # };
  };
}
