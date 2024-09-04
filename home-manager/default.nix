{ config, desktop, inputs, lib, outputs, pkgs, stateVersion, username, hostname, isWorkstation, isLima, ... }:
#############################################
### Default Home-Manager configs for all. ###
#############################################
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  inherit (lib) optional optionals mkOption types mkIf;
  home-build = import ../resources/scripts/nix/home-build.nix { inherit pkgs; };
  home-switch = import ../resources/scripts/nix/home-switch.nix { inherit pkgs; };
  gen-ssh-key = import ../resources/scripts/nix/gen-ssh-key.nix { inherit pkgs; };
  home-manager_change_summary = import ../resources/scripts/nix/home-manager_change_summary.nix { inherit pkgs; };
  isOld = if (hostname == "oldarch") then false else true;
  isGeneric = if (config.custom.nonNixOs.enable) then true else false;
in
{
  imports = [
    ./_mixins/console
    ./_mixins/non-nixos
    ./core/xdg.nix
  ]
  ++ optional (builtins.pathExists (./. + "/users/${username}")) ./users/${username}
  ++ optional (builtins.pathExists (./. + "/hosts/${hostname}.nix")) ./hosts/${hostname}.nix
  ++ optional (isWorkstation) ./_mixins/desktop;
  catppuccin = {
    accent = "lavender";
    flavor = "frappe";
  };
  home = {
    inherit stateVersion;
    inherit username;
    activation = {
      report-changes = config.lib.dag.entryAnywhere ''
        if [[ -n "$oldGenPath" && -n "$newGenPath" ]]; then
          ${pkgs.nvd}/bin/nvd diff $oldGenPath $newGenPath
        fi
      '';
    };
    homeDirectory = if isDarwin then "/Users/${username}" else if isLima then "/home/${username}.linux" else "/home/${username}";
    sessionVariables =
      let
        editor = "micro"; # change for whatever you want
      in
      {
        NIXPKGS_ALLOW_UNFREE = "1";
        NIXPKGS_ALLOW_INSECURE = "1";
        FLAKE = "/home/${username}/.dotfiles/nixfiles";
        EDITOR = "${editor}";
        PAGER = "${pkgs.moar}/bin/moar";
        SYSTEMD_EDITOR = "${editor}";
        VISUAL = "${editor}";
      };
    packages = with pkgs;[
      home-build
      home-switch
      gen-ssh-key
      home-manager_change_summary
      nix-whereis
      duf # Modern Unix `df`
      fd # Modern Unix `find`
      netdiscover # Modern Unix `arp`
    ] ++ optionals isDarwin [
      m-cli # Terminal Swiss Army Knife for macOS
    ] ++ optionals isLinux [
      iw # Terminal WiFi info
      pciutils # Terminal PCI info
      usbutils # Terminal USB info
      zsync # Terminal file sync; FTBFS on aarch64-darwin
      # compression
      lzop
      p7zip
      unrar
      zip
    ]
    # ++ optionals isGeneric [
    #   nix-output-monitor
    #   nixpkgs-fmt
    #   nil
    # ]
    ++ optionals (isGeneric && isOld) [
      nixgl.auto.nixGLDefault
    ];
    file = {
      ".hidden".text = ''snap'';
    };
  };
  programs = {
    info.enable = true;
    jq = {
      enable = true;
      package = pkgs.jiq;
    };
  };
  news.display = "silent";
  nixpkgs = {
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages
      outputs.overlays.legacy-packages
      inputs.nixgl.overlay
      inputs.nur.overlay
      # Or define it inline, for example:
      (_final: _prev: {
        # hi = final.hello.overrideAttrs (oldAttrs: {
        #   patches = [ ./change-hello-to-hi.patch ];
        # });
        # awesome = inputs.nixpkgs-f2k.packages.${pkgs.system}.awesome-git;
      })
    ];
    config = {
      permittedInsecurePackages = [ ];
      allowUnfree = true;
      allowUnfreePredicate = (_: true);
      joypixels.acceptLicense = true;
    };
  };
  nix = {
    registry = lib.mapAttrs (_: value: { flake = value; }) inputs;
    package = pkgs.unstable.nix;
    settings =
      if isDarwin then {
        nixPath = [ "nixpkgs=/run/current-system/sw/nixpkgs" ];
        daemonIOLowPriority = true;
      }
      else {
        # accept-flake-config = true;
        auto-optimise-store = true;
        experimental-features = [
          "nix-command"
          "flakes"
          "auto-allocate-uids"
          "cgroups"
        ];
        auto-allocate-uids = true;
        use-cgroups = if isLinux then true else false;
        # build-users-group = "nixbld";
        builders-use-substitutes = true;
        sandbox = if (isDarwin) then true else "relaxed";
        # Avoid unwanted garbage collection when using nix-direnv
        # https://nixos.org/manual/nix/unstable/command-ref/conf-file.html
        # keep-going = true;
        show-trace = true;
        keep-outputs = true;
        keep-derivations = true;
        warn-dirty = false;
        allow-dirty = true;
        # allowed-users = [ "nixbld" "@wheel" ]; # Allow to run nix
        # allowed-users = [ "root" "@wheel" ];
        # trusted-users = [ "root" "@wheel" ];
        connect-timeout = 5;
        http-connections = 0;
      };
    extraOptions =
      ''log-lines = 15
        fallback = true
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
  systemd.user = {
    # Nicely reload system units when changing configs
    startServices = lib.mkIf isLinux "sd-switch";
    services.nix-index-database-sync = {
      Unit.Description = "fetch mic92/nix-index-database";
      Service = {
        Type = "oneshot";
        ExecStart = lib.getExe (pkgs.writeShellApplication {
          name = "fetch-nix-index-database";
          runtimeInputs = with pkgs; [ wget coreutils ];
          text = ''
            mkdir -p ~/.cache/nix-index
            cd ~/.cache/nix-index
            name="index-${pkgs.stdenv.system}"
            wget -N "https://github.com/Mic92/nix-index-database/releases/latest/download/$name"
            ln -sf "$name" "files"
          '';
        });
        Restart = "on-failure";
        RestartSec = "5m";
      };
    };
    timers.nix-index-database-sync = {
      Unit.Description = "Automatic github:mic92/nix-index-database fetching";
      Timer = {
        OnBootSec = "10m";
        OnUnitActiveSec = "24h";
      };
      Install.WantedBy = [ "timers.target" ];
    };
  };
  xdg = {
    enable = isLinux;
    userDirs = {
      enable = isLinux && !isLima;
      createDirectories = lib.mkDefault true;
      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/screenshots";
      };
    };
  };
}
