{ options, config, lib, desktop, pkgs, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.hardware.fingerprint;
in
{
  options.hardware.fingerprint = {
    enable = mkOption {
      type = bool;
      default = false;
      description = mdDoc "Whether or not to enable fingerprint support.";
    };
  };

  config = mkIf cfg.enable {
    services.fprintd.enable = true;


    # Allow login/authentication with fingerprint or password
    # - https://github.com/NixOS/nixpkgs/issues/171136
    # - https://discourse.nixos.org/t/fingerprint-auth-gnome-gdm-wont-allow-typing-password/35295
    security.pam.services = mkIf (desktop == "gnome") {
      login.fprintAuth = false;
      gdm-fingerprint = mkIf config.services.fprintd.enable {
        text = ''
          auth       required                    pam_shells.so
          auth       requisite                   pam_nologin.so
          auth       requisite                   pam_faillock.so      preauth
          auth       required                    ${pkgs.fprintd}/lib/security/pam_fprintd.so
          auth       optional                    pam_permit.so
          auth       required                    pam_env.so
          auth       [success=ok default=1]      ${pkgs.gnome.gdm}/lib/security/pam_gdm.so
          auth       optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so

          account    include                     login

          password   required                    pam_deny.so

          session    include                     login
          session    optional                    ${pkgs.gnome-keyring}/lib/security/pam_gnome_keyring.so auto_start
        '';
      };
    };
  };
}
