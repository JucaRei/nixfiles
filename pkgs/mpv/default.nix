{
  pkgs,
  lib,
  ...
}: let
  # This is a very convoluted fetchurl, but has more info so that it can be more easily converted into a proper package
  singleFileScript = inputs @ {
    pname,
    rev,
    filename,
    url,
    sha256,
    meta,
  }:
    pkgs.callPackage
    (
      import ./single-file.nix inputs
    )
    {};
in {
  mpvScripts = {
    betterChapters = singleFileScript rec {
      pname = "mpv-betterChapters";
      rev = "1d1daf22f0ec5f0219e4e72216e772828f5c8e4c";
      filename = "betterchapters.lua";
      url = "https://gist.githubusercontent.com/Hakkin/4f978a5c87c31f7fe3ae/raw/${rev}/${filename}";
      sha256 = "sha256-bPH9sm/aO/FnWYY8K+2DFjFahaOCrSj5Es2bqfBk9ow=";
      meta = with lib; {
        description = "Loads the next or previous playlist entry if there are no more chapters in the seek direction.";
        homepage = "https://gist.github.com/Hakkin/4f978a5c87c31f7fe3ae";
        license = licenses.unfree;
        # mantainers = ;
      };
    };

    # Pay attention to https://github.com/po5/evafast/pull/8
    evafast = singleFileScript rec {
      pname = "mpv-evafast";
      rev = "f9ee7e41dedf0f65186900e0ccdd6ca6a8ced7ed";
      filename = "evafast.lua";
      url = "https://raw.githubusercontent.com/po5/evafast/${rev}/${filename}";
      sha256 = "sha256-UkqWhHws0V7rV5f2w7g3d0jHvEP70zhbomE8AQIiwh0=";
      meta = with lib; {
        description = "mpv script for hybrid fastforward and seeking";
        homepage = "https://github.com/po5/evafast";
        license = licenses.unfree;
        # mantainers = ;
      };
    };

    pauseWhenMinimize = pkgs.callPackage ./pauseWhenMinimize.nix {};
  };

  shaders = {
    # https://gist.github.com/igv
    SSimSuperRes = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/igv/2364ffa6e81540f29cb7ab4c9bc05b6b/raw/15d93440d0a24fc4b8770070be6a9fa2af6f200b/SSimSuperRes.glsl";
      sha256 = "sha256-qLJxFYQMYARSUEEbN14BiAACFyWK13butRckyXgVRg8=";
    };

    SSimDownscaler = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/igv/36508af3ffc84410fe39761d6969be10/raw/6998ff663a135376dbaeb6f038e944d806a9b9d9/SSimDownscaler.glsl";
      sha256 = "sha256-FF3rw4DzwgWLHSkziQXSvIBgAxVtZ0skdFJ03S1QmQY=";
    };

    KrigBilateral = pkgs.fetchurl {
      url = "https://gist.githubusercontent.com/igv/a015fc885d5c22e6891820ad89555637/raw/7c151e0af2281ae6657809be1f3c5efe0e325c38/KrigBilateral.glsl";
      sha256 = "sha256-uIbPX59nIHeHC9wa1Mv1nQartUusOgXaEHQyA95BST8=";
    };

    anime4k = pkgs.callPackage ./an4k.nix {};

    fsrcnnx = pkgs.callPackage ./fsrcnnx.nix {};
  };
}
