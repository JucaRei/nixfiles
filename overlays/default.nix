{ inputs, ... }:
{
  # Brings custom local packages from the 'pkgs' directory
  localPackages = final: _prev: import ../pkgs final.pkgs;

  # Modifications to standard packages
  modifiedPackages = final: prev: {
    makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });

    # Fallback to unstable antigravity-cli if not present in current nixpkgs stable
    antigravity-cli = prev.antigravity-cli or final.unstable.antigravity-cli;

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

    # Fix for Vivaldi 8.1: link bundled libffmpeg.so to versioned name expected by vivaldi launcher
    # and ensure opt/vivaldi is in LD_LIBRARY_PATH so dynamic linker finds libffmpeg.so
    vivaldi = prev.vivaldi.overrideAttrs (old: {
      postInstall = (old.postInstall or "") + ''
        chmod +x "$out/opt/vivaldi/update-ffmpeg"
        wrapProgram "$out/bin/vivaldi" \
          --prefix LD_LIBRARY_PATH : "$out/opt/vivaldi"
      '';
    });

    # Fix for Noctalia Shell on MangoWM: enable ext-workspace-v1 protocol and workspace discovery
    noctalia-shell = prev.noctalia-shell.overrideAttrs (old: {
      patches = (old.patches or [ ]) ++ (
        final.lib.optional (
          !(builtins.elem ./patches/noctalia-mangowm-workspaces.patch (old.patches or [ ]))
        ) ./patches/noctalia-mangowm-workspaces.patch
      );
    });
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
