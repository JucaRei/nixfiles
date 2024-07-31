{ lib, config, desktop, inputs, hostid, hostname, username, stateVersion, modulesPath, outputs, platform, isInstall, isWorkstation, isISO, notVM, pkgs, ... }:
with lib;

let
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  variables = import ./hosts/${hostname}/variables.nix { inherit config username; }; # vars for better check
in

{
  imports =
    [
      inputs.disko.nixosModules.disko
      inputs.nh.nixosModules.default
      inputs.catppuccin.nixosModules.catppuccin
      inputs.nix-flatpak.nixosModules.nix-flatpak
      inputs.nix-index-database.nixosModules.nix-index
      inputs.nix-snapd.nixosModules.default
      inputs.sops-nix.nixosModules.sops
      (modulesPath + "/installer/scan/not-detected.nix")
      (./. + "/hosts/${ hostname}")
      ./_mixins/services/network/openssh.nix
      ./_mixins/config/scripts
      ./_mixins/services/network/networkmanager.nix
      ./_mixins/services/security/firewall.nix
      ./_mixins/features/boot
      ./_mixins/features/bluetooth
      ./users
    ]
    ++ lib.optional (notVM && hostname != "soyo") ./_mixins/features/smartd # Wheather enable smart daemon
    ++ lib.optional (notVM) ./_mixins/features/docker # Wheather enable docker daemon
    ++ lib.optional (notVM && hostname != "soyo") ./_mixins/features/lxd # Wheather enable linux containers
    ++ lib.optional (isWorkstation) ./_mixins/desktop # if has desktop environment
    ++ lib.optional (isWorkstation) ./_mixins/sys
    ++ lib.optional (hostname == "nitro") ./_mixins/features/nix-ld
  ;

  ######################
  ### Documentations ###
  ######################
  documentation = mkDefault {
    enable = true; # documentation of packages
    nixos.enable = false; # nixos documentation
    man.enable = true; # manual pages and the man command
    info.enable = false; # info pages and the info command
    doc.enable = false; # documentation distributed in packages' /share/doc
  };

  ############################
  ### Default Boot Options ###
  ############################

  ## Only enable the grub on installs, not live media (.ISO images)
  boot = {
    initrd.verbose = mkDefault false;
    consoleLogLevel = 3; # Silence ACPI "errors" at boot shown before NixOS stage 1 output (default is 4)
    tmp = {
      cleanOnBoot = mkDefault true;
      useTmpfs = mkDefault false;
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
      };
    };
    supportedFilesystems = [
      "ext4"
      "exfat"
      "ntfs"
      # "bcachefs"
      # "btrfs"
    ];
  };

  #######################
  ### Default Locales ###
  #######################
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

  time = mkDefault {
    timeZone = "${variables.timezone}";

    ### For dual boot
    hardwareClockInLocalTime = isWorkstation && hostname == "nitro";
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

  ###################
  ### Console tty ###
  ###################
  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    # keyMap = lib.mkDefault "us";
    keyMap = mkIf (config.console.font != null) "${variables.keymap}";
    packages = with pkgs; [ tamzen ];
  };

  ########################
  ### Default Programs ###
  ########################
  programs = mkDefault {
    fuse.userAllowOther = isWorkstation;
    nano.enable = false;
    ssh.startAgent = true;
    fish = {
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
      shellAliases = {
        nano = "${variables.defaultEditor}";
      };
    };
  };

  #########################
  ### Defaults Packages ###
  #########################

  environment = {
    # Eject nano and perl from the system
    defaultPackages = with pkgs; mkForce [
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
      podman-compose
      podman-tui
      podman
      flyctl
      fuse-overlayfs
    ] ++ optionals (isInstall || isWorkstation) [
      # inputs.fh.packages.${platform}.default
      inputs.nixos-needtoreboot.packages.${platform}.default
      nvd
      nvme-cli
      smartmontools
      sops
      ssh-to-age
    ] ++ optionals (isInstall && hasNvidia) [
      vdpauinfo
    ];

    variables = {
      EDITOR = "${variables.defaultEditor}";
      SYSTEMD_EDITOR = "${variables.defaultEditor}";
      VISUAL = "${variables.defaultEditor}";
    };

    #################################
    ### Default Session Variables ###
    #################################
    sessionVariables = {
      ### Permit Insecure Packages && Allow unfree packages ###
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      FLAKE = "${variables.flake-path}";
    };

    localBinInPath = true; ### Add ~/.local/bin to $PATH

    #############################
    ### Default Shell Aliases ###
    #############################
    shellAliases = {
      system-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      sxorg = "export DISPLAY=:0.0";
      drivers = "lspci -v | grep -B8 -v 'Kernel modules: [a-z0-9]+'";
      r = "rsync -ra --info=progress2";
      fd = "fd --hidden --exclude .git";
      search = "nix search nixpkgs";
    };

    #################################################################################
    ### Create a file in /etc/nixos-current-system-packages  Listing all Packages ###
    #################################################################################
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

  ######################
  ### Nix Cli helper ###
  ######################
  nh = {
    clean = {
      enable = true;
      extraArgs = "--keep-since 10d --keep 5";
    };
    enable = true;
    flake = "${variables.flake-path}";
  };

  ##############
  ### Tweaks ###
  ##############
  system = {
    nixos = {
      label = mkIf (isInstall) (builtins.concatStringsSep "-" [ "${hostname}-" ] + config.system.nixos.version);
      tags = mkIf (isInstall) [ "NixOS" ];
    };
    stateVersion = stateVersion;
  };

  systemd = {
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
      ### Nix gc when powered
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

      # Workaround https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = lib.mkForce false;
      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      systemd-udev-settle.enable = lib.mkForce false;

      # Modify autoconnect priority of the connection to my home network
      # modify-autoconnect-priority = {
      #   description = "Modify autoconnect priority of OPTUS_B27161 connection";
      #   script = ''
      #     nmcli connection modify OPTUS_B27161 connection.autoconnect-priority 1
      #   '';
      # };
    };

    targets = lib.mkIf (hostname == "soyo") {
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };

    # enable cgroups=v2 as default
    enableUnifiedCgroupHierarchy = mkForce isInstall;
  };

  services = {
    ##################
    ### My modules ###
    ##################
    nm-manager.enable = true;
    firewall.enable = isWorkstation;

    # snap daemon
    snap.enable = notVM && isWorkstation;
    # Enable GEO location
    geoclue2 = mkForce {
      enable = isWorkstation;
    };
    fwupd = {
      enable = isInstall;
    };

    dbus = mkDefault {
      packages = with pkgs; [ gnome-keyring gcr ];
      implementation = "broker";
    };

    # Local services
    avahi = {
      enable = isWorkstation;
      nssmdns4 = config.services.avahi.enable;
      openFirewall = config.services.avahi.enable;
      publish = {
        addresses = true;
        enable = true;
        workstation = isWorkstation;
      };
    };

    kmscon = mkIf (isInstall) {
      enable = true;
      hwRender = true;
      fonts = [{
        name = "FiraCode Nerd Font Mono";
        package = pkgs.nerdfonts.override { fonts = [ "FiraCode" ]; };
      }];
      extraConfig =
        ''
          font-size=14
          xkb-layout=br
        '';
    };

    xserver = {
      ### Touchpad
      libinput = {
        enable = isWorkstation && hostname == "nitro";
        touchpad = {
          accelProfile = "adaptive";
          accelSpeed = "0.6";
          tapping = true;
          scrollMethod = "twofinger";
          disableWhileTyping = true;
          clickMethod = "clickfinger";
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
      extraConfig = mkDefault ''
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
    logind = mkIf (isInstall) {
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
      enable = mkForce true;
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
  };

  security = {
    allowSimultaneousMultithreading = true; # Enables simultaneous use of processor threads.

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

    pam = {
      # Increase open file limit for sudoers
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
      ];

      services =
        let
          ttyAudit = {
            enable = true;
            enablePattern = "*";
          };
        in
        {
          # Allow screen lockers such as Swaylock or gtklock) to also unlock the screen.
          swaylock.text = "auth include login";
          gtklock.text = "auth include login";

          login = {
            inherit ttyAudit;
            setLoginUid = true;
          };

          sshd = {
            inherit ttyAudit;
            setLoginUid = true;
          };

          sudo = {
            inherit ttyAudit;
            setLoginUid = true;
          };


          # Enable pam_systemd module to set dbus environment variable.
          login.startSession = mkForce isWorkstation;
        };
    };
  };
}
