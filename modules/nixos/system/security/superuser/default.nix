{ options, config, lib, namespace, ... }:
with lib.${namespace};
{
  imports = [
    ./doas
    ./sudo
  ];

  options.${namespace}.system.security.superuser = {
    enable = mkBoolOpt false "Whether or not enable super user manager.";
    manager = mkOption str enum [ "sudo" "doas" ] "sudo" "The super user manager to use.";
  };
  config = mkIf config.${namespace}.system.security.superuser.enable {
    security = {
      # User namespaces are required for sandboxing. Better than nothing imo.
      allowUserNamespaces = true;

      # Disable unprivileged user namespaces, unless containers are enabled
      unprivilegedUsernsClone = config.features.container-manager.enable;
    };

    systemd.tmpfiles.rules = [
      "L+ /usr/local/bin - - - - /run/current-system/sw/bin/" # symlink executable's to normal linux path
    ];

    ${namespace}.user.extraGroups = [ "wheel" "systemd-journal" ];
  };
}
