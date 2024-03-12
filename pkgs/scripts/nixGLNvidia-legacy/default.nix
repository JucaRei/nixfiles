{ fetchurl
, system ? builtins.currentSystem
, runCommand
, pkgs
, linuxPackages
, nvidiaVersion ? "340.108"
, nvidiaHash ? "sha256-xnHU8bfAm8GvB5uYtEetsG1wSwT4AvcEWmEfpQEztxs="
}:
let
  overlay = self: super:
    {
      linuxPackages = self: super: linuxPackages // {
        nvidia_x11 =
          # let
          #   linuxPackages = self: super: linuxPackages;
          # in
          (pkgs.linuxPackages.nvidia_x11.override { }).overrideAttrs (oldAttrs: {
            # name = "nvidia-${nvidiaVersion}";
            name = "nvidia-340.108";
            src = fetchurl {
              url = "http://download.nvidia.com/XFree86/Linux-x86_64/340.108/NVIDIA-Linux-x86_64-340.108.run";
              # sha256 = nvidiaHash;
              sha256 = "sha256-xnHU8bfAm8GvB5uYtEetsG1wSwT4AvcEWmEfpQEztxs=";
            };
            useGLVND = false;
          });

        nixpkgs = {
          overlays = [
            overlay
          ];
          config = { allowUnfree = true; };
        };
      };
    };

  # nvidia = overlay;

  nvidiaLibsOnly = overlay.override {
    libsOnly = true;
    kernel = null;
  };

  nixNvidiaWrapper = api: runCommand "nix${api}Nvidia"
    {
      buildInputs = [ nvidiaLibsOnly ];

      meta = with pkgs.stdenv.lib; {
        description = "nixGL libraries for old 340.108 nvidia gpu";
        homepage = "https://github.com/guibou/nixGL";
        # Thanks guibou and nix-community
      };
    } ''
    mkdir -p $out/bin
    cat > $out/bin/nix${api}Nvidia << FOO
    #!/usr/bin/env sh
    export LD_LIBRARY_PATH=${nvidiaLibsOnly}/lib
    "\$@"
    FOO

    chmod u+x $out/bin/nix${api}Nvidia
  '';
in
with pkgs ;
rec
{

  # export LD_LIBRARY_PATH=/run/opengl-driver/lib
  nixGLNvidia-legacy = nixNvidiaWrapper "GL" { };
  nixVulkanNvidia = nixNvidiaWrapper "Vulkan" { };
}
