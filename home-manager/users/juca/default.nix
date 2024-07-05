{ config, lib, hostname, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  imports = [
    # ../../_mixins/fonts
    # ../../_mixins/services/keybase.nix
    # ../../_mixins/services/syncthing.nix
  ];
  home = {
    file = {
      #   ".bazaar/authentication.conf".text = "
      #   [Launchpad]
      #   host = .launchpad.net
      #   scheme = ssh
      #   user = flexiondotorg
      # ";
      # file.".bazaar/bazaar.conf".text = "
      #   [DEFAULT]
      #   email = Reinaldo Pjr <code@test.com>
      #   launchpad_username = dev
      #   mail_client = default
      #   tab_width = 4
      #   [ALIASES]
      # ";
      #file."Development/debian/.envrc".text = "export DEB_VENDOR=Debian";
      #file."Development/ubuntu/.envrc".text = "export DEB_VENDOR=Ubuntu";
      ".ssh/config".text = ''
        Host github.com
          HostName github.com
          User git

        # Host man
        #   HostName man.wimpress.io

        # Host yor
        #   HostName yor.wimpress.io

        # Host man.ubuntu-mate.net
        #   HostName man.ubuntu-mate.net
        #   User matey
        #   IdentityFile ~/.ssh/id_rsa_semaphore

        # Host yor.ubuntu-mate.net
        #   HostName yor.ubuntu-mate.net
        #   User matey
        #   IdentityFile ~/.ssh/id_rsa_semaphore

        # Host bazaar.launchpad.net
        #   User flexiondotorg

        # Host git.launchpad.net
        #   User flexiondotorg

        # Host ubuntu.com
        #   HostName people.ubuntu.com
        #   User flexiondotorg

        # Host people.ubuntu.com
        #   User flexiondotorg

        # Host ubuntupodcast.org
        #   HostName live.ubuntupodcast.org
      '';
      "Quickemu/nixos-console.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-console/disk.qcow2"
        disk_size="20G"
        iso="nixos-console/nixos.iso"
      '';
      "Quickemu/nixos-desktop.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-desktop/disk.qcow2"
        disk_size="20G"
        iso="nixos-desktop/nixos.iso"
      '';

      # List home-manager packages
      ".local/home-manager_packages.txt" = {
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
    # sessionVariables = {
    #   BZR_EMAIL = "Reinaldo P Jr <code@wimpress.io>";
    #   DEBFULLNAME = "Reinaldo P Jr";
    #   DEBEMAIL = "code@wimpress.io";
    #   DEBSIGN_KEYID = "8F04688C17006782143279DA61DF940515E06DA3";
    #   PAGER = "moar";
    # };
    extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
  };
  programs = {
    # git = {
    #   userEmail = "reinaldo.develop@gmail.com";
    #   userName = "Reinaldo P JR ";
    #   signing = {
    #     key = "15E06DA3";
    #     signByDefault = true;
    #   };
    # };

    home-manager = lib.mkDefault {
      enable = true;
      # path = "${config.home.homeDirectory}/home-manager";
    };
  };

  services = {
    home-manager = {
      autoUpgrade = {
        enable = false;
        # frequency = "weekly";
      };
    };
  };

  systemd.user.tmpfiles.rules = lib.mkIf isLinux [
    "d ${config.home.homeDirectory}/Scripts 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Studio/OBS/config/obs-studio/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/Virtualmachines/windows 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/Virtualmachines/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/Virtualmachines/mac 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/docker/docker-configs/resources 0750 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/docker-configs/composes 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/lab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/github 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/bitbucket 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/gitlab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/scripts 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Downloads/Videos 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Downloads/Music 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Downloads/Torrents 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Downloads/Files 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/OVAs 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Youtube 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Youtube/Tutorials 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/playlists 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/albums 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/singles 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/artits 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/downloads 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/records 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Games 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Quickemu/nixos-desktop 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Quickemu/nixos-console 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Syncthing 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/family 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/backup 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/phones 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/screenshots 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/wallpapers 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/resources 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Volatile/Vorta 0755 ${username} users - -"
    "L+ /home/${username}/.config/obs-studio/ - - - - ${config.home.homeDirectory}/Studio/OBS/config/obs-studio/"
  ];
}
