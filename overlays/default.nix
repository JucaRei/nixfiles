# This file defines overlays
{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };


  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    cyberre = final.cyberre-grub-theme;
    advcp = final.advmvcp;
    hacked-cursor = final.breeze-hacked-cursorr;
    clonegit = final.cloneit;
    deezer-gui = final.deezer;
    icloudpd = final.icloud-photo-downloader;
    nvchad = prev.nvchad;
    thorium = final.thorium-browser;
    pulseaudio-control = final.polybar-pulseaudio-control;
    fantezy = final.fantezy-font;
    flat-remix = final.flat-remix-shell;
    # apple-font = final.apple-fonts;
    # tidal = final.tidal-dl;
    # mpvconf = prev.mpv;
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
