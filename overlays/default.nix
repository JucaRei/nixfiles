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
      inherit (final) system;
      config = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = true;
        nvidia.acceptLicense = true;
        permittedInsecurePackages = [
          "broadcom-sta-6.30.223.271-59-5.15.212"
          "broadcom-sta-6.30.223.271-59-5.15"
          "broadcom-sta-6.30.223.271-59-6.18.40"
          "broadcom-sta-6.30.223.271-59-6.18"
          "broadcom-sta"
        ];
      };
    };
  };

  # Access oldstable packages via 'pkgs.oldstable.<package>'
  oldstablePackages = final: _prev: {
    oldstable = import inputs.nixpkgs-oldstable {
      inherit (final) system;
      config = {
        allowUnfree = true;
        allowBroken = true;
        allowInsecure = true;
        nvidia.acceptLicense = true;
        permittedInsecurePackages = [
          "broadcom-sta-6.30.223.271-59-5.15.212"
          "broadcom-sta-6.30.223.271-59-5.15"
          "broadcom-sta-6.30.223.271-59-6.18.40"
          "broadcom-sta-6.30.223.271-59-6.18"
          "broadcom-sta"
        ];
      };
    };
  };
}

