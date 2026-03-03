{
  description = "NixOS, nix-darwin and Home Manager Configuration";
  inputs = {
    ### Determine Helper
    determinate.url = "https://flakehub.com/f/DeterminateSystems/determinate/*";
    fh.url = "https://flakehub.com/f/DeterminateSystems/fh/*";

    ### NIXOS
    nixpkgs.url = "https://flakehub.com/f/nixos/nixpkgs/0.2511.*";
    nixpkgs-unstable.url = "https://flakehub.com/f/DeterminateSystems/nixpkgs-weekly/0";
    nixpkgs-oldstable.url = "https://flakehub.com/f/nixos/nixpkgs/0.2405.*";

    ### Home-Manager
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
    home-manager_unstable.url = "github:nix-community/home-manager/master";
    home-manager_unstable.inputs.nixpkgs.follows = "nixpkgs-unstable";

    ### Nix for darwin
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    ### Chaotic repo
    chaotic.url = "github:chaotic-cx/nyx/nyxpkgs-unstable";

    ### Other Custom Modules
    catppuccin.url = "github:catppuccin/nix";
    nixos-hardware.url = "https://flakehub.com/f/NixOS/nixos-hardware/*";
    nix-flatpak.url = "https://flakehub.com/f/gmodena/nix-flatpak/*.tar.gz";
    nur.url = "github:nix-community/NUR";
    nixos-needsreboot.url = "https://flakehub.com/f/wimpysworld/nixos-needsreboot/*.tar.gz";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    nixgl.url = "github:nix-community/nixGL";
    nixgl.inputs.nixpkgs.follows = "nixpkgs";
    auto-cpufreq.url = "github:AdnanHodzic/auto-cpufreq";
    auto-cpufreq.inputs.nixpkgs.follows = "nixpkgs-unstable";
    lanzaboote.url = "github:nix-community/lanzaboote";
    lanzaboote.inputs.nixpkgs.follows = "nixpkgs";
    vscode-server.url = "github:nix-community/nixos-vscode-server";
    vscode-server.inputs.nixpkgs.follows = "nixpkgs-unstable";
    nix4vscode.url = "github:nix-community/nix4vscode";
    nix4vscode.inputs.nixpkgs.follows = "nixpkgs-unstable";
    sf-mono-liga-src.url = "github:shaunsingh/SFMono-Nerd-Font-Ligaturized"; # SFMono w/ patches
    sf-mono-liga-src.flake = false;
    sops-nix.url = "github:Mic92/sops-nix";
    sops-nix.inputs.nixpkgs.follows = "nixpkgs";
    system-manager.url = "github:numtide/system-manager";
    system-manager.inputs.nixpkgs.follows = "nixpkgs";
  };
  outputs = { self, nix-darwin, nixpkgs, ... }@inputs:
    with inputs;
    let
      inherit (self) outputs;
      # https://nixos.wiki/wiki/FAQ/When_do_I_update_stateVersion
      # stateVersion = "24.11";
      helper = import ./lib { inherit inputs outputs; };
    in
    {
      homeConfigurations = {
        # nix-shell -p home-manager.out --run 'home-manager switch -b backup --flake . --show-trace'
        # .iso images
        # "nixos@iso-console" = helper.mkHome { hostname = "iso-console"; username = "nixos"; };
        # "nixos@iso-gnome" = helper.mkHome { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        # "nixos@iso-mate" = helper.mkHome { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        # "nixos@iso-pantheon" = helper.mkHome { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };
        # Workstations
        # "juca@nitro" = helper.mkHome { hostname = "nitro"; desktop = "xfce4"; };
        # "juca@rocinante" = helper.mkHome { hostname = "rocinante"; desktop = "xfce4"; };
        # "juca@anubis" = helper.mkHome { hostname = "anubis"; desktop = "xfce4"; useNixGL = true; stateVersion = "24.05"; };
        # Only terminal apps
        # Servers
        # VMs
        # "juca@virtual" = helper.mkHome { hostname = "virtual"; desktop = "xfce4"; };
        "juca@fedora" = helper.mkHome { hostname = "fedora"; desktop = "xfce4"; useNixGL = true; stateVersion = "25.11"; };
        "juca@anubis" = helper.mkHome { hostname = "anubis"; desktop = "bspwm"; useNixGL = true; stateVersion = "25.11"; };
        "juca@virtualvm" = helper.mkHome {
          hostname = "virtualvm";
          # desktop = "xfce4";
          useNixGL = true;
          stateVersion = "24.05";
        };
      };

      nixosConfigurations = {
        ## Examples ##
        # nix run github:numtide/nixos-anywhere -- --build-on-remote --flake /home/juca/Documents/workspace/gitea/nixsystem#vm root@192.168.2.175
        # nix run github:numtide/nixos-anywhere -- --flake /home/juca/.dotfiles/nixfiles#air root@192.168.1.76
        # nix run github:numtide/nixos-anywhere -- --flake $FLAKE#air root@192.168.1.76
        # nix build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage
        # nom build .#nixosConfigurations.{iso-console|iso-desktop}.config.system.build.isoImage

        # .iso images
        # iso-console = helper.mkNixos { hostname = "iso-console"; username = "nixos"; };
        # iso-gnome = helper.mkNixos { hostname = "iso-gnome"; username = "nixos"; desktop = "gnome"; };
        # iso-mate = helper.mkNixos { hostname = "iso-mate"; username = "nixos"; desktop = "mate"; };
        # iso-pantheon = helper.mkNixos { hostname = "iso-pantheon"; username = "nixos"; desktop = "pantheon"; };

        # Workstations
        #  - sudo nixos-rebuild boot --flake $HOME/.dotfiles/nixfiles
        #  - sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles
        #  - nix build .#nixosConfigurations.{hostname}.config.system.build.toplevel
        # nixtro = helper.mkNixos { hostname = "rocinante"; desktop = "hyprland"; };
        # rocinante = helper.mkNixos { hostname = "rocinante"; desktop = "xfce4"; };
        # zion = helper.mkNixos { hostname = "zion"; desktop = "xfce4"; };
        # Servers
        # soyoz = helper.mkNixos { hostname = "soyoz"; };
        # VMs
        # virtual = helper.mkNixos { hostname = "virtual"; desktop = "xfce4"; stateVersion = "24.05"; };
        # virtualvm = helper.mkNixos { hostname = "virtualvm"; desktop = "xfce4"; };
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

      devShells = helper.forAllSystems (system:
        let
          # pkgs = nixpkgs.legacyPackages.${system}
          pkgs = import nixpkgs {
            inherit system;
            config = { allowUnfree = true; };
          };
        in
        import ./shell.nix {
          inherit pkgs;
        })
        # {
        #   default = (import ./devShells/default.nix { inherit pkgs; }).default;
        #   teste = (import ./devShells/teste.nix { inherit pkgs; }).teste;
        # })
      ;

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
          # Return the set of custom packages
        in
        customPkgs
      );

      # Formatter for .nix files, available via 'nix fmt' #nixfmt-rfc-style
      formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixpkgs-fmt);
      # formatter = helper.forAllSystems (system: nixpkgs.legacyPackages.${system}.nixfmt-rfc-style);
    };
}
