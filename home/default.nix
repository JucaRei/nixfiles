{ config, inputs, isLima, isWorkstation, lib, outputs, pkgs, stateVersion, username, hostname, platform, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
in
{
  imports = [
    (import ../modules/home-manager/linux/cli/fish { inherit config pkgs lib; })
  ]
  ++ lib.optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
  # ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix;
  ++ lib.optional (builtins.pathExists (./. + "/hosts/${hostname}")) ./hosts/${hostname};

  home = {

    sessionVariables = lib.mkDefault {
      EDITOR = lib.mkDefault "micro";
      MANPAGER = lib.mkDefault "sh -c 'col --no-backspaces --spaces | bat --language man'";
      MANROFFOPT = lib.mkDefault "-c";
      MICRO_TRUECOLOR = lib.mkDefault "1";
      PAGER = lib.mkDefault "bat";
      SYSTEMD_EDITOR = lib.mkDefault "micro";
      VISUAL = lib.mkDefault "micro";
      NIXPKGS_ALLOW_UNFREE = lib.mkDefault "1";
      NIXPKGS_ALLOW_INSECURE = lib.mkDefault "1";
      FLAKE = lib.mkDefault "/home/${username}/.dotfiles/nixfiles";
    };

    shellAliases = {
      mkhostid = lib.mkIf isLinux "head -c4 /dev/urandom | od -A none -t x4";
      mkdir = "mkdir -pv";
      ip = lib.mkIf isLinux "${pkgs.iproute2}/bin/ip --color --brief";
      less = lib.mkDefault "${pkgs.bat}/bin/bat --paging=always";
      more = lib.mkDefault "${pkgs.bat}/bin/bat --paging=always";
      du = lib.mkDefault "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
      glow = "${pkgs.glow}/bin/glow --pager";
      ruler = ''${pkgs.hr}/bin/hr "╭─³⁴⁵⁶⁷⁸─╮"'';
      hr = ''${pkgs.hr}/bin/hr "─━"'';
      speedtest = "${pkgs.speedtest-go}/bin/speedtest-go";
      top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
      audio = "${pkgs.inxi}/bin/inxi -A";
      battery = "${pkgs.inxi}/bin/inxi -B -xxx";
      bluetooth = "${pkgs.inxi}/bin/inxi -E";
      graphics = "${pkgs.inxi}/bin/inxi -G";
      system = "${pkgs.inxi}/bin/inxi -Fazy";
      usb = "${pkgs.inxi}/bin/inxi -J";
      wifi = "${pkgs.inxi}/bin/inxi -n";
      dmesg = lib.mkIf isLinux "${pkgs.util-linux}/bin/dmesg --human --color=always";
      store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
    };
  };

  # Workaround home-manager bug with flakes
  # - https://github.com/nix-community/home-manager/issues/2033
  news.display = "silent";

  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      # outputs.overlays.legacy-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default
      # inputs.agenix.overlays.default

      # Or define it inline, for example:
      (_final: _prev: {
        # hi = final.hello.overrideAttrs (oldAttrs: {
        #   patches = [ ./change-hello-to-hi.patch ];
        # });

        # awesome = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-git;
      })
    ];
    # Configure your nixpkgs instance
    config = {
      # allowUnsupportedSystem = true; # Allow unsupported packages to be built
      # allowBroken = false; # Disable broken package
      permittedInsecurePackages = [
        ### Allow old broken electron
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        # "electron-21.4.0"
      ];
      allowUnfree = true; # Disable if you don't want unfree packages
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = (_: true);
      # Accept the joypixels license
      joypixels.acceptLicense = true;
    };

    # hostPlatform = lib.mkDefault "${platform}";
  };

  nix = {
    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;

    # package = pkgs.nix;
    # auto upgrade nix to the unstable version
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/tools/package-management/nix/default.nix#L284
    package = pkgs.nixVersions.latest;

    settings = {
      auto-optimise-store = isLinux;
      experimental-features = [
        "nix-command"
        "flakes"
      ];
      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      warn-dirty = false;
      allow-dirty = true;

      sandbox =
        if (isDarwin)
        then true
        else "relaxed"; #false

      allowed-users = [ "root" "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
      connect-timeout = 5;
    };
    extraOptions =
      ''
        log-lines = 15
        fallback = true

        # Free up to 1GiB whenever there is less than 100MiB left.
        # min-free = ${toString (100 * 1024 * 1024)}
        # max-free = ${toString (1024 * 1024 * 1024)}
        # Free up to 2GiB whenever there is less than 1GiB left.
        min-free = ${toString (1024 * 1024 * 1024)}        # 1 GiB
        max-free = ${toString (3 * 1024 * 1024 * 1024)}    # 2 GiB
      ''
      + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
        extra-platforms = x86_64-darwin
      '';
  };

  programs = {
    aria2.enable = true;
    atuin = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      flags = [ "--disable-up-arrow" ];
      package = pkgs.atuin;
      settings = {
        auto_sync = true;
        dialect = "us";
        # key_path = config.sops.secrets.atuin_key.path;
        show_preview = true;
        style = "compact";
        sync_frequency = "1h";
        sync_address = "https://api.atuin.sh";
        update_check = false;
      };
    };
    bat = {
      catppuccin.enable = true;
      enable = true;
      extraPackages = with pkgs.bat-extras; [
        batgrep
        batwatch
        prettybat
      ];
      config = {
        style = "plain";
      };
    };
    bottom = {
      catppuccin.enable = true;
      enable = true;
      settings = {
        disk_filter = {
          is_list_ignored = true;
          list = [ "/dev/loop" ];
          regex = true;
          case_sensitive = false;
          whole_word = false;
        };
        flags = {
          dot_marker = false;
          enable_gpu_memory = true;
          group_processes = true;
          hide_table_gap = true;
          mem_as_value = true;
          tree = true;
        };
      };
    };
    cava = {
      catppuccin.enable = true;
      enable = isLinux;
    };
    dircolors = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
    };
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv = {
        enable = true;
      };
    };
    eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
      git = true;
      icons = true;
    };
    fzf = {
      catppuccin.enable = true;
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
    };
    gh = {
      enable = true;
      extensions = with pkgs; [
        gh-dash
        gh-markdown-preview
      ];
      settings = {
        editor = "micro";
        git_protocol = "ssh";
        prompt = "enabled";
      };
    };
    git = {
      enable = true;
      aliases = {
        ci = "commit";
        cl = "clone";
        co = "checkout";
        purr = "pull --rebase";
        dlog = "!f() { GIT_EXTERNAL_DIFF=difft git log -p --ext-diff $@; }; f";
        dshow = "!f() { GIT_EXTERNAL_DIFF=difft git show --ext-diff $@; }; f";
        fucked = "reset --hard";
        graph = "log --color --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit";
      };
      difftastic = {
        display = "side-by-side-show-both";
        enable = true;
      };
      extraConfig = {
        advice = {
          statusHints = false;
        };
        color = {
          branch = false;
          diff = false;
          interactive = true;
          log = false;
          status = true;
          ui = false;
        };
        core = {
          pager = "bat";
        };
        push = {
          default = "matching";
        };
        pull = {
          rebase = false;
        };
        init = {
          defaultBranch = "main";
        };
      };
      ignores = [
        "*.log"
        "*.out"
        ".DS_Store"
        "bin/"
        "dist/"
        "result"
      ];
    };
    gitui = {
      catppuccin.enable = true;
      enable = true;
    };
    gpg.enable = true;
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
    micro = {
      catppuccin.enable = true;
      enable = true;
      settings = {
        autosu = true;
        diffgutter = true;
        paste = true;
        rmtrailingws = true;
        savecursor = true;
        saveundo = true;
        scrollbar = true;
        scrollbarchar = "░";
        scrollmargin = 4;
        scrollspeed = 1;
      };
    };
    nix-index.enable = true;
    powerline-go = {
      enable = true;
      settings = {
        cwd-max-depth = 5;
        cwd-max-dir-size = 12;
        theme = "gruvbox";
        max-width = 60;
      };
    };
    ripgrep = {
      arguments = [
        "--colors=line:style:bold"
        "--max-columns-preview"
        "--smart-case"
      ];
      enable = true;
    };
    tmate.enable = true;
    tmux = {
      aggressiveResize = true;
      baseIndex = 1;
      catppuccin.enable = true;
      clock24 = true;
      historyLimit = 50000;
      enable = true;
      escapeTime = 0;
      extraConfig = ''
        set -g @catppuccin_window_status_icon_enable "yes"
        set -g @catppuccin_icon_window_last "󰖰"
        set -g @catppuccin_icon_window_current "󰖯"
        set -g @catppuccin_icon_window_zoom "󰁌"
        set -g @catppuccin_icon_window_mark "󰃀"
        set -g @catppuccin_icon_window_silent "󰂛"
        set -g @catppuccin_icon_window_activity "󱅫"
        set -g @catppuccin_icon_window_bell "󰂞"
        set -g @catppuccin_status_background "theme"

        set -g @catppuccin_window_left_separator ""
        set -g @catppuccin_window_right_separator " "
        set -g @catppuccin_window_middle_separator " █"
        set -g @catppuccin_window_number_position "right"

        set -g @catppuccin_window_default_fill "number"
        set -g @catppuccin_window_default_text "#W"

        set -g @catppuccin_window_current_fill "number"
        set -g @catppuccin_window_current_text "#W"

        set -g @catppuccin_status_modules_right "directory user host session"
        set -g @catppuccin_status_left_separator  " "
        set -g @catppuccin_status_right_separator ""
        set -g @catppuccin_status_fill "icon"
        set -g @catppuccin_status_connect_separator "no"

        set -g @catppuccin_directory_text "#{pane_current_path}"
        # Status at the top
        set -g status on
        set -g status-position top
        # Increase tmux messages display duration from 750ms to 4s
        set -g display-time 4000
        # Refresh 'status-left' and 'status-right' more often, from every 15s to 5s
        set -g status-interval 5
        # Focus events enabled for terminals that support them
        set -g focus-events on
        # | and - for splitting panes:
        bind | split-window -h
        bind "\\" split-window -fh
        bind - split-window -v
        bind _ split-window -fv
        unbind '"'
        unbind %
        # reload config file
        bind r source-file ~/.config/tmux/tmux.conf
        # Fast pant-switching using Alt-arrow without prefix
        bind -n M-Left select-pane -L
        bind -n M-Right select-pane -R
        bind -n M-Up select-pane -U
        bind -n M-Down select-pane -D
      '';
      keyMode = "emacs";
      mouse = true;
      newSession = false;
      #sensibleOnTop = true;
      shortcut = "a";
      terminal = "tmux-256color";
    };
    yazi = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      catppuccin.enable = true;
      settings = {
        manager = {
          show_hidden = false;
          show_symlink = true;
          sort_by = "natural";
          sort_dir_first = true;
          sort_sensitive = false;
          sort_reverse = false;
        };
      };
    };
    yt-dlp = {
      enable = true;
      settings = {
        audio-format = "best";
        audio-quality = 0;
        embed-chapters = true;
        embed-metadata = true;
        embed-subs = true;
        embed-thumbnail = true;
        remux-video = "aac>m4a/mov>mp4/mkv";
        sponsorblock-mark = "sponsor";
        sub-langs = "all";
      };
    };
    zoxide = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      # Replace cd with z and add cdi to access zi
      options = [ "--cmd cd" ];
    };
  };

  services = {
    gpg-agent = lib.mkIf isLinux {
      enable = isLinux;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
    pueue = {
      enable = isLinux;
      # https://github.com/Nukesor/pueue/wiki/Configuration
      settings = {
        daemon = {
          default_parallel_tasks = 1;
        };
      };
    };
  };

  # sops = lib.mkIf (username == "juca") {
  #   age = {
  #     keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
  #     generateKey = false;
  #   };
  #   defaultSopsFile = ../secrets/secrets.yaml;
  #   # sops-nix options: https://dl.thalheim.io/
  #   secrets = {
  #     asciinema.path = "${config.home.homeDirectory}/.config/asciinema/config";
  #     atuin_key.path = "${config.home.homeDirectory}/.local/share/atuin/key";
  #     gh_token = { };
  #     gpg_private = { };
  #     gpg_public = { };
  #     gpg_ownertrust = { };
  #     hueadm.path = "${config.home.homeDirectory}/.hueadm.json";
  #     obs_secrets = { };
  #     ssh_config.path = "${config.home.homeDirectory}/.ssh/config";
  #     ssh_key.path = "${config.home.homeDirectory}/.ssh/id_rsa";
  #     ssh_pub.path = "${config.home.homeDirectory}/.ssh/id_rsa.pub";
  #     ssh_semaphore_key.path = "${config.home.homeDirectory}/.ssh/id_rsa_semaphore";
  #     ssh_semaphore_pub.path = "${config.home.homeDirectory}/.ssh/id_rsa_semaphore.pub";
  #     transifex.path = "${config.home.homeDirectory}/.transifexrc";
  #   };
  # };
}
