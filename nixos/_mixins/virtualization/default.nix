{
  desktop,
  lib,
  hostname,
  ...
}: {
  imports = [
    ./podman.nix
    # ./distrobox.nix
    # ./docker.nix
  ];
  # ++ lib.optional
  #   (builtins.isString desktop && builtins.isString hostname != "vm")
  #   ./lxd.nix
  # ++ lib.optional
  #   (builtins.isString desktop && builtins.isString hostname != "vm")
  #   ./quickemu.nix
  # ++ lib.optional
  #   (builtins.isString desktop && builtins.isString hostname != "vm")
  #   ./virt-manager.nix;
}
