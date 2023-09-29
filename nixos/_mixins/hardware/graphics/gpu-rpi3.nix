{ config, pkgs, ... }:

{
  hardware.opengl = {
    enable = true;
    setLdLibraryPath = true;
    package = pkgs.mesa_drivers;
  };
  hardware.raspberry-pi."3".fkms-3d.enable = true;
}
