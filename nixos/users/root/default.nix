{ lib, ... }: {
  users.users.root = {
    group = "root";
    # hashedPassword = null;
    initialHashedPassword = lib.mkDefault "$6$yePUgLk6bNadaTtq$14GbXvnjgCE3DRK7R4tgL6/RZVjJfv3FF1K3/ljzMDVx/0m5E7hxVm/7kWYcYp6OBJeWkT79hNVyKQqXRGL7g1"; # nixos changeMe when installed -
    openssh.authorizedKeys.keys = [ ];
  };
}
