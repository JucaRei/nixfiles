{ lib, config, desktop, inputs, hostid, hostname, username, stateVersion, modulesPath, outputs, platform, isInstall, isLaptop, isWorkstation, isISO, notVM, pkgs, ... }:
let
  inherit (lib) mkDefault mkIf mapAttrsToList optional optionals;
  variables = import ../hosts/${hostname}/variables.nix { inherit config username; }; # vars for better check
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;

in
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      (../. + "/hosts/${ hostname}")
      # ../_mixins/services/network/openssh.nix
      ../../resources/nixos/scripts
      # ../_mixins/services/network/networkmanager.nix
      ../_mixins/services/security/firewall.nix
      ../_mixins/features
      # ../_mixins/features/bluetooth

      # ../../resources/scripts/nixos
      ./boot.nix
      ./console.nix
      ./cpu.nix
      ./locale.nix
      ./optimizations.nix
      ./timezone.nix
      ./security.nix
      ./network.nix
      ./ssh.nix
      ./system.nix
    ]
    ++ optional (notVM && hostname != "soyo") ../_mixins/features/smartd # Wheather enable smart daemon
    ++ optional (notVM) ../_mixins/virtualization/docker # Wheather enable docker daemon
    ++ optional (notVM && hostname != "soyo") ../_mixins/virtualization/lxd # Wheather enable linux containers
    ++ optional (isWorkstation) ../_mixins/desktop # if has desktop environment
    # ++ optional (isWorkstation) ../_mixins/sys
    # ++ optional (hostname == "nitro") ../_mixins/features/nix-ld
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

  ########################
  ### Default Programs ###
  ########################
  programs = mkDefault {
    fuse.userAllowOther = isWorkstation;
    nano.enable = false;

    ######################
    ### Nix Cli helper ###
    ######################
    nh = {
      enable = true;
      flake = "${variables.flake-path}";
    };
  };

  services = {
    # snap daemon
    snap.enable = notVM && isISO;

    libinput = {
      enable = isWorkstation || isISO || isInstall;
      touchpad = mkIf isLaptop {
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
        accelProfile = mkDefault "adaptive";
      };
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

    # larger runtime directory size to not run out of ram while building
    # https://discourse.nixos.org/t/run-usr-id-is-too-small/4842
    logind.extraConfig = mkIf (isWorkstation) "RuntimeDirectorySize=2G";

    udev = mkIf isWorkstation {
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

  environment = {
    defaultPackages = with pkgs; [
      uutils-coreutils-noprefix
      micro
      nix-output-monitor
    ];
    systemPackages = with pkgs; [
      gitMinimal
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
      inputs.nixos-needtoreboot.packages.${platform}.default
      nvd
      nvme-cli
      smartmontools
      sops
      ssh-to-age
    ] ++ optionals (isInstall && hasNvidia) [
      vdpauinfo
    ];

    shellAliases =
      let
        _ = lib.getExe;
        __ = lib.getExe';
      in
      {
        system-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
        sxorg = "export DISPLAY=:0.0";
        drivers = "${__ pkgs.pciutils "lspci"} -v | grep -B8 -v 'Kernel modules: [a-z0-9]+'";
        r = "${_ pkgs.rsync} -ra --info=progress2";
        fd = "${_ pkgs.fd} --hidden --exclude .git";
        search = "nix search nixpkgs";
      };

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1"; # Allow unfree packages
      NIXPKGS_ALLOW_INSECURE = "1"; # Permit Insecure Packages
      FLAKE = "${variables.flake-path}";
    };

    localBinInPath = true; ## Add ~/.local/bin to $PATH

    ## Create a file in /etc/nixos-current-system-packages  Listing all Packages ###
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
}
