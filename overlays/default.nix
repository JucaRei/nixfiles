{ inputs, ... }:
{
  # Brings custom local packages from the 'pkgs' directory
  localPackages = final: _prev: import ../pkgs final;

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

    # Profile-sync-daemon com suporte estendido (LibreWolf, Floorp, Brave, Edge e wrappers do Nix)
    profile-sync-daemon = prev.profile-sync-daemon.overrideAttrs (oldAttrs: {
      nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ final.makeWrapper ];
      installPhase = (oldAttrs.installPhase or "") + ''
        # Cria diretório de browsers caso não exista
        mkdir -p $out/share/psd/browsers

        # Copia navegadores adicionais da pasta contrib se presentes
        if [ -d contrib ]; then
          cp -r contrib/* $out/share/psd/browsers/ 2>/dev/null || true
        fi

        # Patch para detecção de processos com wrappers do Nix
        if [ -f $out/share/psd/browsers/firefox ]; then
          sed -i 's/PSNAME="$browser"/PSNAME="(firefox|\\.firefox-wra.*)"/' $out/share/psd/browsers/firefox 2>/dev/null || true
        fi
        if [ -f $out/share/psd/browsers/chromium ]; then
          sed -i 's/PSNAME="$browser"/PSNAME="(chromium|\\.chromium-wra.*)"/' $out/share/psd/browsers/chromium 2>/dev/null || true
        fi
        if [ -f $out/share/psd/browsers/google-chrome ]; then
          sed -i 's/PSNAME="chrome"/PSNAME="(chrome|google-chrome|\\.chrome-wra.*|\\.google-chrome-wra.*)"/' $out/share/psd/browsers/google-chrome 2>/dev/null || true
        fi
        if [ -f $out/share/psd/browsers/vivaldi ]; then
          sed -i 's/PSNAME="$browser"/PSNAME="(vivaldi|\\.vivaldi-wra.*)"/' $out/share/psd/browsers/vivaldi 2>/dev/null || true
        fi

        # Suporte nativo para LibreWolf
        cat << 'EOF' > $out/share/psd/browsers/librewolf
librewolf_dir=""
if [[ -d "$HOME/.librewolf" ]]; then
    librewolf_dir="$HOME/.librewolf"
elif [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/librewolf" ]]; then
    librewolf_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/librewolf"
fi

index=0
PSNAME="(librewolf|\.librewolf-wra.*)"
if [[ -n "$librewolf_dir" && -f "$librewolf_dir/profiles.ini" ]]; then
    while read -r profileItem; do
        if [[ $(echo "$profileItem" | cut -c1) = "/" ]]; then
            DIRArr[$index]="$profileItem"
        else
            DIRArr[$index]="$librewolf_dir/$profileItem"
        fi
        (( index=index+1 ))
    done < <(grep -i '^path=' "$librewolf_dir/profiles.ini" 2>/dev/null | sed -e 's/^[Pp]ath=//' | tr -d '\r')
fi
if [[ ''${#DIRArr[@]} -eq 0 && -n "$librewolf_dir" ]]; then
    for prof in "$librewolf_dir"/*.default*; do
        if [[ -d "$prof" ]]; then
            DIRArr[$index]="$prof"
            (( index=index+1 ))
        fi
    done
fi
check_suffix=1
EOF

        # Suporte nativo para Floorp
        cat << 'EOF' > $out/share/psd/browsers/floorp
floorp_dir=""
if [[ -d "$HOME/.floorp" ]]; then
    floorp_dir="$HOME/.floorp"
elif [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/floorp" ]]; then
    floorp_dir="''${XDG_CONFIG_HOME:-$HOME/.config}/floorp"
fi

index=0
PSNAME="(floorp|\.floorp-wra.*)"
if [[ -n "$floorp_dir" && -f "$floorp_dir/profiles.ini" ]]; then
    while read -r profileItem; do
        if [[ $(echo "$profileItem" | cut -c1) = "/" ]]; then
            DIRArr[$index]="$profileItem"
        else
            DIRArr[$index]="$floorp_dir/$profileItem"
        fi
        (( index=index+1 ))
    done < <(grep -i '^path=' "$floorp_dir/profiles.ini" 2>/dev/null | sed -e 's/^[Pp]ath=//' | tr -d '\r')
fi
if [[ ''${#DIRArr[@]} -eq 0 && -n "$floorp_dir" ]]; then
    for prof in "$floorp_dir"/*.default*; do
        if [[ -d "$prof" ]]; then
            DIRArr[$index]="$prof"
            (( index=index+1 ))
        fi
    done
fi
check_suffix=1
EOF

        # Suporte para Brave
        cat << 'EOF' > $out/share/psd/browsers/brave
if [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/BraveSoftware/Brave-Browser" ]]; then
    DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/BraveSoftware/Brave-Browser"
    PSNAME="(brave|\.brave-wra.*)"
fi
check_suffix=1
EOF

        # Suporte para Microsoft Edge
        cat << 'EOF' > $out/share/psd/browsers/microsoft-edge
if [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge" ]]; then
    DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge"
    PSNAME="(msedge|microsoft-edge|\.msedge-wra.*|\.microsoft-edge-wra.*)"
elif [[ -d "''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge-dev" ]]; then
    DIRArr[0]="''${XDG_CONFIG_HOME:-$HOME/.config}/microsoft-edge-dev"
    PSNAME="(msedge|microsoft-edge|\.msedge-wra.*|\.microsoft-edge-wra.*)"
fi
check_suffix=1
EOF

        # Patch no binário profile-sync-daemon para também buscar em ~/.config/psd/browsers
        sed -i 's|if \[\[ ! -f "$SHAREDIR/browsers/$browser" \]\]; then|if [[ ! -f "$SHAREDIR/browsers/$browser" \&\& ! -f "$PSDCONFDIR/browsers/$browser" ]]; then|g' $out/bin/profile-sync-daemon 2>/dev/null || true
        sed -i 's|\. "$SHAREDIR/browsers/$browser"|if [[ -f "$PSDCONFDIR/browsers/$browser" ]]; then . "$PSDCONFDIR/browsers/$browser"; else . "$SHAREDIR/browsers/$browser"; fi|g' $out/bin/profile-sync-daemon 2>/dev/null || true
      '';
      postFixup = (oldAttrs.postFixup or "") + ''
        wrapProgram $out/bin/profile-sync-daemon \
          --prefix PATH : ${final.lib.makeBinPath [
            final.rsync
            final.kmod
            final.gawk
            final.procps
            final.util-linux
            final.coreutils
            final.findutils
            final.gnugrep
            final.gnused
            final.fuse-overlayfs
            final.fuse3
          ]}
      '';
    });

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

  # Access older packages (NixOS 22.11) via 'pkgs.older.<package>'
  olderPackages = final: _prev: {
    older = import inputs.nixpkgs-older {
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
