{ inputs, lib, config, pkgs, modulesPath, hostname, username, stateVersion, isISO, ... }:
let
  inherit (lib) optional mkDefault mkIf;
in
{
  # You can import other NixOS modules here
  imports = [
    ./users
    ../modules/nixos
  ] ++
  optional (builtins.pathExists ./hosts/${hostname}) ./hosts/${hostname};

  networking = {
    hostName = "${hostname}";
  };

  services.openssh = {
    enable = true;
    settings = {
      # Opinionated: forbid root login through SSH.
      PermitRootLogin = mkIf (isISO) "yes";
      # Opinionated: use keys only.
      # Remove if you want to SSH using passwords
      PasswordAuthentication = true;
    };
  };

  i18n = {
    defaultLocale = mkDefault "en_US.UTF-8";
    extraLocaleSettings = {
      LANG = "en_US.UTF-8";
      LC_CTYPE = "pt_BR.UTF-8"; # Fix ç in us-intl.
      LC_ADDRESS = "pt_BR.UTF-8";
      LC_IDENTIFICATION = "en_US.UTF-8";
      LC_MEASUREMENT = "pt_BR.UTF-8";
      LC_MONETARY = "pt_BR.UTF-8";
      LC_NAME = "pt_BR.UTF-8";
      LC_NUMERIC = "pt_BR.UTF-8";
      LC_PAPER = "pt_BR.UTF-8";
      LC_TELEPHONE = "pt_BR.UTF-8";
      LC_TIME = "pt_BR.UTF-8";
    };
  };
}
