{
  description = "NixOS, nix-darwin and Home Manager Configuration";

  inputs = {
    # Nixpkgs Stable
    # nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2411.*";
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2505.*";

    # Nixpkgs Unstable
    # nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";
    # Also see the 'unstable-packages' overlay at 'overlays/default.nix'.

    # Old nixpkgs
    nixpkgs-oldstable.url = "https://flakehub.com/f/nixos/nixpkgs/0.2405.*";

    # Home manager Stable
    # home-manager.url = "github:nix-community/home-manager/release-24.11";
    home-manager.url = "github:nix-community/home-manager/release-25.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    home-manager_unstable.url = "github:nix-community/home-manager/master";
    home-manager_unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-snapd.url = "https://flakehub.com/f/io12/nix-snapd/*.tar.gz";
    nix-snapd.inputs.nixpkgs.follows = "nixpkgs";

    catppuccin.url = "github:catppuccin/nix";
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    nixos-hardware.url = "https://flakehub.com/f/NixOS/nixos-hardware/*";
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";
    nur.url = "github:nix-community/NUR"; # Add "nur.nixosModules.nur" to the host modules
    nixos-needsreboot.url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/0.2.9.tar.gz";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";

    auto-cpufreq.url = "github:AdnanHodzic/auto-cpufreq";
    auto-cpufreq.inputs.nixpkgs.follows = "nixpkgs-unstable";

    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    # SFMono w/ patches
    sf-mono-liga-src.url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized";
    sf-mono-liga-src.flake = false;

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    system-manager.url = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";

  };

  outputs =
    { self, nix-darwin, nixpkgs, ... }@inputs:
      with inputs;
      let
        inherit (self) outputs;
        # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
        # stateVersion = "24.11";
        helper = import ./lib { inherit inputs outputs stateVersion; };
      in
      {
        # home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles
        # home-manager switch -b backup --flake $FLAKE
        # nix run nixpkgs#home-manager -- switch -b backup --flake "${HOME}/.dotfiles/nixfiles"
        # nom build -- switch -b backup --flake "${HOME}/.dotfiles/nixfiles"
        # nom build .#homeConfigurations.${username@hostname}.activationPackage --impure --show-trace -vL
        homeConfigurations = {
          # .iso images
          "nixos@iso-console" = helper.mkHome {
            hostname = "iso-console";
            username = "nixos";
          };
          "nixos@iso-gnome" = helper.mkHome {
            hostname = "iso-gnome";
            username = "nixos";
            desktop = "gnome";
          };
          "nixos@iso-mate" = helper.mkHome {
            hostname = "iso-mate";
            username = "nixos";
            desktop = "mate";
          };
          "nixos@iso-pantheon" = helper.mkHome {
            hostname = "iso-pantheon";
            username = "nixos";
            desktop = "pantheon";
          };
          # Workstations
          "juca@nitro" = helper.mkHome {
            hostname = "nitro";
            desktop = "xfce4";
          };
          "juca@nitrowin" = helper.mkHome { hostname = "nitro"; };
          "juca@rocinante" = helper.mkHome {
            hostname = "rocinante";
            desktop = "xfce4";
          };
          # Only terminal apps
          "juca@anubis" = helper.mkHome {
            hostname = "anubis";
            stateVersion = "24.05";
          };
          # Servers
          # VMs
          "juca@qemu" = helper.mkHome { hostname = "qemu"; };
          "juca@soyoz-vm" = helper.mkHome {
            hostname = "soyoz-vm";
            desktop = "xfce4";
          };
          "juca@minimech" = helper.mkHome { hostname = "minimech"; };
          "juca@scrubber" = helper.mkHome {
            hostname = "scrubber";
            desktop = "kde";
          };
          # Apple
        };

        nixosConfigurations = {
          ## Examples ##
          # nix run github:numtide/nixos-anywhere -- --build-on-remote --flake /home/juca/Documents/workspace/gitea/nixsystem#vm root@192.168.2.175
          # nix run github:numtide/nixos-anywhere -- --flake /home/juca/.dotfiles/nixfiles#air root@192.168.1.76
          # nix run github:numtide/nixos-anywhere -- --flake $FLAKE#air root@192.168.1.76
          # nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
          # nom build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage

          # .iso images
          iso-console = helper.mkNixos {
            hostname = "iso-console";
            username = "nixos";
          };
          iso-gnome = helper.mkNixos {
            hostname = "iso-gnome";
            username = "nixos";
            desktop = "gnome";
          };
          iso-mate = helper.mkNixos {
            hostname = "iso-mate";
            username = "nixos";
            desktop = "mate";
          };
          iso-pantheon = helper.mkNixos {
            hostname = "iso-pantheon";
            username = "nixos";
            desktop = "pantheon";
          };

          # Workstations
          #  - sudo nixos-rebuild boot --flake $HOME/.dotfiles/nixfiles
          #  - sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles
          #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
          rocinante = helper.mkNixos {
            hostname = "rocinante";
            desktop = "xfce4";
          };
          zion = helper.mkNixos {
            hostname = "zion";
            desktop = "xfce4";
          };
          nixtro = helper.mkNixos {
            hostname = "nixtro";
            # desktop = "hyprland";
            desktop = "xfce4";
          };

          # Servers
          soyoz = helper.mkNixos { hostname = "soyoz"; };
          revan = helper.mkNixos { hostname = "revan"; };

          # VMs
          virtua = helper.mkNixos {
            hostname = "virtua";
            desktop = "xfce4";
            stateVersion = "24.05";
          };
        };

        #nix run nix-darwin -- switch --flake ~/Zero/nix-config
        #nix build .#darwinConfigurations.{hostname}.config.system.build.toplevel
        # darwinConfigurations = {
        # };

        #  System-Manager configurations
        # nix run .#systemCOnfigs.{$hostname}.config.system.build.toplevel
        # nom build .#systemCOnfigs.{$hostname}.config.system.build.toplevel
        # systemConfigs = {
        #   minimech = helper.mkSystemManager { };
        # };

        devShells =
          let
            supportedSystems = [
              "x86_64-linux"
              "aarch64-linux"
              "x86_64-darwin"
            ];
            forEachSupportedSystem =
              f:
              nixpkgs.lib.genAttrs supportedSystems (
                system:
                f {
                  pkgs = import nixpkgs {
                    inherit system;
                    config.allowUnfree = true;
                  };
                }
              );
          in
          forEachSupportedSystem (
            { pkgs }:
            {
              default = pkgs.mkShell {
                packages =
                  with pkgs;
                  [
                    git
                    home-manager
                    just
                    micro
                    nh
                    nixpkgs-fmt
                    # nixd # lsp server
                    nil # lsp server
                    nix-output-monitor
                    nix-direnv # A shell extension that manages your environment for nix
                    duf # check space
                    cachix
                    dropbear # ss

                    figlet
                    lolcat
                  ]
                  ++ lib.optionals pkgs.stdenv.isLinux [
                    inputs.nixos-needsreboot.packages.${system}.default
                  ];
                shellHook = ''
                  # exec fish
                  alias ssh="dbclient"
                  echo "🔨 Welcome to flakes" | figlet -W | lolcat -F 0.3 -p 2.5 -S 300
                  echo ">>>> ❄️ Entering Nix Development Environment"
                '';
              };
            }
          );

        # Custom packages and modifications, exported as overlays
        overlays = import ./overlays { inherit inputs; };

        # Custom packages; acessible via 'nix build', 'nix shell', etc
        packages = helper.forAllSystems (system:
          let
            # Import nixpkgs for the target system, applying overlays directly
            pkgsWithOverlays = import nixpkgs {
              inherit system;
              config = { allowUnfree = true; }; # Ensure consistent config
              # Pass the list of overlay functions directly
              overlays = builtins.attrValues self.overlays;
            };
            # Import the function from pkgs/default.nix
            pkgsFunction = import ./pkgs;
            # Call the function with the fully overlaid package set
            customPkgs = pkgsFunction pkgsWithOverlays;
          in
          # Return the set of custom packages
          customPkgs
        );
        # nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
        # nom-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'

        # Formatter for .nix files, available via 'nix fmt' #nixfmt-rfc-style
        # formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
        formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
      };
}
