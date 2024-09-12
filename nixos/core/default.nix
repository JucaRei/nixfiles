{ lib, config, desktop, inputs, hostid, hostname, username, stateVersion, modulesPath, outputs, platform, isInstall, isWorkstation, isISO, notVM, pkgs, ... }:
with lib;
let
  variables = import ../hosts/${hostname}/variables.nix { inherit config username; }; # vars for better check
  hasNvidia = lib.elem "nvidia" config.services.xserver.videoDrivers;
in
{
  imports =
    [
      (modulesPath + "/installer/scan/not-detected.nix")
      (../. + "/hosts/${ hostname}")
      # ../_mixins/services/network/openssh.nix
      ../_mixins/config/scripts
      # ../_mixins/services/network/networkmanager.nix
      ../_mixins/services/security/firewall.nix
      # ../_mixins/features/boot
      # ../_mixins/features/bluetooth
      ./boot.nix
      ./console.nix
      ./hardware.nix
      ./locale.nix
      ./timezone.nix
      ./network.nix
      ./ssh.nix
      ./system.nix
    ]
    ++ lib.optional (notVM && hostname != "soyo") ../_mixins/features/smartd # Wheather enable smart daemon
    ++ lib.optional (notVM) ../_mixins/features/docker # Wheather enable docker daemon
    ++ lib.optional (notVM && hostname != "soyo") ../_mixins/features/lxd # Wheather enable linux containers
    ++ lib.optional (isWorkstation) ../_mixins/desktop # if has desktop environment
    ++ lib.optional (isWorkstation) ../_mixins/sys
    ++ lib.optional (hostname == "nitro") ../_mixins/features/nix-ld
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
      clean.enable = true;
      clean.extraArgs = "--keep-since 4d --keep 3";
      flake = "${variables.flake-path}";
    };
  };

  services = {
    # snap daemon
    snap.enable = notVM && isISO;

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
  };

  environment = {
    defaultPackages = with pkgs; [
      coreutils
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

    shellAliases = {
      system-clean = "sudo nix-collect-garbage -d && nix-collect-garbage -d";
      sxorg = "export DISPLAY=:0.0";
      drivers = "${pkgs.pciutils}/bin/lspci -v | grep -B8 -v 'Kernel modules: [a-z0-9]+'";
      r = "${pkgs.rsync}/bin/rsync -ra --info=progress2";
      fd = "${pkgs.fd}/bin/fd --hidden --exclude .git";
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
