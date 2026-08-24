{ inputs, ... }:
{
  # Brings custom local packages from the 'pkgs' directory
  localPackages = final: _prev: import ../pkgs final.pkgs;

  # Modifications to standard packages
  modifiedPackages = _final: prev: {
    makeModulesClosure = x:
      prev.makeModulesClosure (x // { allowMissing = true; });

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

