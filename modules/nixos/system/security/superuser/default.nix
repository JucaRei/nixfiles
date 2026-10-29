{
  config,
  lib,
  username,
  ...
}:
let
  inherit (lib) mkIf;
in
{
  imports = [
    ./doas
    ./sudo
  ];

  options = {
    system.security.superuser = {
      enable = lib.my.mkBool false "Whether or not enable superuser manager.";
      manager = lib.my.mkEnum [
        "sudo"
        "doas"
      ] "sudo" "The super user manager to use.";
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
