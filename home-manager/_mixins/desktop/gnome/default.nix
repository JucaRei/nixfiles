{ config, lib, hostname, pkgs, ... }:
with lib.hm.gvariant;
let
  # Assuming extensionUuid is unique to Gnome extensions
  # extensions = builtins.filter (p: p ? "extensionUuid") config.home.packages;
  extensions = with pkgs; with gnomeExtensions; [
    user-themes
    night-theme-switcher
  ];
in
{

  imports = [
    ./theme.nix
    ./settings.nix
  ];

  services = {
    gpg-agent.pinentryFlavor = lib.mkForce "gnome3";
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    mpris-proxy.enable = true;
  };

  dconf.settings = {
    "ca/desrt/dconf-editor" = {
      show-warning = false;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      left-handed = false;
      natural-scroll = false;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = true;
      tap-to-click = true;
      two-finger-scrolling-enabled = true;
    };
  };
}
