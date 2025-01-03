{ config, inputs, isLima, isWorkstation, lib, outputs, pkgs, stateVersion, username, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) optional mkIf;
  isOtherOS = if builtins.isString (builtins.getEnv "__NIXOS_SET_ENVIRONMENT_DONE") then false else true;
in
{
  imports = with inputs // outputs; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Modules exported from other flakes:
    nur.modules.homeManager.default
    catppuccin.homeManagerModules.catppuccin
    sops-nix.homeManagerModules.sops
    nix-index-database.hmModules.nix-index
    nix-flatpak.homeManagerModules.nix-flatpak
    chaotic.homeManagerModules.default

    ../resources/hm-configs/scripts
    ../resources/hm-configs/console
  ]
  ++ optional isWorkstation ./_mixins/features
  ++ optional isWorkstation ./_mixins/desktop
  # ++ optional (builtins.pathExists (./. + "/hosts/${hostname}")) ./hosts/${hostname}
  ++ optional (builtins.pathExists (./. + "/hosts")) ./hosts
  # ++ optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
  ++ optional (builtins.pathExists (./. + "/users")) ./users
  ;

  catppuccin = {
    accent = "blue";
    flavor = "mocha";
  };

  home = {
    inherit stateVersion;
    inherit username;
    homeDirectory = if isDarwin then "/Users/${username}" else if isLima then "/home/${username}.linux" else "/home/${username}";

    packages =
      with pkgs; [
        fd # Modern Unix `find`
        netdiscover # Modern Unix `arp`
      ]
      ++ optional isOtherOS [
        pciutils # Terminal PCI info
        duf # Modern Unix `df`
        usbutils # Terminal USB info
      ];

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      EDITOR = "micro";
      # MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
      # MANROFFOPT = "-c";
      MICRO_TRUECOLOR = "1";
      PAGER = "bat";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };

    sessionPath = [
      "$HOME/.local/bin"
      "$HOME/.local/share/applications"
    ];
  };

  # Workaround home-manager bug with flakes
  # - https://github.com/nix-community/home-manager/issues/2033
  news.display = "silent";

  nixpkgs = {
    overlays = with outputs; [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      overlays.additions
      overlays.modifications
      overlays.unstable-packages
      overlays.oldstable-packages
    ];
    # Configure your nixpkgs instance
    config = {
      allowUnfree = true;
    };
  };

  nix = {
    package = pkgs.nixVersions.latest;
    settings = {
      experimental-features = "flakes nix-command";
      trusted-users = [ "root" "${username}" ];
    };
  };

  console = {
    bat.enable = true;
    bottom.enable = true;
    lsd.enable = true;
    man.enable = isOtherOS;
    zoxide.enable = true;
  };

  programs = {
    nix-index.enable = true;
  };

  services = {
    gpg-agent = mkIf isLinux {
      enable = isLinux;
      enableSshSupport = true;
      pinentryPackage = pkgs.pinentry-curses;
    };
    # pueue = {
    #   enable = isLinux;
    #   # https://github.com/Nukesor/pueue/wiki/Configuration
    #   settings = {
    #     daemon = {
    #       default_parallel_tasks = 1;
    #     };
    #   };
    # };
  };

  sops = mkIf (username == "teste") {
    age = {
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      generateKey = false;
    };
    defaultSopsFile = ../secrets/secrets.yaml;
    # sops-nix options: https://dl.thalheim.io/
    secrets = {
      asciinema.path = "${config.home.homeDirectory}/.config/asciinema/config";
      atuin_key.path = "${config.home.homeDirectory}/.local/share/atuin/key";
      gh_token = { };
      gpg_private = { };
      gpg_public = { };
      gpg_ownertrust = { };
      hueadm.path = "${config.home.homeDirectory}/.hueadm.json";
      obs_secrets = { };
      ssh_config.path = "${config.home.homeDirectory}/.ssh/config";
      ssh_key.path = "${config.home.homeDirectory}/.ssh/id_rsa";
      ssh_pub.path = "${config.home.homeDirectory}/.ssh/id_rsa.pub";
      ssh_semaphore_key.path = "${config.home.homeDirectory}/.ssh/id_rsa_semaphore";
      ssh_semaphore_pub.path = "${config.home.homeDirectory}/.ssh/id_rsa_semaphore.pub";
      transifex.path = "${config.home.homeDirectory}/.transifexrc";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = mkIf isLinux "sd-switch";
}
