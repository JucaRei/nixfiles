{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs, stateVersion, username, hostid, platform, isWorkstation, isInstall, isISO, ... }:
with lib;
let
  notVM = if (hostname == "minimech") || (hostname == "scrubber") || (hostname == "vm") || (builtins.substring 0 5 hostname == "lima-") then false else true;
  # Create some variable to control what doesn't get installed/enabled
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;

  variables = import ./hosts/${hostname}/variables.nix { inherit config username; }; # vars for better check
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
    ++ lib.optional (notVM && hostname != "soyo") ./_mixins/services/tools/smartmon.nix
    ++ lib.optional (notVM) ./_mixins/features/docker
    ++ lib.optional (notVM && hostname != "soyo") ./_mixins/virtualization/lxd.nix
    ++ lib.optional (isWorkstation) ./_mixins/desktop
    ++ lib.optional (isWorkstation) ./_mixins/sys
    ++ lib.optional (hostname == "nitro") ./_mixins/features/nix-ld
  ;

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
    # give nix-daemon the lowest priority
    daemonIOSchedClass = "idle"; # Reduce disk usage
    # Leave nix builds as a background task
    daemonCPUSchedPolicy = "idle"; # Set CPU scheduling policy for daemon processes to idle
    daemonIOSchedPriority = 7; # Set I/O scheduling priority for daemon processes to 7
    gc = {
      automatic = true;
      dates = "20:00"; # Schedule the task to run weekly / daily and 24hr time
      options = "--delete-older-than 10d"; # Specify options for the task: delete files older than 10 days
      randomizedDelaySec = "14m";
    };
    # distributedBuilds = true;
    ### This will add each flake input as a registry
    ### To make nix3 commands consistent with your flake
    registry = mapAttrs (_: value: { flake = value; }) inputs;
    ### Add nixpkgs input to NIX_PATH
    ### This lets nix2 commands still use <nixpkgs>
    nixPath = [ "nixpkgs=${inputs.nixpkgs.outPath}" ];
    optimise = {
      automatic = true;
      dates = [ "14:00" ];
    };
    package = mkIf (isInstall) pkgs.unstable.nix;
    settings = {
      # Tell nix to use the xdg spec for base directories
      # while transitioning, any state must be carried over
      # manually, as Nix won't do it for us.
      use-xdg-base-directories = true;

      # Always build inside sandboxed environments
      # sandbox = true;
      sandbox-fallback = false;
      sandbox = "relaxed"; # true
      # extra-sandbox-paths = [ "/opt" ];

      # extra-sandbox-paths = [ ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake" # repl to inspect a flake
        "recursive-nix" # let nix invoke itself
        "ca-derivations" # content addressed nix
        "auto-allocate-uids" # allow nix to automatically pick UIDs, rather than creating nixbld* user accounts
        "cgroups" # allow nix to execute builds inside cgroups
      ];
      allowed-users = [ "root" "${username}" ];
      trusted-users = [ "root" "${username}" ];
      builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.
      ### Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      keep-going = true;
      warn-dirty = false;
      tarball-ttl = 300; # Set the time-to-live (in seconds) for cached tarballs to 300 seconds (5 minutes)
      use-cgroups = true; # execute builds inside cgroups
      system-features = [
        ## Allows building v3/v4 packages
        "gccarch-x86-64-v3"
        "gccarch-x86-64-v4"
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
    hostPlatform = mkDefault "${platform}";

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
      permittedInsecurePackages = [
        "python3.11-youtube-dl-2021.12.17"
      ];

      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  #############
  ### Hosts ###
  #############

  networking = {
    extraHosts = ''
      192.168.1.35  nitro
      192.168.1.45  rocinante
      192.168.1.76  dongle
      192.168.1.228 rocinante
      192.168.1.184 soyo
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
  boot = {
    initrd.verbose = mkDefault false;
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
    kernelModules = mkIf (notVM) [ "vhost_vsock" ];
    kernelParams = [
      "udev.log_priority=3"
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
    keyMap = mkIf (config.console.font != null) "${variables.keymap}";
    packages = with pkgs; [ tamzen ];
  };

  ###############
  ### Locales ###
  ###############

  i18n = {
    defaultLocale = mkDefault "${variables.df-locale}";
    extraLocaleSettings = mkDefault {
      #LC_CTYPE = mkDefault "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = "${variables.extra-locale}";
      LC_IDENTIFICATION = "${variables.extra-locale}";
      LC_MEASUREMENT = "${variables.extra-locale}";
      LC_MONETARY = "${variables.extra-locale}";
      LC_NAME = "${variables.extra-locale}";
      LC_NUMERIC = "${variables.extra-locale}";
      LC_PAPER = "${variables.extra-locale}";
      LC_TELEPHONE = "${variables.extra-locale}";
      LC_TIME = "${variables.extra-locale}";
      #LC_COLLATE = "${variables.extra-locale}";
      #LC_MESSAGES = "${variables.extra-locale}";
    };
  };

  ########################
  ### Default Timezone ###
  ########################

  time = lib.mkDefault
    {
      timeZone = "${variables.timezone}";

      ### For dual boot
      hardwareClockInLocalTime = isWorkstation;
    };

  #########################
  ### Defaults Packages ###
  #########################

  environment = with lib; {
    # Eject nano and perl from the system
    defaultPackages = with pkgs; lib.mkForce [
      coreutils-full
      micro
      nix-output-monitor
    ];

    systemPackages = with pkgs; [
      git
    ] ++ optionals (isISO) [
      inputs.nixos-needtoreboot.packages.${platform}.default
      inputs.crafts-flake.packages.${platform}.snapcraft
      distrobox
      #https://nixos.wiki/wiki/Podman
      podman-compose
      podman-tui
      podman
      flyctl
      fuse-overlayfs
    ] ++ optionals (isInstall || isWorkstation) [
      # inputs.crafts-flake.packages.${platform}.snapcraft
      # inputs.fh.packages.${platform}.default
      inputs.nixos-needtoreboot.packages.${platform}.default
      libva-utils
      nvd
      nvme-cli
      smartmontools
      sops
      ssh-to-age
    ] ++ optionals (isInstall && isWorkstation) [
      pods
    ] ++ optionals (isInstall && isWorkstation && notVM && hostname != "soyo") [
      quickemu
    ] ++ optionals (isInstall && hasNvidia) [
      # unstable.nvtop
      vdpauinfo
    ]
      # ++ optionals (isInstall && !hasNvidia) [
      #   nvtop-amd
      # ]
    ;

    variables = {
      EDITOR = "${variables.defaultEditor}";
      SYSTEMD_EDITOR = "${variables.defaultEditor}";
      VISUAL = "${variables.defaultEditor}";
    };

    # --------------------------------------------------------------------
    # Permit Insecure Packages && Allow unfree packages
    # --------------------------------------------------------------------

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";

      FLAKE = "${variables.flake-path}";
    };

    homeBinInPath = true;
    localBinInPath = true;

    shellAliases = {
      system-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
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
    fish =
      let
        config = import ../resources/nixos/fish { inherit lib pkgs isInstall hostname config username; };
      in
      {
        enable = isWorkstation;
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
          update-lock = "pushd $HOME/.dotfiles/nixfiles && nix flake update && popd";
        };
        shellAliases = {
          nano = "${variables.defaultEditor}";
        };
      };
  };

  nh = {
    clean = {
      enable = true;
      extraArgs = "--keep-since 10d --keep 5";
    };
    enable = true;
    flake = "${variables.flake-path}";
  };


  system = {
    nixos.label = lib.mkIf (isInstall) "-";
    stateVersion = stateVersion;
  };

  systemd = {
    user = {
      extraConfig = ''
        DefaultTimeoutStopSec=10s
        DefaultTimeoutAbortSec=8s
      '';
    };

    tmpfiles.rules = [
      "d /nix/var/nix/profiles/per-user/${username} 0755 ${username} root"
    ];

    extraConfig = ''
      DefaultTimeoutStartSec=8s
      DefaultTimeoutStopSec=10s
      DefaultDeviceTimeoutSec=8s
      DefaultTimeoutAbortSec=10s
    '';

    services = {

      # By default nix-gc makes no effort to respect battery life by avoding
      # GC runs on battery and fully commits a few cores to collecting garbage.
      # This will drain the battery faster than you can say "Nix, what the hell?"
      # and contribute heavily to you wanting to get a new desktop.
      # For those curious (such as myself) desktops are always seen as "AC powered"
      # so the system will not fail to fire if you are on a desktop system.
      nix-gc = {
        unitConfig.ConditionACPower = true;
      };
      # disable-wifi-powersave = {
      #   wantedBy = [ "multi-user.target" ];
      #   path = [ pkgs.iw ];
      #   script = ''
      #     iw dev wlan0 set power_save off
      #   '';
      # };

      # ---------------------------------------------------------------------
      # Do not restart these, since it messes up the current session
      # ---------------------------------------------------------------------
      NetworkManager.restartIfChanged = true;
      configure-flathub-repo.restartIfChanged = true;
      display-manager.restartIfChanged = false;
      libvirtd.restartIfChanged = false;
      openssh.restartIfChanged = true;
      polkit.restartIfChanged = true;
      systemd-logind.restartIfChanged = false;
      # wpa_supplicant.restartIfChanged = false;

      # Workaround https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = lib.mkForce false;
      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      systemd-udev-settle.enable = lib.mkForce false;
      # systemd-user-sessions.enable = false;

      # Modify autoconnect priority of the connection to my home network
      # modify-autoconnect-priority = {
      #   description = "Modify autoconnect priority of OPTUS_B27161 connection";
      #   script = ''
      #     nmcli connection modify OPTUS_B27161 connection.autoconnect-priority 1
      #   '';
      # };
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

    # Enable GEO location
    geoclue2 = {
      enable = true;
    };

    # Timesyncd: Synchronizes system time with network time servers
    timesyncd.enable = true;

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
          accelProfile = "adaptive";
          accelSpeed = "0.5";
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
    logind = {
      extraConfig = ''
        # Set the maximum size of runtime directories to 100%
        RuntimeDirectorySize=100%

        # Set the maximum number of inodes in runtime directories to 1048576
        RuntimeDirectoryInodesMax=1048576

        # to prevent nix-shell complaining about no space left
        # default value is 10% of total RAM
        # writes to: /etc/systemd/logind.conf
        RuntimeDirectorySize=2G
      '';
    };

    dbus = {
      # Enable the D-Bus service, which is a message bus system that allows
      # communication between applications.
      enable = true;
      implementation = "${variables.dbus-type}";
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
        KERNEL=="cpu_dma_latency", GROUP="audio"
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
      services.login.startSession = isWorkstation;
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
