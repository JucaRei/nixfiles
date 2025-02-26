{ config, inputs, isLima, isWorkstation, lib, outputs, pkgs, stateVersion, username, isOtherOS, system, ... }:
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) optional optionals mkIf mkOverride mkDefault;
  isNixos = builtins.hasAttr "system" config; # only present on NixOS systems
  checkVer = if isNixos == true then false else true;
in
{
  imports = with inputs; [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # homeManagerModules.example

    # Modules exported from other flakes:
    nur.modules.homeManager.default
    catppuccin.homeManagerModules.catppuccin
    sops-nix.homeManagerModules.sops
    nix-index-database.hmModules.nix-index
    nix-flatpak.homeManagerModules.nix-flatpak
    chaotic.homeManagerModules.default

    ./_mixins/features
    ../resources/hm-configs/scripts
    ../resources/hm-configs/console
  ]
  # ++ optional isWorkstation ./_mixins/features
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

    activation = {
      diff = lib.hm.dag.entryAnywhere ''
        if [[ -n ''${oldGenPath:-} ]] && [[ -n ''${newGenPath:-} ]]; then
          ${lib.getExe config.nix.package} \
            --extra-experimental-features 'nix-command' \
            store diff-closures $oldGenPath $newGenPath || true
        fi
      '';
    };

    packages =
      with pkgs; [
        fd # Modern Unix `find`
        netdiscover # Modern Unix `arp`
      ]
      ++ optionals (isOtherOS) [
        pciutils # Terminal PCI info
        duf # Modern Unix `df`
        usbutils # Terminal USB info
      ];

    sessionVariables = {
      NIXPKGS_ALLOW_UNFREE = "1";
      NIXPKGS_ALLOW_INSECURE = "1";
      EDITOR = "micro";

      MICRO_TRUECOLOR = "1";
      PAGER = "bat";
      SYSTEMD_EDITOR = "micro";
      VISUAL = "micro";
    };

    enableNixpkgsReleaseCheck = false;
  };

  # Workaround home-manager bug with flakes
  # - https://github.com/nix-community/home-manager/issues/2033
  news.display = "silent";

  # nixpkgs = mkOverride 1500 (mkIf (!isNixos)
  nixpkgs = {
    overlays = [
      inputs.nixgl.overlay # for non-nixos linux system's

      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.oldstable-packages
    ];
    # Configure your nixpkgs instance
    config = mkIf (checkVer) {
      allowUnfree = true;
      # allowUnfreePredicate = (_: true);
      # permittedInsecurePackages = [ ];
    };
    # });
  };

  nix = mkIf (checkVer) {
    # package = optional (isNixos == false) pkgs.nixVersions.latest;
    # package = mkDefault (optional checkVer pkgs.nixVersions.latest);
    # package = mkDefault pkgs.nixVersions.latest;
    package = mkDefault pkgs.nix;
    # package = if isNixos then pkgs.nixVersions.latest else null;
    settings = {
      experimental-features = "flakes nix-command";
      trusted-users = [ "root" "${username}" ];
      allowed-users = [ "root" "${username}" ];
      warn-dirty = false;
      allow-dirty = true;
    };

    extraOptions = ''
      # Free up to 1GiB whenever there is less than 100MiB left.
      # min-free = ${toString (100 * 1024 * 1024)}
      # max-free = ${toString (1024 * 1024 * 1024)}
      # Free up to 2GiB whenever there is less than 1GiB left.
      min-free = ${toString (1024 * 1024 * 1024)}        # 1 GiB
      max-free = ${toString (3 * 1024 * 1024 * 1024)}    # 3 GiB
    ''
    + pkgs.lib.optionalString (pkgs.system == "aarch64-darwin") ''
      extra-platforms = x86_64-darwin
    '';
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
    # gpg-agent = mkIf isLinux {
    #   enable = isLinux;
    #   enableSshSupport = true;
    #   pinentryPackage = pkgs.pinentry-curses;
    # };
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
    # sops = mkIf (username == "juca") {
    age = {
      # automatically import host SSH key as age keys
      # sshKeyPaths = [ "/home/${username}/.ssh/machines/personal/nitro" ];
      # this will use an agey key that is expected to already be in the filesystem
      keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      generateKey = false;
      # generate a new key if the key specified above does not exist
      # generateKey = true;
    };
    defaultSopsFile = ../secrets/secrets.yaml;
    # validateSopsFiles = false;
    # sops-nix options: https://dl.thalheim.io/

    # secrets will be output to /run/secrets
    # e.g. /run/secrets/password
    # secrets required for user creation are handled in respective ./users/<username>.nix files
    # because they will be output to /run/secrets-for-users and only when the user is assigned to a host
    secrets = {
      # password = { };
      # asciinema.path = "${config.home.homeDirectory}/.config/asciinema/config";
      # atuin_key.path = "${config.home.homeDirectory}/.local/share/atuin/key";
      # gh_token = { };
      # gpg_private = { };
      # gpg_public = { };
      # gpg_ownertrust = { };
      # hueadm.path = "${config.home.homeDirectory}/.hueadm.json";
      # obs_secrets = { };
      # ssh_config.path = "${config.home.homeDirectory}/.ssh/config";
      ssh_key.path = "${config.home.homeDirectory}/.ssh/machines/personal/nitro";
      ssh_key_pub.path = "${config.home.homeDirectory}/.ssh/machines/personal/nitro.pub";
      # ssh_semaphore_key.path = "${config.home.homeDirectory}/.ssh/id_rsa_semaphore";
      # ssh_semaphore_pub.path = "${config.home.homeDirectory}/.ssh/id_rsa_semaphore.pub";
      # transifex.path = "${config.home.homeDirectory}/.transifexrc";
    };
  };

  systemd = {
    user = {
      # Nicely reload system units when changing configs
      startServices = mkIf isLinux "sd-switch";

      # Create age keys directory for SOPS
      tmpfiles = mkIf isLinux {
        rules = [
          "d ${config.home.homeDirectory}/.config/sops/age 0755 ${username} users - -"
        ];
      };
    };
  };
}
