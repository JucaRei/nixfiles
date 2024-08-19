{ lib, isWorkstation, inputs, pkgs, isLima, username, config, stateVersion, ... }:
let
  inherit (pkgs) stdenv;

in
{
  imports = [
    ../../../home
    ./cli/alias_core
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Modules exported from other flakes:
    inputs.catppuccin.homeManagerModules.catppuccin
    # inputs.determinate.homeModules.default
    inputs.sops-nix.homeManagerModules.sops
    inputs.nix-index-database.hmModules.nix-index
  ] ++ lib.optional isWorkstation ./desktop;

  config = {
    catppuccin = {
      accent = "blue";
      flavor = "mocha";
    };

    home = {
      inherit stateVersion username;
      homeDirectory =
        if isLima then "/home/${username}.linux"
        else "/home/${username}";

      packages = with pkgs; [
        duf # Modern Unix `df`
        fd # Modern Unix `find`
        speedtest-go # Terminal speedtest.net
        tldr # Modern Unix `man`
        iw # Terminal WiFi info
        pciutils # Terminal PCI info
        usbutils # Terminal USB info
      ];
    };

    fonts.fontconfig.enable = true;

    nix.settings.experimental-features = [
      "auto-allocate-uids"
      "cgroups"
    ];

    systemd.user = {
      # Nicely reload system units when changing configs
      startServices = "sd-switch";

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
      enable = true;
      userDirs = {
        # Do not create XDG directories for LIMA; it is confusing
        enable = !isLima;
        createDirectories = lib.mkDefault true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/Screenshots";
        };
      };
    };

    programs = {
      home-manager = {
        enable = true;
        # path = lib.mkForce "$HOME/.config/home-manager";
      };
    };
  };
}
