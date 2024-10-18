{
  description = "NixOS, nix-darwin and Home Manager Configuration";
  inputs = {
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2405.*";
    nixpkgs-unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";

    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };

    # Chaotic Nyx!
    # chaotic-nyx = {
    #   url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
    #   inputs.home-manager.follows = "home-manager";
    # };

    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    auto-cpufreq.url = "github:AdnanHodzic/auto-cpufreq";
    auto-cpufreq.inputs.nixpkgs.follows = "nixpkgs-unstable";

    catppuccin.url = "github:catppuccin/nix";

    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-24.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-needtoreboot.url = "github:thefossguy/nixos-needsreboot";
    nixos-needtoreboot.inputs.nixpkgs.follows = "nixpkgs";

    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    nix-vscode-extensions.url = "github:nix-community/nix-vscode-extensions";
    nix-vscode-extensions.inputs.nixpkgs.follows = "nixpkgs";

    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs";

    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";

    # Optional but recommended to limit the size of your system closure.
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";

    # FlakeHub
    catppuccin-vsc.url = "https://flakehub.com/f/catppuccin/vscode/*.tar.gz";
    catppuccin-vsc.inputs.nixpkgs.follows = "nixpkgs";

    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/0";

    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/0";

    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";

    nix-snapd.url = "https://flakehub.com/f/io12/nix-snapd/*.tar.gz";
    nix-snapd.inputs.nixpkgs.follows = "nixpkgs";

    stream-sprout.url = "https://flakehub.com/f/wimpysworld/stream-sprout/*.tar.gz";
    stream-sprout.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    { self, nix-darwin, nixpkgs, ... }@inputs:
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      stateVersion = "24.05";
      helper = import ./lib { inherit inputs outputs stateVersion; };
    in
    {
      # home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles
      # nix run nixpkgs#home-manager -- switch -b backup --flake "${HOME}/.dotfiles/nixfiles"
      homeConfigurations = {
        # .iso images
        "nixos@iso-console" = helper.mkHome { hostname = "iso-console"; username = "nixos"; };
        "nixos@iso-gnome" = helper.mkHome { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        "nixos@iso-mate" = helper.mkHome { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        "nixos@iso-pantheon" = helper.mkHome { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        "juca@phasma" = helper.mkHome { hostname = "phasma"; desktop = "hyprland"; };
        "juca@vader" = helper.mkHome { hostname = "vader"; desktop = "hyprland"; };
        "juca@shaa" = helper.mkHome { hostname = "shaa"; desktop = "hyprland"; };
        "juca@tanis" = helper.mkHome { hostname = "tanis"; desktop = "hyprland"; };
        "juca@momin" = helper.mkHome { hostname = "momin"; platform = "aarch64-darwin"; desktop = "aqua"; };
        "juca@krall" = helper.mkHome { hostname = "krall"; platform = "x86_64-darwin"; desktop = "aqua"; };
        # palpatine/sidious are dual boot hosts, WSL2/Ubuntu and NixOS respectively.
        "juca@palpatine" = helper.mkHome { hostname = "palpatine"; };
        "juca@sidious" = helper.mkHome { hostname = "sidious"; desktop = "gnome"; };
        # Servers
        "juca@revan" = helper.mkHome { hostname = "revan"; };
        # Steam Deck
        "deck@steamdeck" = helper.mkHome { hostname = "steamdeck"; username = "deck"; };
        # VMs
        "juca@minimech" = helper.mkHome { hostname = "minimech"; };
        "juca@scrubber" = helper.mkHome { hostname = "scrubber"; desktop = "pantheon"; };
      };
      nixosConfigurations = {
        # .iso images
        #  - nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        iso-console = helper.mkNixos { hostname = "iso-console"; username = "nixos"; };
        iso-gnome = helper.mkNixos { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        iso-mate = helper.mkNixos { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        iso-pantheon = helper.mkNixos { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        #  - sudo nixos-rebuild boot --flake $HOME/.dotfiles/nixfiles
        #  - sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles
        #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
        phasma = helper.mkNixos { hostname = "phasma"; desktop = "hyprland"; };
        tanis = helper.mkNixos { hostname = "tanis"; desktop = "hyprland"; };
        sidious = helper.mkNixos { hostname = "sidious"; desktop = "gnome"; };
        rocinante = helper.mkNixos { hostname = "rocinante"; desktop = "xfce4"; };
        nitro = helper.mkNixos { hostname = "nitro"; desktop = "pantheon"; };
        # Servers
        revan = helper.mkNixos { hostname = "revan"; };
        # VMs
        minimech = helper.mkNixos { hostname = "minimech"; };
        scrubber = helper.mkNixos { hostname = "scrubber"; desktop = "mate"; };
      };
      #nix run nix-darwin -- switch --flake ~/Zero/nix-config
      #nix build .#darwinConfigurations.{hostname}.config.system.build.toplevel
      darwinConfigurations = {
        momin = helper.mkDarwin { hostname = "momin"; };
        krall = helper.mkDarwin { hostname = "krall"; platform = "x86_64-darwin"; };
      };

      # Devshell for bootstrapping; acessible via 'nix develop' or 'nix-shell' (legacy)
      devShells = helper.forAllSystems (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
        in
        import ./shell.nix {
          inherit pkgs;
          # node = pkgs.callPackage ./shells/node { };
        }
      );

      # Custom packages and modifications, exported as overlays
      overlays = import ./overlays { inherit inputs; };
      # Custom packages; acessible via 'nix build', 'nix shell', etc
      packages = helper.forAllSystems (system: import ./pkgs nixpkgs.legacyPackages.${system});
      # Formatter for .nix files, available via 'nix fmt' #nixfmt-rfc-style
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
    };
}
