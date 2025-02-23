{ options, config, lib, ... }:
let
  inherit (lib) mkIf mkOption mdDoc;
  inherit (lib.types) enum nullOr bool;
in
{
  imports = [
    ./doas
    ./sudo
  ];

  options = {
    system.security.superuser = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Whether or not enable superuser manager.";
      };
      manager = mkOption {
        type = nullOr (enum [ "sudo" "doas" ]);
        default = "sudo";
        description = mdDoc "The super user manager to use.";
      };
    };
  };
  config = mkIf config.system.security.superuser.enable {
    security = {
      # User namespaces are required for sandboxing. Better than nothing imo.
      allowUserNamespaces = true;

      # Disable unprivileged user namespaces, unless containers are enabled
      unprivilegedUsernsClone = config.features.container-manager.enable;
    };

    users.extraGroups = [ "wheel" "systemd-journal" ];
  };
}
