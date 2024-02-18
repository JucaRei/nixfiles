{
  config,
  lib,
  hostname,
  pkgs,
  username,
  nixpkgs,
  ...
}: let
  inherit (pkgs.stdenv) isLinux;
in {
  imports = [
    ../../_mixins/fonts
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
      "${config.home.homeDirectory}/Pictures/wallpapers" = {
        source = ../../_mixins/config/wallpapers;
        recursive = true;
      };
      ".face".source = ./face.jpg;
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
        text = let
          packages = builtins.map (p: "${p.name}") config.home.packages;
          sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
          formatted = builtins.concatStringsSep "\n" sortedUnique;
        in "${formatted}";
      };
    };
    # A Modern Unix experience
    # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
    packages = with pkgs;
      lib.mkDefault [
        # asciinema # Terminal recorder
        # black # Code format Python
        # bmon # Modern Unix `iftop`
        # breezy # Terminal bzr client
        # butler # Terminal Itch.io API client
        # chafa # Terminal image viewer
        # chroma # Code syntax highlighter
        # clinfo # Terminal OpenCL info
        # curlie # Terminal HTTP client
        # dconf2nix # Nix code from Dconf files
        # debootstrap # Terminal Debian installer
        diffr # Modern Unix `diff`
        # difftastic # Modern Unix `diff`
        # dogdns # Modern Unix `dig`
        # dua # Modern Unix `du`
        duf # Modern Unix `df`
        frogmouth # Terminal mardown viewer
        # du-dust # Modern Unix `du`
        # entr # Modern Unix `watch`
        # fast-cli # Terminal fast.com
        # fd # Modern Unix `find`
        # glow # Terminal Markdown renderer
        # gping # Modern Unix `ping`
        # hexyl # Modern Unix `hexedit`
        # httpie # Terminal HTTP client
        # hyperfine # Terminal benchmarking
        # iperf3 # Terminal network benchmarking
        # iw # Terminal WiFi info
        # jpegoptim # Terminal JPEG optimizer
        # jiq # Modern Unix `jq`
        # lazygit # Terminal Git client
        # libva-utils # Terminal VAAPI info
        # lurk # Modern Unix `strace`
        # mdp # Terminal Markdown presenter
        moar # Modern Unix `less`
        # mtr # Modern Unix `traceroute`
        # netdiscover # Modern Unix `arp`
        # nethogs # Modern Unix `iftop`
        # nodePackages.prettier # Code format
        # nurl # Nix URL fetcher
        # nyancat # Terminal rainbow spewing feline
        # speedtest-go # Terminal speedtest.net
        # optipng # Terminal PNG optimizer
        # procs # Modern Unix `ps`
        # python310Packages.gpustat # Terminal GPU info
        # quilt # Terminal patch manager
        ripgrep # Modern Unix `grep`
        # rustfmt # Code format Rust
        # shellcheck # Code lint Shell
        # shfmt # Code format Shell
        # tldr # Modern Unix `man`
        # tokei # Modern Unix `wc` for code
        # vdpauinfo # Terminal VDPAU info
        # wavemon # Terminal WiFi monitor
        # yq-go # Terminal `jq` for YAML
        # nvchad
      ];
    # sessionVariables = {
    #   BZR_EMAIL = "Reinaldo P Jr <code@wimpress.io>";
    #   DEBFULLNAME = "Reinaldo P Jr";
    #   DEBEMAIL = "code@wimpress.io";
    #   DEBSIGN_KEYID = "8F04688C17006782143279DA61DF940515E06DA3";
    #   PAGER = "moar";
    # };
    extraOutputsToInstall = ["info" "man" "share" "icons" "doc"];
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
      path = "${config.home.homeDirectory}/home-manager";
    };
  };

  services = {
    home-manager = {
      autoUpgrade = {
        enable = true;
        frequency = "weekly";
      };
    };
  };

  systemd.user.tmpfiles.rules = lib.mkIf isLinux [
    "d ${config.home.homeDirectory}/Scripts 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Studio/OBS/config/obs-studio/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/virtualmachines/windows 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/virtualmachines/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/virtualmachines/mac 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/docker-configs/resources 0750 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/docker-configs/composes 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/lab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/github 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/bitbucket 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/gitlab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/scripts 0755 ${username} users - -"
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
