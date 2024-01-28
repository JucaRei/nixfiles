{ pkgs, lib, ... }:
with lib.hm.gvariant; {
  home = {
    packages = with pkgs; [ gnome3.gvfs gnome3.nautilus ];

    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features

    sessionVariables = { GIO_EXTRA_MODULES = "${pkgs.gvfs}/lib/gio/modules"; };
  };
}
