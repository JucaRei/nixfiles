{ inputs, pkgs, ... }: {
  # https://nixos.wiki/wiki/Steam
  fonts.fontconfig.cache32Bit = true;
  hardware = {
    steam-hardware.enable = true;
    opengl = {
      driSupport32Bit = true;
      extraPackages = with pkgs; [ vulkan-validation-layers ];
    };
  };
  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    };
  };
  services = {
    jack.alsa.support32Bit = true;
    pipewire.alsa.support32Bit = true;

    ## Nintendo Pro Controller / Joycon support
    # joycond.enable = true;
  };

  # improve wine performance
  environment.sessionVariables = { WINEDEBUG = "-all"; };


  # Adds Proton GE to Steam
  # Does not work in main overlay
  # Results in infinite recursion due to referencing pkgs
  nixpkgs.overlays = [
    (_: prev: {
      steam = prev.steam.override {
        extraProfile = "export STEAM_EXTRA_COMPAT_TOOLS_PATHS='${inputs.nix-gaming.packages.${pkgs.system}.proton-ge}'";
      };
    })
  ];

  # nix-gaming cache
  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [ "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4=" ];
  };

  # https://github.com/NixOS/nixpkgs/issues/45492
  # Set limits for esync.
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  security.pam.loginLimits = [
    {
      domain = "*";
      type = "hard";
      item = "nofile";
      value = "1048576";
    }
  ];
}
