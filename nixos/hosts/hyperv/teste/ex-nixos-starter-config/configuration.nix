{ inputs, pkgs, lib, config, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./persist.nix
  ];

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix.registry = (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs);

  # This will additionally add your inputs to the system's legacy channels
  # Making legacy nix commands consistent as well, awesome!
  nix.nixPath = [ "/etc/nix/path" ];

  environment.etc =
    lib.mapAttrs'
      (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      })
      config.nix.registry;

  nix.settings = {
    experimental-features = "nix-command flakes";
    auto-optimise-store = true;
  };

  networking.hostName = "hyperv";
  networking.networkmanager.enable = true;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  time.timeZone = "America/Sao_Paulo";

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  users.mutableUsers = false;

  users.users = {
    # password: temp a
    root.initialHashedPassword = "$6$iXUPCNyNN2.ulexC$k3IQgaw55qIKv2DNtOHMfICl7w5XolNwYN8j9RE16bIR7nqPd7uOndGQ00zJqAcfvxpP4NIUtNpgxunDidpVA/";

    juca = {
      # password: temp b
      initialHashedPassword = "$6$iXUPCNyNN2.ulexC$k3IQgaw55qIKv2DNtOHMfICl7w5XolNwYN8j9RE16bIR7nqPd7uOndGQ00zJqAcfvxpP4NIUtNpgxunDidpVA/";
      extraGroups = [ "wheel" ];
      isNormalUser = true;
      shell = pkgs.zsh;
    };
  };

  programs.zsh.enable = true;

  # Enables copy / paste when running in a KVM with spice.
  #services.spice-vdagentd.enable = true;

  virtualisation.hypervGuest.enable = true;

  services.xserver = {
    enable = true;
    desktopManager.plasma5.enable = true;
    displayManager.sddm.enable = true;
  };

  fonts.packages = with pkgs; [
    fira-mono
    hack-font
    inconsolata
    iosevka
  ];

  # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
  system.stateVersion = "23.11";
}
