{ pkgs, config, desktop, hostname, lib, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  isLima = builtins.substring 0 5 hostname == "lima-";
  isWorkstation = if (desktop != null) then true else false;
  isStreamstation = if (hostname == "phasma" || hostname == "vader") then true else false;
in
{
  imports = [
    # ./config/scripts/home-manager_change_summary.nix
    ./console
  ];

  config = {
    home = {
      # A Modern Unix experience
      # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
      packages = with pkgs; [
        # (nerdfonts.override { fonts = [
        #   # "FiraCode"
        #   "NerdFontsSymbolsOnly" ]; })
        # ubuntu_font_family
        work-sans
        asciicam # Terminal webcam
        # asciinema-agg # Convert asciinema to .gif
        # asciinema # Terminal recorder
        bandwhich # Modern Unix `iftop`
        # bmon # Modern Unix `iftop`
        # breezy # Terminal bzr client
        # butler # Terminal Itch.io API client
        # chafa # Terminal image viewer
        chroma # Code syntax highlighter
        clinfo # Terminal OpenCL info
        # cpufetch # Terminal CPU info
        # croc # Terminal file transfer
        # curlie # Terminal HTTP client
        # dconf2nix # Nix code from Dconf files
        # difftastic # Modern Unix `diff`
        # dogdns # Modern Unix `dig`
        # dotacat # Modern Unix lolcat
        # dua # Modern Unix `du`
        duf # Modern Unix `df`
        # du-dust # Modern Unix `du`
        # editorconfig-core-c # EditorConfig Core
        # entr # Modern Unix `watch`
        fd # Modern Unix `find`
        # frogmouth # Terminal mardown viewer
        # glow # Terminal Markdown renderer
        gping # Modern Unix `ping`
        # h # Modern Unix autojump for git projects
        # hexyl # Modern Unix `hexedit`
        hr # Terminal horizontal rule
        # httpie # Terminal HTTP client
        # hyperfine # Terminal benchmarking
        # iperf3 # Terminal network benchmarking
        # jpegoptim # Terminal JPEG optimizer
        # jiq # Modern Unix `jq`
        # lima-bin # Terminal VM manager
        # mdp # Terminal Markdown presenter
        # mtr # Modern Unix `traceroute`
        # neo-cowsay # Terminal ASCII cows
        netdiscover # Modern Unix `arp`
        nixpkgs-review # Nix code review
        nix-prefetch-scripts # Nix code fetcher
        nurl # Nix URL fetcher
        # nyancat # Terminal rainbow spewing feline
        # onefetch # Terminal git project info
        optipng # Terminal PNG optimizer
        procs # Modern Unix `ps`
        # quilt # Terminal patch manager
        # rclone # Modern Unix `rsync`
        rsync # Traditional `rsync`
        # sd # Modern Unix `sed`
        speedtest-go # Terminal speedtest.net
        # terminal-parrot # Terminal ASCII parrot
        # tldr # Modern Unix `man`
        # tokei # Modern Unix `wc` for code
        # ueberzugpp # Terminal image viewer integration
        # unzip # Terminal ZIP extractor
        # upterm # Terminal sharing
        # wget # Terminal HTTP client
        wget2 # Terminal HTTP client
        # wthrr # Modern Unix weather
        wormhole-william # Terminal file transfer
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
        pciutils # Terminal PCI info
        # psmisc # Traditional `ps`
        ramfetch # Terminal system info
        # s-tui # Terminal CPU stress test
        # stress-ng # Terminal CPU stress test
        usbutils # Terminal USB info
        # wavemon # Terminal WiFi monitor
        writedisk # Modern Unix `dd`
        zsync # Terminal file sync; FTBFS on aarch64-darwin
      ] ++ lib.optionals isDarwin [
        m-cli # Terminal Swiss Army Knife for macOS
      ];


      sessionVariables =
        let
          editor = "micro"; # change for whatever you want
        in
        {
          EDITOR = "${editor}";
          MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
          PAGER = "moar";
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
      mpd.enable = mkForce false;
    };

    services =
      with lib; {
        aliases.enable = true;
        bat.enable = true;
        dircolors.enable = true;
        fish.enable = true;
        fastfetch.enable = true;
        direnv.enable = true;
        eza.enable = true;
        git.enable = true;
        micro.enable = true;
        ncmpcpp.enable = mkForce false;
        gpg.enable = true;
        ssh.enable = true;
      };
  };
}
