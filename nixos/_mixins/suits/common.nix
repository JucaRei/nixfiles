{ config, lib, isInstall, isWorkstation, ... }:
let
  inherit (lib) mkDefault mkOptionDefault mkOverride;
in
{
  config = {
    system = {
      boot = {
        enable = mkDefault isInstall;
        boottype = mkDefault "efi";
        bootmanager = mkDefault "grub";
        isDualBoot = mkOptionDefault false;
        secureBoot = mkOptionDefault false;
        silentBoot = mkOptionDefault isWorkstation;
        plymouth = mkOptionDefault isWorkstation;
      };

      # console.enable = true;
      locales.enable = true;

      security = {
        superuser = {
          enable = mkDefault true;
          manager = mkDefault "sudo";
        };
      };

      docs = {
        enable = mkDefault true;
        doctypes = [ "man" ];
      };

      ssh = {
        enable = true;
      };

      hardware = {
        cpu = {
          enable = mkOverride 990 true;
          hardenKernel = mkOptionDefault false;
          improveTCP = mkDefault (isInstall || isWorkstation);
          enableKvm = mkOptionDefault false;
          cpuVendor = mkDefault "intel";
        };

        network = {
          enable = true;
          networkOpt = mkDefault "network-manager";
          exclusive-locallan = mkDefault false;
          powersave = mkDefault false;
          wakeonlan = mkDefault false;
          # custom-interface = "eth0";
        };
      };
    };
  };
}
