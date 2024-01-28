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
      remotePlay.openFirewall =
        true; # Open ports in the firewall for Steam Remote Play
      dedicatedServer.openFirewall =
        true; # Open ports in the firewall for Source Dedicated Server
    };
    # On-demand system optimization for gaming
    # gamemode.enable = true;
  };
  services = {
    jack.alsa.support32Bit = true;
    pipewire.alsa.support32Bit = true;

    ## Nintendo Pro Controller / Joycon support
    # joycond.enable = true;

    # udev = {
    #   ## correct controller support for steam
    #   extraRules = ''
    #     # This rule is needed for basic functionality of the controller in Steam and keyboard/mouse emulation
    #     SUBSYSTEM=="usb", ATTRS{idVendor}=="28de", MODE="0666"
    #     # This rule is necessary for gamepad emulation
    #     KERNEL=="uinput", MODE="0660", GROUP="input", OPTIONS+="static_node=uinput"
    #     KERNEL=="js*", MODE="0660", GROUP="input"
    #     # Valve HID devices over USB hidraw
    #     KERNEL=="hidraw*", ATTRS{idVendor}=="28de", MODE="0666"
    #     # Valve HID devices over bluetooth hidraw
    #     KERNEL=="hidraw*", KERNELS=="*28DE:*", MODE="0666"
    #     # DualShock 4 over USB hidraw
    #     KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="05c4", MODE="0666"
    #     # DualShock 4 wireless adapter over USB hidraw
    #     KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0ba0", MODE="0666"
    #     # DualShock 4 Slim over USB hidraw
    #     KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="09cc", MODE="0666"
    #     # DualShock 4 over bluetooth hidraw
    #     KERNEL=="hidraw*", KERNELS=="*054C:05C4*", MODE="0666"
    #     # DualShock 4 Slim over bluetooth hidraw
    #     KERNEL=="hidraw*", KERNELS=="*054C:09CC*", MODE="0666"
    #     # DualShock 3 controller, Bluetooth
    #     KERNEL=="hidraw*", KERNELS=="*054C:0268*", MODE="0660", TAG+="uaccess"
    #     # DualShock 3 controller, USB
    #     KERNEL=="hidraw*", ATTRS{idVendor}=="054c", ATTRS{idProduct}=="0268", MODE="0660", TAG+="uaccess"
    #     # Nintendo Switch Pro Controller over USB hidraw
    #     KERNEL=="hidraw*", ATTRS{idVendor}=="057e", ATTRS{idProduct}=="2009", MODE="0666"
    #     # Nintendo Switch Pro Controller over bluetooth hidraw
    #     KERNEL=="hidraw*", KERNELS=="*057E:2009*", MODE="0666"
    #   '';
    # };
  };

  # improve wine performance
  environment.sessionVariables = { WINEDEBUG = "-all"; };

  # Adds Proton GE to Steam
  # Does not work in main overlay
  # Results in infinite recursion due to referencing pkgs
  nixpkgs.overlays = [
    (_: prev: {
      steam = prev.steam.override {
        extraProfile = "export STEAM_EXTRA_COMPAT_TOOLS_PATHS='${
            inputs.nix-gaming.packages.${pkgs.system}.proton-ge
          }'";
      };
    })
  ];

  ssbm = {
    overlay.enable = true;
    cache.enable = true;
  };

  # nix-gaming cache
  nix.settings = {
    substituters = [ "https://nix-gaming.cachix.org" ];
    trusted-public-keys = [
      "nix-gaming.cachix.org-1:nbjlureqMbRAxR1gJ/f3hxemL9svXaZF/Ees8vCUUs4="
    ];
  };

  # https://github.com/NixOS/nixpkgs/issues/45492
  # Set limits for esync.
  systemd.extraConfig = "DefaultLimitNOFILE=1048576";
  security.pam.loginLimits = [{
    domain = "*";
    type = "hard";
    item = "nofile";
    value = "1048576";
  }];
}
