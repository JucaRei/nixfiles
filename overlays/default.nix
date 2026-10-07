{ inputs, ... }:
{
  # Brings custom local packages from the 'pkgs' directory
  localPackages = final: _prev: import ../pkgs final.pkgs;

  # Modifications to standard packages
  modifiedPackages = final: prev: {
    makeModulesClosure = x: prev.makeModulesClosure (x // { allowMissing = true; });

    # Fallback to unstable antigravity-cli if not present in current nixpkgs stable
    antigravity-cli = (prev.antigravity-cli or final.unstable.antigravity-cli).overrideAttrs (_old: {
      doInstallCheck = false;
      installCheckPhase = "true";
    });

    # Polybar com suporte nativo a PulseAudio habilitado globalmente (necessário para internal/pulseaudio)
    polybar = prev.polybar.override {
      pulseSupport = true;
      i3Support = false;
    };

    # Noctalia (v5+): fallback unstable + wrapper com xdg-utils no PATH e auto-patch do plugin keymap
    noctalia =
      let
        baseNoctalia = prev.noctalia or final.unstable.noctalia;
        keymapPatch = ./patches/noctalia-keymap-performance.patch;
      in
      final.symlinkJoin {
        name = "noctalia-${baseNoctalia.version or "5.0.0"}";
        paths = [ baseNoctalia ];
        postBuild = ''
          rm "$out/bin/noctalia"
          cat > "$out/bin/noctalia" << EOF
#!${final.bash}/bin/bash
export PATH="${
  final.lib.makeBinPath [
    final.xdg-utils
    final.patch
  ]
}:\$PATH"

KEYMAP_PANEL="\$HOME/.local/state/noctalia/plugins/materialized/community/keymap/panel.luau"
if [ -f "\$KEYMAP_PANEL" ] && ! grep -q "PANEL_STEP_KEY" "\$KEYMAP_PANEL" 2>/dev/null; then
  ${final.patch}/bin/patch -s -f "\$KEYMAP_PANEL" < "${keymapPatch}" 2>/dev/null || true
fi

exec "${baseNoctalia}/bin/noctalia" "\$@"
EOF
          chmod +x "$out/bin/noctalia"
        '';
        passthru = (baseNoctalia.passthru or { }) // {
          unwrapped = baseNoctalia;
          inherit keymapPatch;
        };
      };

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

    # Fix for Catfish: requires which, findutils and file in PATH to detect search backend (locate/find)
    catfish = prev.catfish.overrideAttrs (old: {
      preFixup = (old.preFixup or "") + ''
        gappsWrapperArgs+=(--prefix PATH : "${
          final.lib.makeBinPath [
            final.which
            final.findutils
            final.file
          ]
        }")
      '';
    });

    # Compatibility aliases for fcitx5 packages migrated to qt6Packages in recent nixpkgs
    fcitx5-with-addons = final.qt6Packages.fcitx5-with-addons;
    fcitx5-configtool = final.qt6Packages.fcitx5-configtool;
    fcitx5-chinese-addons = final.qt6Packages.fcitx5-chinese-addons;
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
