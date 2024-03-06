{
  pkgs,
  lib,
  ...
}:
with lib.hm.gvariant; {
  home = {
    packages = with pkgs;
      [nautilus-open-any-terminal]
      ++ (with pkgs.gnome; [nautilus gvfs sushi]);

    # Installing Nautilus directly from Nixpkgs in Non-NixOS systems have no support for mounting sftps and other features

    sessionVariables = {
      GIO_EXTRA_MODULES = "${pkgs.gnome.gvfs}/lib/gio/modules";
    };
  };
}
