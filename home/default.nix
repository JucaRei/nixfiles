{ config, inputs, isLima, isWorkstation, lib, outputs, pkgs, stateVersion, username, hostname, platform, flakepath, ... }:
with lib;
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  home-build = pkgs.writeScriptBin "home-build" ''
    #!${pkgs.stdenv.shell}

    if [ -e ${flakepath} ]; then
      all_cores=$(nproc)
      build_cores=$(${pkgs.coreutils}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
      echo "Building Nix Home-manager 🏠️ with $build_cores cores"
      ${pkgs.nh}/bin/nh home build ${flakepath} -- --impure --cores $build_cores
    else
      ${pkgs.coreutils}/bin/echo "ERROR! No nixfiles found in ${flakepath}"
    fi
  '';
  home-switch = pkgs.writeScriptBin "home-switch" ''
    #!${pkgs.stdenv.shell}

    if [ -e ${flakepath} ]; then
      all_cores=$(nproc)
      build_cores=$(${pkgs.coreutils}/bin/printf "%.0f" $(echo "$all_cores * 0.75" | ${pkgs.bc}/bin/bc))
      echo "Building Nix Home-manager 🏠️ with $build_cores cores"
      ${pkgs.nh}/bin/nh home switch --backup-extension backup ${flakepath} -- --impure --cores $build_cores
    else
      ${pkgs.coreutils}/bin/echo "ERROR! No nix-config found in ${flakepath}"
    fi
  '';
in
{
  imports = [ ]
    ++ optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
    # ++ optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix;
    ++ optional (builtins.pathExists (./. + "/hosts/${hostname}")) ./hosts/${hostname};

  home = {

    sessionVariables = mkDefault {
      EDITOR = mkDefault "micro";
      MANPAGER = mkDefault "sh -c 'col --no-backspaces --spaces | bat --language man'";
      MANROFFOPT = mkDefault "-c";
      MICRO_TRUECOLOR = mkDefault "1";
      PAGER = mkDefault "bat";
      SYSTEMD_EDITOR = mkDefault "micro";
      VISUAL = mkDefault "micro";
      NIXPKGS_ALLOW_UNFREE = mkDefault "1";
      NIXPKGS_ALLOW_INSECURE = mkDefault "1";
      FLAKE = mkDefault flakepath;
    };

    shellAliases = {
      mkhostid = mkIf isLinux "head -c4 /dev/urandom | od -A none -t x4";
      mkdir = "mkdir -pv";
      ip = mkIf isLinux "${pkgs.iproute2}/bin/ip --color --brief";
      less = mkDefault "${pkgs.bat}/bin/bat --paging=always";
      more = mkDefault "${pkgs.bat}/bin/bat --paging=always";
      du = mkDefault "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
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
      # store-path = "${pkgs.coreutils-full}/bin/readlink (${pkgs.which}/bin/which $argv)";
    };

    packages = with pkgs; [ home-build home-switch nix-whereis ];
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

    package = pkgs.nix;
    # auto upgrade nix to the unstable version
    # https://github.com/NixOS/nixpkgs/blob/nixos-unstable/pkgs/tools/package-management/nix/default.nix#L284
    # package = pkgs.nixVersions.latest;

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
    home-manager.enable = true;
    info.enable = true;
    jq.enable = true;
    nix-index.enable = true;
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
