{ lib, pkgs, ... }: {
  services.dbus = {
    enable = true;
    implementation = lib.mkForce "broker";
    packages = with pkgs; [
      dconf
      grc
      udisks2
    ];
  };
}
