{
  config,
  lib,
  pkgs,
  username ? "juca",
  ...
}:
let
  inherit (lib)
    mkOption
    mkDefault
    mkIf
    ;
  inherit (lib.types) enum nullOr;
  cfg = config.desktop.display-managers;
  dmEnabled =
    cfg.name != null
    || cfg.lightdm.enable
    || cfg.sddm.enable
    || cfg.regreet.enable
    || cfg.gdm.enable;
in

{
  imports = [
    ./lightdm
    ./sddm
    ./regreet
    ./gdm
  ];

  options = {
    desktop.display-managers.name = mkOption {
      type = nullOr (enum [
        "lightdm"
        "sddm"
        "regreet"
        "gdm"
      ]);
      default = null;
      description = "The selected display-manager for your desktop environment.";
    };
  };

  config = {
    desktop.display-managers.lightdm.enable = mkDefault (cfg.name == "lightdm");
    desktop.display-managers.sddm.enable = mkDefault (cfg.name == "sddm");
    desktop.display-managers.regreet.enable = mkDefault (cfg.name == "regreet");
    desktop.display-managers.gdm.enable = mkDefault (cfg.name == "gdm");

    # Provedor universal de avatar do usuário para qualquer display manager (GDM, SDDM, LightDM, ReGreet)
    services.accounts-daemon.enable = mkDefault dmEnabled;

    environment.systemPackages = mkIf dmEnabled [
      pkgs.juca-avatar
    ];

    systemd.tmpfiles.rules = mkIf dmEnabled [
      "d /var/lib/AccountsService 0755 root root -"
      "d /var/lib/AccountsService/icons 0755 root root -"
      "d /var/lib/AccountsService/users 0755 root root -"
      "L+ /var/lib/AccountsService/icons/${username} 0644 root root - ${pkgs.juca-avatar}/share/faces/juca.jpg"
      "f /var/lib/AccountsService/users/${username} 0600 root root - [User]\nIcon=/var/lib/AccountsService/icons/${username}\nSystemAccount=false\n"
    ];
  };
}
