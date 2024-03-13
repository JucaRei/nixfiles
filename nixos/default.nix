{ config, desktop, hostname, inputs, lib, modulesPath, outputs, pkgs, stateVersion, username, hostid, platform, ... }:
let
  notVM = if (hostname == "minimech" || hostname == "scrubber" || builtins.substring 0 5 hostname == "lima-") then false else true;
  # Create some variable to control what doesn't get installed/enabled
  isInstall = if (builtins.substring 0 4 hostname != "iso-") then true else false;
  isWorkstation = if (desktop != null) then true else false;
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
  syncthing = {
    hosts = [
      "nitro"
      "DietPi"
    ];
    tcpPorts = [ 22000 ];
    udpPorts = [ 22000 21027 ];
  };

  grub = import ./_mixins/hardware/boot/efi.nix;
  systemd-boot = import ./_mixins/hardware/boot/systemd-boot.nix;
in
{
  imports =
    [
      inputs.disko.nixosModules.disko
      inputs.nix-index-database.nixosModules.nix-index
      inputs.nix-snapd.nixosModules.default
      # inputs.sops-nix.nixosModules.sops
      (modulesPath + "/installer/scan/not-detected.nix")
      (./. + "/hosts/${hostname}")
      ./_mixins/services/network/openssh.nix
      ./_mixins/services/tools/smartmon.nix
      ./_mixins/config/scripts
      ./_mixins/services/network/networkmanager.nix
      ./_mixins/services/network/openssh.nix
      ./users
    ]
    # ++ lib.optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
    ++ lib.optional (isWorkstation) ./_mixins/desktop;

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
    # 🍑 smooth rebuilds
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

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    nixPath = lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry;

    optimise.automatic = true;
    package = lib.mkIf (isInstall) pkgs.unstable.nix;
    settings = {
      sandbox = true; #"relaxed"
      # extra-sandbox-paths = [ ];
      auto-optimise-store = true;
      experimental-features = [
        "nix-command"
        "flakes"
        "repl-flake"
      ];
      allowed-users = [ "root" "@wheel" ];
      # trusted-users = [ "root" "@wheel" ];
      # builders-use-substitutes = true; # Avoid copying derivations unnecessary over SSH.

      # Avoid unwanted garbage collection when using nix-direnv
      keep-outputs = true;
      keep-derivations = true;
      # keep-going = false;
      warn-dirty = false;
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
    #min-free = ${toString (512 * 1024 * 1024)}
    #min-free = 1073741824 # 1GiB
    #max-free = 4294967296 # 4GiB
    #builders-use-substitutes = true
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
      # Add overlays exported from other flakes:

      # inputs.nixd.overlays.default
      # inputs.agenix.overlays.default


      # workaround for: https://github.com/NixOS/nixpkgs/issues/154163
      (_: super: {
        makeModulesClosure = x:
          super.makeModulesClosure (x // { allowMissing = true; });
      })

      ## Testing
      # (self: super: {


      #   mpv =
      #     super.mpv.override { scripts = with super.mpvScripts; [ mpris ]; };
      #   # vaapiIntel = super.vaapiIntel.override { enableHybridCodec = true; };
      #   deadbeef = super.deadbeef.override { wavpackSupport = true; };
      #   deadbeef-with-plugins = super.deadbeef-with-plugins.override {
      #     plugins = with super.deadbeefPlugins; [ mpris2 statusnotifier ];
      #   };
      # })
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
    useDHCP = lib.mkDefault true;
    firewall = {
      enable = true;
      allowedTCPPorts = [ 22 ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.tcpPorts;
      allowedUDPPorts = [ ]
        ++ lib.optionals (builtins.elem hostname syncthing.hosts) syncthing.udpPorts;
      trustedInterfaces = lib.mkIf (isInstall) [ "lxdbr0" ];
    };
  };

  ############################
  ### Default Boot Options ###
  ############################

  # Only enable the grub on installs, not live media (.ISO images)
  grub = lib.mkIf (isInstall);

  boot = with lib; {
    initrd = {
      verbose = mkDefault false;
    };
    consoleLogLevel = mkDefault 0;
    kernelModules = [ "vhost_vsock" "tcp_bbr" ];
    kernelParams = [
      "boot.shell_on_fail"
      "loglevel=3"
      "rd.systemd.show_status=false"
      "rd.udev.log_level=3"
      "udev.log_priority=3"
    ];
    kernelPackages = mkDefault pkgs.linuxPackages_latest;
    kernel = {
      sysctl = {
        "net.ipv4.ip_forward" = 1;
        "net.ipv6.conf.all.forwarding" = 1;
        # Keep zram swap (lz4) latency in check
        "vm.page-cluster" = 1;
        # "vm.nr_hugepages" = lib.mkDefault "0"; # disabled is better for DBs
        ### Improve networking
        # https://www.kernel.org/doc/html/latest/admin-guide/sysrq.html
        "kernel.sysrq" = 1; # magic keyboard shortcuts
        # TCP Fast Open is a TCP extension that reduces network latency by packing
        # data in the sender’s initial TCP SYN. Setting 3 = enable TCP Fast Open for
        # both incoming and outgoing connections:
        "net.ipv4.tcp_fastopen" = 3;
        # Bufferbload mitigations + slight improvement in throughput & latency
        "net.ipv4.tcp_congestion_control" = "bbr";
        "net.core.default_qdisc" = "cake";
        #"net.core.default_qdisc" = "fq";

        # Bypass hotspot restrictions for certain ISPs
        "net.ipv4.ip_default_ttl" = 65;

        # "vm.swappiness" = 30; # default 60, between 0 to 100. 10 means try to not swap
        # "vm.vfs_cache_pressure" = 200; # default 100, recommended between 50 to 500. 500 means less file cache for less swapping
        # TODO: the higher default of 10% of RAM would be better here,
        # but it makes removable storage dangerous as it's a system wide setting
        # and there's no way to make the limit smaller for removable storeage
        # I also haven't found an easy way to make removeable storage mount with sync option
        # "vm.dirty_bytes" = 1024 * 1024 * 512;
        # "vm.dirty_background_bytes" = 1024 * 1024 * 32;
        # "vm.dirty_background_ratio" = 10; # default 10, start writting dirty pages at this ratio
        # "vm.dirty_ratio" = 40; # default 20, maximum ratio, block process when reached
      };
    };
    supportedFilesystems = [ "ext4" "btrfs" "exfat" "ntfs" ];
  };

  ###################
  ### Console tty ###
  ###################
  console = {
    font = "${pkgs.tamzen}/share/consolefonts/TamzenForPowerline10x20.psf";
    keyMap = if (hostname == "nitro") then "br" else "us";
    packages = with pkgs; [ tamzen ];
  };

  ###############
  ### Locales ###
  ###############

  i18n = {
    defaultLocale = lib.mkForce "en_US.utf8";
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

  time = lib.mkDefault {
    timeZone = "America/Sao_Paulo";

    ### For dual boot
    hardwareClockInLocalTime = lib.mkIf (isWorkstation && hostname == "nitro");
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
      inputs.crafts-flake.packages.${platform}.snapcraft
      inputs.fh.packages.${platform}.default
      inputs.nixos-needtoreboot.packages.${platform}.default
      clinfo
      unstable.distrobox
      flyctl
      fuse-overlayfs
      libva-utils
      nvme-cli
      #https://nixos.wiki/wiki/Podman
      podman-compose
      podman-tui
      podman
      smartmontools
      sops
      ssh-to-age
    ] ++ lib.optionals (isInstall && isWorkstation) [
      pods
    ] ++ lib.optionals (isInstall && isWorkstation && notVM) [
      quickemu
    ] ++ lib.optionals (isInstall && hasNvidia) [
      nvtop
      vdpauinfo
    ] ++ lib.optionals (isInstall && !hasNvidia) [
      nvtop-amd
    ];

    variables = {
      EDITOR = "micro";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";

      FLAKE = "/home/${username}/.dotfiles/nixfiles";
    };

    # --------------------------------------------------------------------
    # Permit Insecure Packages && Allow unfree packages
    # --------------------------------------------------------------------

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
    command-not-found.enable = false;
    dconf.enable = true;
    fish-terminal = import ./_mixins/console/fish.nix;
    nano.enable = false;
    nix-index-database.comma.enable = isInstall;
    nix-ld = lib.mkIf (isInstall) {
      enable = true;
      libraries = with pkgs; [
        # Add any missing dynamic libraries for unpackaged
        # programs here, NOT in environment.systemPackages
      ];
    };
    ssh.startAgent = true;
  };

  system = {
    activationScripts = {
      diff = lib.mkIf (isInstall) {
        supportsDryActivation = true;
        # text = ''
        #   if [ -e /run/current-system/boot.json ] && ! ${pkgs.gnugrep}/bin/grep -q "LABEL=nixos-minimal" /run/current-system/boot.json; then
        #     ${pkgs.nvd}/bin/nvd --nix-bin-dir=${pkgs.nix}/bin diff /run/current-system "$systemConfig"
        #   fi
        #   /run/current-system/sw/bin/nixos-reedsreboot
        # '';

        text = ''
          if [[ -e /run/current-system ]]; then
            echo -e "\n***            ***          ***           ***           ***\n"
            ${pkgs.nix}/bin/nix store diff-closures /run/current-system "$systemConfig" | grep -w "→" | grep -w "KiB" | column --table --separator " ,:" | ${pkgs.choose}/bin/choose 0:1 -4:-1 | ${pkgs.gawk}/bin/awk '{s=$0; gsub(/\033\[[ -?]*[@-~]/,"",s); print s "\t" $0}' | sort -k5,5gr | ${pkgs.choose}/bin/choose 6:-1 | column --table
            echo -e "\n***            ***          ***           ***           ***\n"
          fi
          /run/current-system/sw/bin/nixos-reedsreboot
        '';
      };
    };

    nixos.label = lib.mkIf (isInstall) "-";
    stateVersion = stateVersion;

    autoUpgrade = {
      enable = false;
      allowReboot = false;
      channel = "https://nixos.org/channels/nixos-unstable";
      flags = [
        "--update-input"
        "nixpkgs"
        "-L" # print build logs
      ];
      dates = "monthly";
      randomizedDelaySec = "45min";
    };
  };

  systemd = {
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
      # Workaround https://github.com/NixOS/nixpkgs/issues/180175
      NetworkManager-wait-online.enable = lib.mkForce false;
      # Speed up boot
      # https://discourse.nixos.org/t/boot-faster-by-disabling-udev-settle-and-nm-wait-online/6339
      systemd-udev-settle.enable = lib.mkForce false;
      # systemd-user-sessions.enable = false;
    };
  };

  services = {
    journald = {
      extraConfig = lib.mkDefault ''
        SystemMaxUse=10M
        SystemMaxFileSize=10M
        RuntimeMaxUse=10M
        RuntimeMaxFileSize=10M
        MaxFileSec=7day
        SystemMaxFiles=5
      '';
      rateLimitBurst = 800;
      rateLimitInterval = "5s";
    };

    dbus = {
      # Enable the D-Bus service, which is a message bus system that allows
      # communication between applications.
      enable = true;
      implementation = if (hostname == "nitro") then "broker" else "dbus";
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
  };

  ############
  ### Virt ###
  ############

  virtualisation = lib.mkIf (isInstall) import [
    ./_mixins/virtualization/podman.nix
    ./_mixins/virtualization/lxd.nix
  ];
  hardware.enableRedistributableFirmware = true;
}
