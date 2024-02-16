{
  lib,
  fetchFromGitHub,
  sources,
}:
# TODO: Clean up this mess
{nvidia ? false}: let
  # nixpkgs = fetchFromGitHub {
  #   owner = "NixOS";
  #   repo = "nixpkgs";
  #   rev = "73b135e6b831166dffdefd5bed299c54883b552a";
  #   sha256 = "0kniph5rnyhqqdhlrffsrqys4s49yp0jikifcms5kdkmz08ggfks";
  # };
  # From https://github.com/guibou/nixGL
  nvidiaVersion = "340.108";
  nvidiaHash = "10kjccrkdn360035lh985cadhwy6lk9xrw3wlmww2wqfaa25f775";
  top = rec {
    pkgs = import <nixpkgs> {config.allowUnfree = true;};
    nvidiaVersion = "340.108";
    nvidiaLibs =
      (pkgs.linuxPackages.nvidia_x11.override {
        libsOnly = true;
        kernel = null;
      })
      .overrideAttrs
      (oldAttrs: rec {
        name = "nvidia-${nvidiaVersion}";
        src = pkgs.fetchurl {
          url = "http://download.nvidia.com/XFree86/Linux-x86_64/${nvidiaVersion}/NVIDIA-Linux-x86_64-${nvidiaVersion}.run";
          sha256 = "10kjccrkdn360035lh985cadhwy6lk9xrw3wlmww2wqfaa25f775";
        };
        useGLVND = 0;
      });
  };
in
  top
  // (
    if nvidiaVersion != null
    then
      top.nvidiaPackages {
        version = nvidiaVersion;
        sha256 = nvidiaHash;
      }
    else {}
  )
