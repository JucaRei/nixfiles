{ lib
, pkgs
, modulesPath
, namespace
, ...
}:
with lib;
with lib.${namespace};
{
  imports = [ (modulesPath + "/virtualisation/digital-ocean-config.nix") ];

  virtualisation.digitalOcean = {
    rebuildFromUserData = false;
  };

  boot.loader.grub = enabled;

  networking.firewall.allowedTCPPorts = [
    80
    443
  ];

  environment.systemPackages = with pkgs; [ neovim ];

  excalibur = {
    nix = enabled;

    cli-apps = {
      tmux = enabled;
      # neovim = enabled;
    };

    tools = {
      git = enabled;
    };

    security = {
      doas = enabled;
      acme = enabled;
    };

    services = {
      openssh = enabled;
      tailscale = enabled;

      websites = {
        scrumfish = enabled;
        retrospectacle = enabled;
        lasersandfeelings = enabled;
      };
    };

    system = {
      fonts = enabled;
      locale = enabled;
      time = enabled;
      xkb = enabled;
    };
  };

  system.stateVersion = "22.11";
}
