{ pkgs
, lib
, namespace
, ...
}:
let
  tailscale-key = builtins.getEnv "TAILSCALE_AUTH_KEY";
in
with lib;
with lib.${namespace};
{
  # `install-iso` adds wireless support that
  # is incompatible with networkmanager.
  networking.wireless.enable = mkForce false;

  excalibur = {
    nix = enabled;

    apps = {
      _1password = enabled;
      firefox = enabled;
      vscode = enabled;
      gparted = enabled;
    };

    cli-apps = {
      neovim = enabled;
      tmux = enabled;
    };

    desktop = {
      gnome = {
        enable = true;
      };

      addons = {
        # I like to have a convenient place to share wallpapers from
        # even if they're not currently being used.
        wallpapers = enabled;
      };
    };

    tools = {
      k8s = enabled;
      git = enabled;
      node = enabled;
      http = enabled;
      misc = enabled;
      titan = enabled;
    };

    hardware = {
      audio = enabled;
      networking = enabled;
    };

    services = {
      openssh = enabled;
      printing = enabled;

      tailscale = {
        enable = true;
        autoconnect = {
          enable = tailscale-key != "";
          key = tailscale-key;
        };
      };
    };

    security = {
      doas = enabled;
      keyring = enabled;
    };

    system = {
      boot = enabled;
      fonts = enabled;
      locale = enabled;
      time = enabled;
      xkb = enabled;
    };
  };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "22.11"; # Did you read the comment?
}
