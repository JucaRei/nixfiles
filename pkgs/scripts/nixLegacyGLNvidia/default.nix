{ system ? builtins.currentSystem
  # , nvidiaVersion ? null
, nvidiaVersion ? 340.08
  # , nvidiaHash ? null
, nvidiaHash ? "sha256-xnHU8bfAm8GvB5uYtEetsG1wSwT4AvcEWmEfpQEztxs="
, pkgs ? import <nixpkgs>
}:

let
  overlay = self: super:
    {
      linuxPackages = super.linuxPackages //
        {
          nvidia_x11 = (super.linuxPackages.nvidia_x11.override { }).overrideAttrs (oldAttrs: rec {
            name = "nvidia-${nvidiaVersion}";
            src = super.fetchurl {
              url = "http://download.nvidia.com/XFree86/Linux-x86_64/${nvidiaVersion}/NVIDIA-Linux-x86_64-${nvidiaVersion}.run";
              sha256 = nvidiaHash;
            };
            useGLVND = false;
          });
        };
    };

  nixpkgs = pkgs { overlays = [ overlay ]; config = { allowUnfree = true; }; };
in
with nixpkgs;
rec {
  nvidia = linuxPackages.nvidia_x11;

  nvidiaLibsOnly = nvidia.override {
    libsOnly = true;
    kernel = null;
  };

  nixNvidiaWrapper = api: runCommand "nix${api}Nvidia"
    {
      buildInputs = [ nvidiaLibsOnly ];

      meta = with pkgs.stdenv.lib; {
        description = "A tool to launch ${api} application on system other than NixOS - Nvidia version";
        homepage = "https://github.com/nix-community/nixGL";
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

  nixLegacyGLNvidia = nixNvidiaWrapper "GL";

  # nixLegacyVulkanNvidia = nixNvidiaWrapper "Vulkan";
}
