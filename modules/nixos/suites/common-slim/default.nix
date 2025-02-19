{ config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.common-slim;
in
{
  options.${namespace}.suites.common-slim = with types; {
    enable = mkBoolOpt false "Whether or not to enable common-slim configuration.";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.${namespace}.list-iommu ];

    ${namespace} = {
      nix = enabled;

      # TODO: Enable this once Attic is configured again.
      # cache.public = enabled;

      programs = {

        terminal = {
          apps = {
            flake = enabled;
          };

          tools = {
            git = enabled;
            comma = enabled;
            # bottom = enabled;
            # direnv = enabled;
          };
        };
      };

      hardware = {
        storage = enabled;
        networking = {
          enable = true;
          manager = "network-manager";
        };
      };

      security = {
        superuser = {
          enable = true;
          manager = mkDefault "doas";
        };
      };

      system = {
        boot = {
          enable = true;
          boottype = "efi";
          bootmanager = "grub";
        };
        fonts = enabled;
        locale = enabled;
        time = enabled;
        services = {
          ssh = enabled;
        };
      };
    };
  };
}
