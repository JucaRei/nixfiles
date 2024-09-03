{ config, lib, hostname, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  imports = [ ];
  home = {
    file = {
      # ".ssh/config".text = ''
      #   Host github.com
      #     HostName github.com
      #     User git

      #   # Host man
      #   #   HostName man.wimpress.io

      #   # Host yor
      #   #   HostName yor.wimpress.io

      #   # Host man.ubuntu-mate.net
      #   #   HostName man.ubuntu-mate.net
      #   #   User matey
      #   #   IdentityFile ~/.ssh/id_rsa_semaphore

      #   # Host yor.ubuntu-mate.net
      #   #   HostName yor.ubuntu-mate.net
      #   #   User matey
      #   #   IdentityFile ~/.ssh/id_rsa_semaphore

      #   # Host bazaar.launchpad.net
      #   #   User flexiondotorg

      #   # Host git.launchpad.net
      #   #   User flexiondotorg

      #   # Host ubuntu.com
      #   #   HostName people.ubuntu.com
      #   #   User flexiondotorg

      #   # Host people.ubuntu.com
      #   #   User flexiondotorg

      #   # Host ubuntupodcast.org
      #   #   HostName live.ubuntupodcast.org
      # '';
      "virtualmachines/nixos-console.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-console/disk.qcow2"
        disk_size="20G"
        iso="nixos-console/nixos.iso"
      '';
      "virtualmachines/nixos-desktop.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-desktop/disk.qcow2"
        disk_size="20G"
        iso="nixos-desktop/nixos.iso"
      '';

      # List home-manager packages
      ".config/home-manager/home-manager_local-packages.txt" = {
        text =
          let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
          "${formatted}";
      };
    };
    # A Modern Unix experience
    # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
    packages = with pkgs;
      lib.mkDefault [
      ];
    extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
  };
  programs = {
    home-manager = lib.mkDefault {
      enable = true;
    };
  };

  services = {
    home-manager = {
      autoUpgrade = {
        enable = false;
      };
    };
  };

  systemd.user.tmpfiles.rules = lib.mkIf isLinux [
    "d ${config.home.homeDirectory}/workspace 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/windows 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/mac 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/docker 0750 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/lab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/scripts 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/OVAs 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Youtube 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/playlists 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/albums 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/singles 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/artits 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/downloads 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/records 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/games 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/nixos-desktop 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/nixos-console 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/family 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/backup 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/phones 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/screenshots 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/wallpapers 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/resources 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
  ];
}
