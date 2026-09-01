{
  config,
  lib,
  pkgs,
  desktop,
  username,
  isWorkstation,
  ...
}:
let
  inherit (lib) mkIf;
  inherit (pkgs.stdenv) isLinux;
in
{
  config = {
    system.programs.shells = {
      aliases = lib.mkDefault {
        enable = true;
        systemd = {
          enable = true;
        };
        process = {
          enable = true;
        };
        nix = {
          enable = true;
          diffProgram = "nix-diff";
        };
      };
    };

    home = {
      file = {
        ".face" = mkIf (desktop != null) {
          source = "${pkgs.juca-avatar}/share/faces/juca.jpg";
        };
        "lab/vm/nixos-console.conf" = {
          text = ''
            #!/run/current-system/sw/bin/quickemu --vm
            guest_os="linux"
            disk_img="nixos-console/disk.qcow2"
            disk_size="25G"
            iso="nixos-console/nixos.iso"
          '';
        };
        "lab/vm/nixos-gnome.conf" = {
          text = ''
            #!/run/current-system/sw/bin/quickemu --vm
            guest_os="linux"
            disk_img="nixos-gnome/disk.qcow2"
            disk_size="25G"
            iso="nixos-gnome/nixos.iso"
            width="1920"
            height="1080"
          '';
        };
        "lab/vm/nixos-mate.conf" = {
          text = ''
            #!/run/current-system/sw/bin/quickemu --vm
            guest_os="linux"
            disk_img="nixos-mate/disk.qcow2"
            disk_size="25G"
            iso="nixos-mate/nixos.iso"
            width="1920"
            height="1080"
          '';
        };
        "lab/vm/nixos-pantheon.conf" = {
          text = ''
            #!/run/current-system/sw/bin/quickemu --vm
            guest_os="linux"
            disk_img="nixos-pantheon/disk.qcow2"
            disk_size="25G"
            iso="nixos-pantheon/nixos.iso"
            width="1920"
            height="1080"
          '';
        };
        # "/lab/vm/nixos-console/.keep" = mkIf (!isLima) { text = ""; };
        "/lab/vm/nixos-console/.keep" = {
          text = "";
        };
        "/lab/vm/nixos-gnome/.keep" = {
          text = "";
        };
        "/lab/vm/nixos-mate/.keep" = {
          text = "";
        };
        "/lab/vm/nixos-pantheon/.keep" = {
          text = "";
        };
        "/lab/workspace/.keep" = {
          text = "";
        };
        "/.dotfiles/.keep".text = "";

        # List home-manager packages
        ".config/home-manager/installed-packages.txt" = {
          text =
            let
              packages = builtins.map (p: "${p.name}") config.home.packages;
              sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
              formatted = builtins.concatStringsSep "\n" sortedUnique;
            in
            "${formatted}";
        };
      };
    };
    systemd = {
      user.tmpfiles.rules = mkIf (isLinux && isWorkstation) [
        "d ${config.home.homeDirectory}/Documents/docs 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Documents/workspace 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Documents/workspace/lab 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Documents/studies 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Videos/animes/movies 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Videos/animes/series 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Videos/animes/OVAs 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Videos/series 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Videos/movies 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Videos/downloads 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Videos/youtube 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Music/playlists 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Music/albums 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Music/singles 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Music/artists 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Music/downloads 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/lab/vm/windows 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/lab/vm/linux 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/lab/vm/mac 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/lab/vm/nixos-desktop 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/lab/vm/nixos-console 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Pictures/family 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Pictures/backup 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Pictures/phones 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Pictures/screenshots 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Pictures/thumbnails 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Pictures/wallpapers 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/Pictures/resources 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
        "d ${config.home.homeDirectory}/.config/home-manager 0755 ${username} users - -"
      ];
    };

    gtk = mkIf isWorkstation {
      gtk3 = {
        bookmarks = [
          "${config.home.homeDirectory}/Documents/docs"
          "${config.home.homeDirectory}/Documents/workspace"
          "${config.home.homeDirectory}/Documents/studies"
          "${config.home.homeDirectory}/Downloads"
          "${config.home.homeDirectory}/Music"
          "${config.home.homeDirectory}/Pictures"
          "${config.xdg.userDirs.pictures}/screenshots"
          "${config.xdg.userDirs.pictures}/wallpapers"
          "${config.home.homeDirectory}/Videos"
          "${config.home.homeDirectory}/lab/workspace"
        ];
      };
    };
  };
}
