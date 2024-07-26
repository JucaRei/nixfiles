{ pkgs, config, desktop, hostname, lib, isLima, isWorkstation, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  isStreamstation = if (hostname == "phasma" || hostname == "vader") then true else false;
  home-build = import ./config/scripts/home-build.nix { inherit pkgs; };
  home-switch = import ./config/scripts/home-switch.nix { inherit pkgs; };
  gen-ssh-key = import ./config/scripts/gen-ssh-key.nix { inherit pkgs; };
  home-manager_change_summary = import ./config/scripts/home-manager_change_summary.nix { inherit pkgs; };
  samba = import ./config/scripts/samba.nix { inherit pkgs; };

in
{
  imports = [
    # ./config/scripts/home-manager_change_summary.nix
    ./console
    # ./config/scripts/nh-home
  ]
  ++ lib.optional (isWorkstation) ./desktop;


  config = {
    home = {
      # A Modern Unix experience
      # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
      packages = with pkgs; [
        # Custom Scripts
        home-build
        home-switch
        gen-ssh-key
        home-manager_change_summary
        # samba

        wormhole-william # Terminal file transfer
        work-sans
        nix-whereis
        duf # Modern Unix `df`
        fd # Modern Unix `find`
        hr # Terminal horizontal rule
        netdiscover # Modern Unix `arp`
        nixpkgs-review # Nix code review
        nix-prefetch-scripts # Nix code fetcher
        nurl # Nix URL fetcher
        optipng # Terminal PNG optimizer
        procs # Modern Unix `ps`
        speedtest-go # Terminal speedtest.net
        rsync # Traditional `rsync`
        wget2 # Terminal HTTP client
        # clinfo # Terminal OpenCL info
        # gping # Modern Unix `ping`
        # (nerdfonts.override { fonts = [
        #   # "FiraCode"
        #   "NerdFontsSymbolsOnly" ]; })
        # ubuntu_font_family
        # asciicam # Terminal webcam
        # asciinema-agg # Convert asciinema to .gif
        # asciinema # Terminal recorder
        # bandwhich # Modern Unix `iftop`
        # bmon # Modern Unix `iftop`
        # breezy # Terminal bzr client
        # butler # Terminal Itch.io API client
        # chafa # Terminal image viewer
        # chroma # Code syntax highlighter
        # cpufetch # Terminal CPU info
        # croc # Terminal file transfer
        # curlie # Terminal HTTP client
        # dconf2nix # Nix code from Dconf files
        # difftastic # Modern Unix `diff`
        # dogdns # Modern Unix `dig`
        # dotacat # Modern Unix lolcat
        # dua # Modern Unix `du`
        # du-dust # Modern Unix `du`
        # editorconfig-core-c # EditorConfig Core
        # entr # Modern Unix `watch`
        # frogmouth # Terminal mardown viewer
        # glow # Terminal Markdown renderer
        # h # Modern Unix autojump for git projects
        # hexyl # Modern Unix `hexedit`
        # httpie # Terminal HTTP client
        # hyperfine # Terminal benchmarking
        # iperf3 # Terminal network benchmarking
        # jpegoptim # Terminal JPEG optimizer
        # jiq # Modern Unix `jq`
        # lima-bin # Terminal VM manager
        # mdp # Terminal Markdown presenter
        # mtr # Modern Unix `traceroute`
        # neo-cowsay # Terminal ASCII cows
        # nyancat # Terminal rainbow spewing feline
        # onefetch # Terminal git project info
        # quilt # Terminal patch manager
        # rclone # Modern Unix `rsync`
        # sd # Modern Unix `sed`
        # terminal-parrot # Terminal ASCII parrot
        # tldr # Modern Unix `man`
        # tokei # Modern Unix `wc` for code
        # ueberzugpp # Terminal image viewer integration
        # unzip # Terminal ZIP extractor
        # upterm # Terminal sharing
        # wget # Terminal HTTP client
        # wthrr # Modern Unix weather
        # yq-go # Terminal `jq` for YAML
      ] ++ lib.optionals (isStreamstation) [
        # Deckmaster and the utilities I bind to the Stream Deck
        alsa-utils
        bc
        # deckmaster
        # hueadm
        notify-desktop
        # obs-cli
        piper-tts
        playerctl
        pulsemixer
      ] ++ lib.optionals isLinux [
        # figlet # Terminal ASCII banners
        iw # Terminal WiFi info
        # lurk # Modern Unix `strace`
        psmisc # a set of small utils like killall, fuser, pstree
        pciutils # Terminal PCI info
        # psmisc # Traditional `ps`
        ramfetch # Terminal system info
        # s-tui # Terminal CPU stress test
        # stress-ng # Terminal CPU stress test
        usbutils # Terminal USB info
        # wavemon # Terminal WiFi monitor
        writedisk # Modern Unix `dd`
        zsync # Terminal file sync; FTBFS on aarch64-darwin

        # compression
        lzop
        p7zip
        unrar
        zip
      ] ++ lib.optionals isDarwin [
        m-cli # Terminal Swiss Army Knife for macOS
      ];


      sessionVariables =
        let
          editor = "micro"; # change for whatever you want
        in
        {
          EDITOR = "${editor}";
          # MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
          PAGER = "${pkgs.moar}/bin/moar";
          SYSTEMD_EDITOR = "${editor}";
          VISUAL = "${editor}";
        };
    };

    programs = with lib;{
      command-not-found.enable = false;
      info.enable = true;
      jq = {
        enable = true;
        package = pkgs.jiq;
      };
    };

    xdg = {
      enable = isLinux;
      userDirs = {
        # Do not create XDG directories for LIMA; it is confusing
        enable = isLinux && !isLima;
        createDirectories = lib.mkDefault true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/screenshots";
        };

      };
    };
  };
}
