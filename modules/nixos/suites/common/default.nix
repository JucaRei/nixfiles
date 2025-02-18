{ config
, lib
, pkgs
, namespace
, ...
}:
let
  inherit (lib) mkOptionDefault mkIf;
  inherit (lib.${namespace}) mkBoolOpt enabled;
  cfg = config.${namespace}.suites.common;
in
{
  options.${namespace}.suites.common = {
    enable = mkBoolOpt false "Whether or not to enable common configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.excalibur.list-iommu ];

    excalibur = {
      nix = enabled;

      # TODO: Enable this once Attic is configured again.
      # cache.public = enabled;

      programs = {
        graphical = { };


        terminal = {
          apps = {
            flake = enabled;
            # thaw = enabled;
            comma = enabled;
          };


          tools = {
            git = enabled;
            misc = enabled;
            nix-ld = enabled;
            bottom = enabled;
          };
        };
      };


      hardware = {
        audio = enabled;
        storage = enabled;
        networking = enabled;
      };

      services = {
        printing = enabled;
        openssh = enabled;
        tailscale = enabled;
      };

      security = {
        gpg = enabled;
        doas = enabled;
        keyring = enabled;
      };

      system = {
        boot = {
          enable = true;
          boottype = mkOptionDefault "efi";
          bootmanager = mkOptionDefault "grub";
          isDualBoot = mkOptionDefault false;
          secureBoot = mkOptionDefault false;
          silentBoot = mkOptionDefault true;
          plymouth = mkOptionDefault true;
        };
        fonts = enabled;
        locale = enabled;
        time = enabled;
        xkb = enabled;
      };
    };
  };
}
