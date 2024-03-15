{ config, lib, hostname, pkgs, ... }:
with lib.hm.gvariant;
let
  # Assuming extensionUuid is unique to Gnome extensions
  extensions = builtins.filter (p: p ? "extensionUuid") config.home.packages;
in
{

  imports = [
    ./theme.nix
    ./settings.nix
  ];

  home = {
    packages = with pkgs; [

    ];
  };

  services = {
    gpg-agent.pinentryFlavor = lib.mkForce "gnome3";
    # https://nixos.wiki/wiki/Bluetooth#Using_Bluetooth_headsets_with_PulseAudio
    mpris-proxy.enable = true;
  };
}
