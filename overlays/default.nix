# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  localPackages = final: _prev: import ../pkgs final.pkgs;

  # https://nixos.wiki/wiki/Overlays
  modifiedPackages = _final: prev: {
    sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation rec {
      pname = "sf-mono-liga-bin";
      version = "dev";
      src = inputs.sf-mono-liga-src;
      dontConfigure = true;
      installPhase = ''
        mkdir -p $out/share/fonts/opentype
        cp -R $src/*.otf $out/share/fonts/opentype/
      '';
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [
        # Apply the same rofi-unwrapped modification to unstable packages
        (_final: _prev: {
          # rofi-unwrapped = _prev.rofi-unwrapped.overrideAttrs (oldAttrs: {
          #   postInstall = (oldAttrs.postInstall or "") + ''
          #     rm -f $out/share/applications/rofi.desktop
          #     rm -f $out/share/applications/rofi-theme-selector.desktop
          #   '';
          # });
        })
      ];
    };
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.oldstable'
  oldstable-packages = final: _prev: {
    oldstable = import inputs.nixpkgs-oldstable {
      inherit (final) system;
      config.allowUnfree = true;
      overlays = [
        # Apply the same rofi-unwrapped modification to unstable packages
        (_final: _prev: { })
      ];
    };
  };


}
