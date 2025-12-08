{ options, config, lib, username, ... }:
let
  inherit (lib) mkIf mkOption mdDoc;
  inherit (lib.types) enum nullOr bool submodule;
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
        default = null;
        description = mdDoc "The super user manager to use.";
      };
    };
    system.security.sudo = mkOption {
      type = submodule { };
      default = { };
      description = "Sudo configuration";
    };
  };
  config = mkIf config.system.security.superuser.enable {
    security = {
      # User namespaces are required for sandboxing. Better than nothing imo.
      allowUserNamespaces = true;
    };

    users.users.${username}.extraGroups = [
      "systemd-journal"
      # "proc" # Enable full /proc access and systemd-status
    ];
  };
}
