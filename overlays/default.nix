{ inputs, ... }:
{
  # Brings custom local packages from the 'pkgs' directory
  localPackages = final: _prev: import ../pkgs final.pkgs;

  # Modifications to standard packages
  modifiedPackages = _final: prev: {
    makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });

    # Fix for nvidia_x11_legacy340 on modern nixpkgs KBuild (Issue #554929 / PR #555840)
    # Permite compilação dos módulos de kernel quando $src aponta para o store read-only do Nix.
    linuxKernel = prev.linuxKernel // {
      packagesFor =
        kernel:
        (prev.linuxKernel.packagesFor kernel).extend (
          _lFinal: lPrev: {
            nvidia_x11_legacy340 = lPrev.nvidia_x11_legacy340.overrideAttrs (old: {
              patches = (old.patches or [ ]) ++ [
                ./patches/legacy340-for-nix-kernel-modules.patch
              ];
              postFixup = (old.postFixup or "") + ''
                if [ -d "$bin/lib/xorg/modules/extensions" ]; then
                  ln -sf libglx.so.340.108 "$bin/lib/xorg/modules/extensions/libglx.so"
                fi
              '';
            });
          }
        );
    };

    sf-mono-liga-bin = prev.stdenvNoCC.mkDerivation {
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

  # Access unstable packages via 'pkgs.unstable.<package>'
  unstablePackages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final.stdenv.hostPlatform) system;
      config = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = true;
        nvidia.acceptLicense = true;
        permittedInsecurePackages = final.config.permittedInsecurePackages or [ ];
      };
    };
  };

  # Access oldstable packages via 'pkgs.oldstable.<package>'
  oldstablePackages = final: _prev: {
    oldstable = import inputs.nixpkgs-oldstable {
      inherit (final.stdenv.hostPlatform) system;
      config = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = true;
        nvidia.acceptLicense = true;
        permittedInsecurePackages = final.config.permittedInsecurePackages or [ ];
      };
    };
  };
}
