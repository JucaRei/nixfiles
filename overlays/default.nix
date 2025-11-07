{ inputs, ... }:
{
  # This one brings our custom packages from the 'pkgs' directory
  localPackages = final: _prev: import ../pkgs final.pkgs;

  # https://nixos.wiki/wiki/Overlays
  modifiedPackages = _final: prev: {

    #linuxPackages_latest = prev.linuxPackages_latest.extend (_lpself: lpsuper: {
    #  mwprocapture = lpsuper.mwprocapture.overrideAttrs ( old: rec {
    #    pname = "mwprocapture";
    #    subVersion = "4390";
    #    version = "1.3.0.${subVersion}";
    #    src = prev.fetchurl {
    #      url = "https://www.magewell.com/files/drivers/ProCaptureForLinux_${subVersion}.tar.gz";
    #      sha256 = "sha256-a2cU7PYQh1KR5eeMhMNx2Sc3HHd7QvCG9+BoJyVPp1Y=";
    #    };
    #  });
    #});

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

    # hyprland = prev.hyprland.overrideAttrs (_old: rec {
    #   postPatch = _old.postPatch + ''
    #     sed -i 's|Exec=Hyprland|Exec=hypr-launch|' example/hyprland.desktop
    #   '';
    # });

    # wavebox = prev.wavebox.overrideAttrs (_old: rec {
    #   pname = "wavebox";
    #   version = "10.128.5-2";
    #   src = prev.fetchurl {
    #     url = "https://download.wavebox.app/stable/linux/deb/amd64/wavebox_${version}_amd64.deb";
    #     sha256 = "sha256-eIiFiRlmnARtyd8YHUHrjDaaF8kQYvcOa2AwT3071Ho=";
    #   };
    # });

    # linuxPackages_6_12 = prev.linuxPackages_6_12.extend (_lpself: lpsuper: {
    #   mwprocapture = lpsuper.mwprocapture.overrideAttrs (old: rec {
    #     pname = "mwprocapture";
    #     subVersion = "4479";
    #     version = "1.3.${subVersion}";
    #     src = prev.fetchurl {
    #       url = "https://www.magewell.com/files/drivers/ProCaptureForLinuxPUBLIC_${version}.tar.gz";
    #       sha256 = "sha256-jol3Ws3k8n6fyprqb4pgh7zOg6PJmXRpzZOQ3WALA2o=";
    #     };
    #   });
    # });
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstablePackages = final: _prev: {
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
  oldstablePackages = final: _prev: {
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
