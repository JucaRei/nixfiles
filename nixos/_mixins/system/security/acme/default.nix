{ lib, pkgs, config, virtual, namespace, ... }:
let
  inherit (lib) mkIf mkEnableOption optional mkOption;
  inherit (lib.types) str bool;

  cfg = config.system.security.acme;
in
{
  options.system.security.acme = with lib.types; {
    enable = mkEnableOption "default ACME configuration";
    email = mkOption {
      type = str;
      default = "";
      description = "The email to use.";
    };
    staging = mkOption {
      type = bool;
      default = false;
      description = "Whether to use the staging server or not.";
    };
  };

  config = mkIf cfg.enable {
    security.acme = {
      acceptTerms = true;

      defaults = {
        inherit (cfg) email;

        group = mkIf config.services.nginx.enable "nginx";
        server = mkIf cfg.staging "https://acme-staging-v02.api.letsencrypt.org/directory";

        # Reload nginx when certs change.
        reloadServices = optional config.services.nginx.enable "nginx.service";
      };
    };
  };
}
