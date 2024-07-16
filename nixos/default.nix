{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs, stateVersion, username, hostid, platform, ... }:
let
  notVM = if (hostname == "minimech") || (hostname == "scrubber") || (hostname == "vm") || (builtins.substring 0 5 hostname == "lima-") then false else true;
  # Create some variable to control what doesn't get installed/enabled
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
  isWorkstation = if (desktop != null) then true else false;
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  imports =
    [
      inputs.disko.nixosModules.disko
      inputs.nh.nixosModules.default
      inputs.nix-index-database.nixosModules.nix-index
      inputs.nix-snapd.nixosModules.default
      # inputs.sops-nix.nixosModules.sops
      (modulesPath + "/installer/scan/not-detected.nix")
      (./. + "/hosts/${ hostname}")
      ./_mixins/services/network/openssh.nix
      ./_mixins/config/scripts
      ./_mixins/services/network/networkmanager.nix
      ./_mixins/services/security/firewall.nix
      ./users
    ]
    # ++ optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
    # ++ lib.optional (notVM) ./_mixins/virtualization/podman.nix # podman not connecting to internet
    ++ lib.optional (notVM || hostname != "soyo") ./_mixins/services/tools/smartmon.nix
    ++ lib.optional (notVM) ./_mixins/virtualization/docker.nix
    ++ lib.optional (notVM) ./_mixins/virtualization/lxd.nix
    ++ lib.optional (isWorkstation) ./_mixins/desktop
    ++ lib.optional (isWorkstation) ./_mixins/sys;

  ######################
  ### Documentations ###
  ######################

  documentation = {
    enable = true; # documentation of packages
    nixos.enable = false; # nixos documentation
    man.enable = true; # manual pages and the man command
    info.enable = false; # info pages and the info command
    doc.enable = false; # documentation distributed in packages' /share/doc
  };

  ###################
  ### Nix Configs ###
  ###################

  nix = {
    # smooth rebuilds
    # give nix-daemon the lowest priority
    # Reduce disk usage
    daemonIOSchedClass = "idle";
    # Leave nix builds as a background task
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedPriority = 7; # only used by "best-effort"
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
    # distributedBuilds = true;
    ### This will add each flake input as a registry
    ### To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    # nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;
    ### Add nixpkgs input to NIX_PATH
    ### This lets nix2 commands still use <nixpkgs>
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
    optimise.automatic = true;
    package = lib.mkIf (isInstall) pkgs.unstable.nix;
    settings = {
      # Tell nix to use the xdg spec for base directories
      # while transitioning, any state must be carried over
      # manually, as Nix won't do it for us.
      use-xdg-base-directories = true;

      # Always build inside sandboxed environments
      # sandbox = true;
      sandbox-fallback = false;
      sandbox = "relaxed"; # true

      # extra-sandbox-paths = [ ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
        "recursive-nix" # let nix invoke itself
        "ca-derivations" # content addressed nix
        "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
        "cgroups" # allow nix to execute builds inside cgroups
      ];
      allowed-users = [ "root" "@wheel" ];
      trusted-users = [ "root" "@wheel" ];
      builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.
      ### Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      keep-going = true;
      warn-dirty = false;
      # execute builds inside cgroups
      use-cgroups = true;
      system-features = [
        #   ## Allows building v3/v4 packages
        #   "gccarch-x86-64-v3"
        #   "gccarch-x86-64-v4"
        "kvm"
        "recursive-nix"
        "big-parallel"
        "nixos-test"
      ];
    };
    extraOptions =
      ''
        log-lines = 15
        # Free up to 4GiB whenever there is less than 2GiB left.
        min-free = ${toString (2048 * 1024 * 1024)}
        max-free = ${toString (4096 * 1024 * 1024)}
        connect-timeout = 10
      '';
    # Free up to 4GiB whenever there is less than 512MiB left.
    # min-free = ${toString (512 * 1024 * 1024)}
    # min-free = 1073741824 # 1GiB
    # max-free = 4294967296 # 4GiB
  };

  ################
  ### Nixpkgs ####
  ################

  nixpkgs = {
    hostPlatform = lib.mkDefault "${platform}";

    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.previous-packages
      outputs.overlays.legacy-packages
      # Add overlays exported from other flakes:

      # inputs.nixd.overlays.default
      # inputs.agenix.overlays.default


      # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
      (_: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })

      ## Testing
      (self: super: {


        vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
        #   deadbeef = super.deadbeef.override { wavpackSupport = true; };
        #   deadbeef-with-plugins = super.deadbeef-with-plugins.override {
        #     plugins = with super.deadbeefPlugins; [ mpris2 statusnotifier ];
        #   };
      })
    ];

    config = {
      # allowBroken = true;
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Accept the joypixels license
      joypixels.acceptLicense = true;
      allowUnsupportedSystem = true;
      # permittedInsecurePackages = [ "openssl-1.1.1w" "electron-19.1.9" ];

      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
      # allowUnfreePredicate = pkg:
      #   builtins.elem (lib.getName pkg) [
      #     "nvidia-settings"
      #     "nvidia-x11"
      #     "spotify"
      #     "steam"
      #     "steam-original"
      #     "steam-run"
      #     "vscode"
      #     # "dubai"
      #     # they got fossed recently so idk
      #     "Anytype"
      #   ];
    };
  };

  #############
  ### Hosts ###
  #############

  networking = {
    extraHosts = ''
      192.168.1.35  nitro
      192.168.1.50  nitro
      192.168.1.45  rocinante
      192.168.1.76  dongle
      192.168.1.228 rocinante
      192.168.1.230 air
      192.168.1.200 DietPi
    '';

    hostName = hostname;
    hostId = hostid;
    usePredictableInterfaceNames = true;
  };

  ############################
  ### Default Boot Options ###
  ############################

  ## Only enable the grub on installs, not live media (.ISO images)
  boot = with lib; {
    # Only enable the systemd-boot on installs, not live media (.ISO images)
    loader = mkIf (notVM) {
      efi = {
        canTouchEfiVariables = true;
      };
      systemd-boot = mkIf (isInstall) {
        configurationLimit = 5;
        consoleMode = "max";
        editor = false;
        graceful = true;
        # enable = true;
        memtest86.enable = true;
      };
      timeout = 7;
    };
    consoleLogLevel = 3; # Silence ACPI "errors" at boot shown before NixOS stage 1 output (default is 4)
    tmp = {
      cleanOnBoot = mkDefault true;
      tmpfsSize = "25%"; # 30% for 27GB system - else "25%"; # 25% for 8GB system
    };
    kernelModules = mkIf (notVM) [ "vhost_vsock" "tcp_bbr" ];
    kernelParams = [
      "boot.shell_on_fail"
      "loglevel=3"
      "vt.default_red=30,243,166,249,137,245,148,186,88,243,166,249,137,245,148,166"
      "vt.default_grn=30,139,227,226,180,194,226,194,91,139,227,226,180,194,226,173"
      "vt.default_blu=46,168,161,175,250,231,213,222,112,168,161,175,250,231,213,200"
    ];
    kernelPackages =
      #        default = 1000
      #   this default = 1250
      # option default = 1500
      mkOverride 1250 pkgs.linuxPackages_latest;
    kernel = {
      sysctl = mkIf (notVM) {
        "vt.cur_default" = "0x700010";
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        "vm.page-cluster" = 1; # Keep zram swap (lz4) latency in check

        # Kernel Settings
        "kernel.pty.max" = 24000; # Maximum number of pseudo-terminal (pty) devices.
        "kernel.sched_autogroup_enabled" = 0; # Disable automatic grouping of tasks in the scheduler.
        "kernel.sched_migration_cost_ns" = 5000000; # Cost (in nanoseconds) of migrating a task to another CPU.
        "kernel.sysrq" = 1; # Enable the SysRq key for low-level system commands.
        "kernel.pid_max" = 131072; # Maximum number of processes and threads.
        "net.ipv4.ip_unprivileged_port_start" = 80; # Podman access port 80

        # Network Settings
        # "net.core.default_qdisc" = "fq"; # Use Fair Queueing (FQ) as default queuing discipline for reduced latency.
        "net.core.default_qdisc" = "cake";
        "net.core.netdev_max_backlog" = 30000; # Helps prevent packet loss during high traffic periods.
        "net.core.rmem_default" = 4194304; # Default socket receive buffer size increased for better network performance.
        "net.core.rmem_max" = 16777216; # Maximum socket receive buffer size increased for better network performance.
        "net.core.wmem_default" = 4194304; # Default socket send buffer size increased for better network performance.
        "net.core.wmem_max" = 16777216; # Maximum socket send buffer size increased for better network performance.
        "net.ipv4.ipfrag_high_threshold" = 5242880; # Threshold to reduce fragmentation.
        "net.ipv4.tcp_fastopen" = 3; # Bufferbload mitigations + slight improvement in throughput & latency
        "net.ipv4.tcp_congestion_control" = "bbr"; # Use TCP BBR congestion control algorithm for optimized throughput.
        "net.ipv4.tcp_keepalive_intvl" = 15; # TCP keepalive interval in seconds for faster detection of connection issues.
        "net.ipv4.tcp_keepalive_probes" = 3; # TCP keepalive probes for faster detection of connection issues.
        "net.ipv4.tcp_keepalive_time" = 120; # TCP keepalive interval in seconds for faster detection of connection issues.
        "net.ipv4.ip_default_ttl" = 65; # Bypass hotspot restrictions for certain ISPs
        "net.ipv4.udp_rmem_min" = 16384;
        "net.ipv4.udp_wmem_min" = 16384;
        "net.ipv4.tcp_tw_reuse" = 1;
        "net.ipv4.tcp_mtu_probing" = 1;

        # Virtual Memory Settings
        "vm.dirty_background_bytes" = 67108864; # Reduce dirty background bytes to 64 MB for faster writeback initiation.
        "vm.dirty_bytes" = 268435456; # Increase dirty bytes to 256 MB for more efficient dirty memory handling.
        "vm.dirty_background_ratio" = 5; # Set very low dirty background ratio to trigger faster writeback (5%).
        "vm.dirty_expire_centisecs" = 1000; # Decrease dirty expire centiseconds to 10 seconds for faster writeout.
        "vm.dirty_ratio" = 30; # Lower dirty ratio to 30% for faster process writeout.
        "vm.dirty_time" = 1; # Enable dirty time accounting to track dirty page age.
        "vm.dirty_writeback_centisecs" = 100; # Reduce dirty writeback centiseconds to 1 second for faster background writeback.
        "vm.max_map_count" = 1000000; # Maximum number of memory map areas per process.
        "vm.min_free_kbytes" = 131072; # Minimum free memory for safety (in KB).
        "vm.swappiness" = 10; # Kernel tendency to swap inactive memory pages.
        "vm.vfs_cache_pressure" = 90; # Management of memory used for caching filesystem objects.

        # File System Settings
        "fs.aio-max-nr" = 524288; # Increase maximum number of asynchronous I/O requests for faster file I/O.
        "fs.inotify.max_user_watches" = 1048576; # Increase maximum number of file system watches for better file system monitoring.

        # Nobara Tweaks
        "kernel.panic" = 5; # Reboot after 5 seconds on kernel panic.
      };
    };
    supportedFilesystems = [
      # "ext4"
      "btrfs"
      "exfat"
      "ntfs"
      # "bcachefs"
    ];
  };

  ###################
  ### Console tty ###
  ###################
  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    # keyMap = lib.mkDefault "us";
    keyMap = if (hostname == "nitro") then "br-abnt2" else "br-latin1-us";
    packages = with pkgs; [ tamzen ];
    colors = [
      "000000"
      "ff5370"
      "c3e88d"
      "ffcb6b"
      "82aaff"
      "c792ea"
      "89ddff"
      "ffffff"
      "545454"
      "ff5370"
      "c3e88d"
      "ffcb6b"
      "82aaff"
      "c792ea"
      "89ddff"
      "ffffff"
    ];
  };

  ###############
  ### Locales ###
  ###############

  i18n = {
    defaultLocale = lib.mkDefault "en_US.utf8";
    extraLocaleSettings = lib.mkDefault {
      #LC_CTYPE = lib.mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "pt_BR.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
      #LC_COLLATE = "pt_BR.UTF-8";
      #LC_MESSAGES = "pt_BR.UTF-8";
    };
  };

  ########################
  ### Default Timezone ###
  ########################

  time = lib.mkDefault
    {
      timeZone = "America/Sao_Paulo";

      ### For dual boot
      hardwareClockInLocalTime = isWorkstation;
    };

  #########################
  ### Defaults Packages ###
  #########################

  environment = {
    # Eject nano and perl from the system
    defaultPackages = with pkgs; lib.mkForce [
      coreutils-full
      micro
    ];

    systemPackages = with pkgs; [
      git
    ] ++ lib.optionals (isInstall) [
      # inputs.crafts-flake.packages.${platform}.snapcraft
      # inputs.fh.packages.${platform}.default
      inputs.nixos-needtoreboot.packages.${platform}.default
      clinfo
      distrobox
      flyctl
      fuse-overlayfs
      libva-utils
      nix-output-monitor
      nvd
      nvme-cli
      #https://nixos.wiki/wiki/Podman
      podman-compose
      podman-tui
      podman
      smartmontools
      # sops
      # ssh-to-age
    ] ++ lib.optionals (isInstall && isWorkstation) [
      pods
    ] ++ lib.optionals (isInstall && isWorkstation && notVM) [
      quickemu
    ] ++ lib.optionals (isInstall && hasNvidia) [
      # unstable.nvtop
      vdpauinfo
    ]
      # ++ lib.optionals (isInstall && !hasNvidia) [
      #   nvtop-amd
      # ]
    ;

    variables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };

    # --------------------------------------------------------------------
    # Permit Insecure Packages && Allow unfree packages
    # --------------------------------------------------------------------

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";

      FLAKE = "/home/${username}/.dotfiles/nixfiles";
    };

    homeBinInPath = true;
    localBinInPath = true;

    shellAliases = {
      system-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles --show-trace -L";
      rebuild-boot = "sudo nixos-rebuild boot --flake $HOME/.dotfiles/nixfiles --show-trace -L";
      sxorg = "export DISPLAY=:0.0";
      # du = "${pkgs.ncdu_1}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
      drivers = "lspci -v | grep -B8 -v 'Kernel modules: [a-z0-9]+'";
      r = "rsync -ra --info=progress2";
      fd = "fd --hidden --exclude .git";
      search = "nix search nixpkgs";

      ### NIX
      inspect-store = "nix path-info -rSh /run/current-system | sort -k2h ";
      # Print timestamp along with cmd output
      # Example: cmd | ts
      ts = "gawk '{ print strftime(\"[%Y-%m-%d %H:%M:%S]\"), $0 }'";
    };

    # Create file /etc/nixos-current-system-packages with List of all Packages
    etc = {
      "nixos-current-system-packages" = {
        text =
          let
            packages =
              builtins.map (p: "${p.name}") config.environment.systemPackages;
            sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
          formatted;
      };
    };
  };

  programs = {
    fuse.userAllowOther = isWorkstation;
    command-not-found.enable = false;
    nano.enable = false;
    nix-index-database.comma.enable = isInstall;
    ssh.startAgent = true;
    # type "fuck" to fix the last command that made you go "fuck"
    # thefuck.enable = true;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual block
        set -U fish_color_autosuggestion brblack
        set -U fish_color_cancel -r
        set -U fish_color_command green
        set -U fish_color_comment brblack
        set -U fish_color_cwd brgreen
        set -U fish_color_cwd_root brred
        set -U fish_color_end brmagenta
        set -U fish_color_error red
        set -U fish_color_escape brcyan
        set -U fish_color_history_current --bold
        set -U fish_color_host normal
        set -U fish_color_match --background=brblue
        set -U fish_color_normal normal
        set -U fish_color_operator cyan
        set -U fish_color_param blue
        set -U fish_color_quote yellow
        set -U fish_color_redirection magenta
        set -U fish_color_search_match bryellow '--background=brblack'
        set -U fish_color_selection white --bold '--background=brblack'
        set -U fish_color_status red
        set -U fish_color_user brwhite
        set -U fish_color_valid_path --underline
        set -U fish_pager_color_completion normal
        set -U fish_pager_color_description yellow
        set -U fish_pager_color_prefix white --bold --underline
        set -U fish_pager_color_progress brwhite '--background=cyan'
      '';
      shellAbbrs = lib.mkIf (isInstall) {
        captive-portal = "${pkgs.xdg-utils}/bin/xdg-open http://$(${pkgs.iproute2}/bin/ip --oneline route get 1.1.1.1 | ${pkgs.gawk}/bin/awk '{print $3}'";
        nix-gc = "sudo nix-collect-garbage --delete-older-than 10d && nix-collect-garbage --delete-older-than 10d";
        update-lock = "pushd $HOME/Zero/nix-config && nix flake update && popd";
      };
      shellAliases = {
        nano = "micro";
      };
    };
  };

  nh = {
    clean = {
      enable = true;
      extraArgs = "--keep-since 10d --keep 5";
    };
    enable = true;
    flake = "/home/${username}/.dotfiles/nixfiles";
  };


  system = {
    nixos.label = lib.mkIf (isInstall) "-";
    stateVersion = stateVersion;
  };

  systemd = {

    # By default nix-gc makes no effort to respect battery life by avoding
    # GC runs on battery and fully commits a few cores to collecting garbage.
    # This will drain the battery faster than you can say "Nix, what the hell?"
    # and contribute heavily to you wanting to get a new desktop.
    # For those curious (such as myself) desktops are always seen as "AC powered"
    # so the system will not fail to fire if you are on a desktop system.
    services.nix-gc = {
      unitConfig.ConditionACPower = true;
    };

    user = {
      extraConfig = ''
        DefaultTimeoutStopSec=15s
        DefaultTimeoutAbortSec=8s
      '';
    };

    tmpfiles.rules = [
      "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
    ];

    extraConfig = ''
      DefaultTimeoutStartSec=10s
      DefaultTimeoutStopSec=10s
      DefaultDeviceTimeoutSec=10s
      DefaultTimeoutAbortSec=10s
    '';

    services = {
      # disable-wifi-powersave = {
      #   wantedBy = [ "multi-user.target" ];
      #   path = [ pkgs.iw ];
      #   script = ''
      #     iw dev wlan0 set power_save off
      #   '';
      # };


      # Enable Multi-Gen LRU:
      # - https://docs.kernel.org/next/admin-guide/mm/multigen_lru.html
      # - Inspired by: https://github.com/hakavlad/mg-lru-helper
      "mglru" = {
        enable = true;
        wantedBy = [ "basic.target" ];
        script = ''
          ${pkgs.coreutils-full}/bin/echo 1000 > /sys/kernel/mm/lru_gen/min_ttl_ms
        '';
        serviceConfig = { Type = "oneshot"; };
        unitConfig = {
          ConditionPathExists = "/sys/kernel/mm/lru_gen/enabled";
          Description = "Configure Enable Multi-Gen LRU";
        };
      };

      # Workaround https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = lib.mkForce false;
      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      systemd-udev-settle.enable = lib.mkForce false;
      # systemd-user-sessions.enable = false;
    };

    targets = lib.mkIf (isInstall) {
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  services = {
    ### My modules
    nm-manager.enable = true;
    firewall.enable = isWorkstation;
    #########################

    snap.enable = notVM;

    avahi = {
      enable = true;
      nssmdns = true;
      # Only open the avahi firewall ports on servers
      openFirewall = isWorkstation;
      publish = {
        addresses = true;
        enable = true;
        workstation = isWorkstation;
      };
    };
    fwupd.enable = isInstall;
    kmscon = lib.mkIf (isInstall) {
      enable = true;
      hwRender = true;
      fonts = [{
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      }];
      extraConfig = ''
        font-size=14
        xkb-layout=gb
      '';
    };

    xserver = {
      libinput = {
        enable = lib.mkDefault true;
        touchpad = {
          # horizontalScrolling = true;
          # tappingDragLock = false;
          accelProfile = "flat";
          tapping = true;
          scrollMethod = "twofinger";
          disableWhileTyping = true;
          # sendEventsMode = "disabled-on-external-mouse";
          # sendEventsMode = lib.mkOverride 1250 "enabled";
          clickMethod = "clickfinger";
          # https://github.com/NixOS/nixpkgs/issues/75007
          naturalScrolling = true;
          # natural scrolling for touchpad only, not mouse
          additionalOptions = ''
            MatchIsTouchpad "on"
          '';
        };
        mouse = {
          naturalScrolling = false;
          disableWhileTyping = true;
          accelProfile = "flat";
        };
      };
    };

    journald = {
      extraConfig = lib.mkDefault ''
        SystemMaxUse=100M
        SystemMaxFileSize=10M
        RuntimeMaxUse=10M
        RuntimeMaxFileSize=10M
        MaxFileSec=7day
        SystemMaxFiles=5
      '';
      rateLimitBurst = 800;
      rateLimitInterval = "5s";
    };

    # to prevent nix-shell complaining about no space left
    # default value is 10% of total RAM
    # writes to: /etc/systemd/logind.conf
    logind.extraConfig = ''
      RuntimeDirectorySize=2G
    '';

    dbus = {
      # Enable the D-Bus service, which is a message bus system that allows
      # communication between applications.
      enable = true;
      implementation = if (isWorkstation && notVM) then "broker" else "dbus";
    };

    getty = {
      greetingLine = "\\l";
      helpLine = ''
        Type `i' to print system information.

            .     .       .  .   . .   .   . .    +  .
              .     .  :     .    .. :. .___---------___.
                   .  .   .    .  :.:. _".^ .^ ^.  '.. :"-_. .
                .  :       .  .  .:../:            . .^  :.:\.
                    .   . :: +. :.:/: .   .    .        . . .:\
             .  :    .     . _ :::/:               .  ^ .  . .:\
              .. . .   . - : :.:./.                        .  .:\
              .      .     . :..|:                    .  .  ^. .:|
                .       . : : ..||        .                . . !:|
              .     . . . ::. ::\(                           . :)/
             .   .     : . : .:.|. ######              .#######::|
              :.. .  :-  : .:  ::|.#######           ..########:|
             .  .  .  ..  .  .. :\ ########          :######## :/
              .        .+ :: : -.:\ ########       . ########.:/
                .  .+   . . . . :.:\. #######       #######..:/
                  :: . . . . ::.:..:.\           .   .   ..:/
               .   .   .  .. :  -::::.\.       | |     . .:/
                  .  :  .  .  .-:.":.::.\             ..:/
             .      -.   . . . .: .:::.:.\.           .:/
            .   .   .  :      : ....::_:..:\   ___.  :/
               .   .  .   .:. .. .  .: :.:.:\       :/
                 +   .   .   : . ::. :.:. .:.|\  .:/|
                 .         +   .  .  ...:: ..|  --.:|
            .      . . .   .  .  . ... :..:.."(  ..)"
             .   .       .      :  .   .: ::/  .  .::\
      '';
    };

    # Keeps the system timezone up-to-date based on the current location
    automatic-timezoned = {
      enable = true;
    };

    udev = lib.mkIf (isWorkstation) {
      enable = true;

      # enable high precision timers if they exist
      # (https://gentoostudio.org/?page_id=420)
      # enable high precision timers if they exist && set I/O scheduler to NONE for ssd/nvme
      # autosuspend USB devices && autosuspend PCI devices
      # (https://gentoostudio.org/?page_id=420)
      extraRules = ''
        KERNEL=="rtc0", GROUP="audio"
        KERNEL=="hpet", GROUP="audio"
        ACTION=="add|change", KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="ext4", ATTR{../queue/scheduler}="kyber"
        ACTION=="add", SUBSYSTEM=="usb", TEST=="power/control", ATTR{power/control}="auto"cl
        ACTION=="add", SUBSYSTEM=="pci", TEST=="power/control", ATTR{power/control}="auto"
      '';
    };

    # broken
    # envfs.enable = lib.mkForce false; # populate /usr/bin for non-nix binaries
  };

  security = {
    # Enables simultaneous use of processor threads.
    allowSimultaneousMultithreading = true;

    polkit = lib.mkIf (isInstall) {
      enable = true;
      debug = lib.mkDefault true;

      # the below configuration depends on security.polkit.debug being set to true
      # so we have it written only if debugging is enabled
      extraConfig = ''
        polkit.addRule(function (action, subject) {
          if (subject.isInGroup('wheel'))
            return polkit.Result.YES;
        });
      '' + ''
        /* Log authorization checks. */
        polkit.addRule(function(action, subject) {
          polkit.log("user " +  subject.user + " is attempting action " + action.id + " from PID " + subject.pid);
        });
      '';
    };

    # Increase open file limit for sudoers
    pam = {
      # fix "too many files open" errors while writing a lot of data at once
      # (e.g. when building a large package)
      # if this, somehow, doesn't meet your requirements you may just bump the numbers up
      loginLimits = [
        {
          domain = "@wheel";
          item = "nofile";
          type = "soft";
          value = "524288";
        }
        {
          domain = "@wheel";
          item = "nofile";
          type = "hard";
          value = "1048576";
        }

        # GPU passthrough with vfio need memlock
        # {
        #   domain = "*";
        #   type = "-";
        #   item = "memlock";
        #   value = "infinity";
        # }
      ];
      # allow screen lockers to also unlock the screen
      # (e.g. swaylock, gtklock)
      services = {
        swaylock.text = "auth include login";
        gtklock.text = "auth include login";
      };

      # Enable pam_systemd module to set dbus environment variable.
      services.login.startSession = true;
    };
  };

  hardware = {
    enableRedistributableFirmware = true;

    # https://nixos.wiki/wiki/Bluetooth
    bluetooth =
      if (isWorkstation) then {
        enable = true;
        # package = pkgs.unstable.bluez5-experimental;
        package = pkgs.unstable.bluez-experimental;
        powerOnBoot = false;
        # hsphfpd.enable = false;
        # disabledPlugins = [ "sap" ];
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            JustWorksRepairing = "always";
            MultiProfile = "multiple";
            # make Xbox Series X controller work
            Class = "0x000100";
            ControllerMode = "bredr";
            FastConnectable = true;
            Privacy = "device";
            Experimental = true;
          };
        };
      } else {
        enable = true;
        package = pkgs.bluez;
        settings = {
          General = {
            Enable = "Source,Sink,Media,Socket";
            Experimental = true;
          };
        };
      };
  };
}
