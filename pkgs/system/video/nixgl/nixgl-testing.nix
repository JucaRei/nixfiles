{ system ? builtins.currentSystem
  # , nvidiaVersion ? null
, nvidiaVersion ? 340.108
  # , nvidiaHash ? null
, nvidiaHash ? "10kjccrkdn360035lh985cadhwy6lk9xrw3wlmww2wqfaa25f775"
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

  pkgs = { overlays = [ overlay ]; config = { allowUnfree = true; }; };
  api = 340.108;
in
with pkgs;
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
        homepage = "https://github.com/guibou/nixGL";
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

  nixGLNvidia = nixNvidiaWrapper "GL";

  nixVulkanNvidia = nixNvidiaWrapper "Vulkan";

  nixGLCommon = nixGL:
    runCommand "nixGLCommon"
      {
        buildInuts = [ nixGL ];
      }
      ''
        mkdir -p "$out/bin"
        cp "${nixGL}/bin/${nixGL.name}" "$out/bin/nixGL";
      '';
}
