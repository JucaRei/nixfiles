# This file defines overlays
{inputs, ...}: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs {pkgs = final;};

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = _final: prev: {
    # https://github.com/NixOS/nixpkgs/issues/278277#issuecomment-1878292158
    keybase = prev.keybase.overrideAttrs (_old: rec {
      pname = "keybase";
      version = "6.2.4";
      src = prev.fetchFromGitHub {
        owner = "keybase";
        repo = "client";
        rev = "v${version}";
        hash = "sha256-z7vpCUK+NU7xU9sNBlQnSy9sjXD7/m8jSRKfJAgyyN8=";
      };
    });

    pythonPackagesExtensions =
      prev.pythonPackagesExtensions
      ++ [
        (python-final: python-prev: {
          default =
            python-prev.default.overridePythonAttrs
            (oldAttrs: {patches = [./ceph.patch];});
        })
      ];

    # nixgl-legacy = prev.nixgl-legacy;

    steam = prev.steam.override {
      extraPkgs = pkgs:
        with pkgs; [
          keyutils
          libkrb5
          libpng
          libpulseaudio
          libvorbis
          stdenv.cc.cc.lib
          xorg.libXcursor
          xorg.libXi
          xorg.libXinerama
          xorg.libXScrnSaver
        ];
    };

    google-chrome = prev.google-chrome.overrideAttrs (old: {
      installPhase =
        old.installPhase
        + ''
          fix=" --enable-features=WebUIDarkMode --force-dark-mode"

          substituteInPlace $out/share/applications/google-chrome.desktop \
            --replace $exe "$exe$fix"
        '';
    });

    keybase-gui = prev.keybase-gui.overrideAttrs (_old: rec {
      pname = "keybase-gui";
      version = "6.2.4";
      versionSuffix = "20240101011938.ae7e4a1c15";
      src = prev.fetchurl {
        url = "https://s3.amazonaws.com/prerelease.keybase.io/linux_binaries/deb/keybase_${
          version + "-" + versionSuffix
        }_amd64.deb";
        hash = "sha256-XyGb9F83z8+OSjxOaO5k+h2qIY78ofS/ZfTXki54E5Q=";
      };
    });

    # nixGL-legacy = inputs.nixpkgs.callPackage "${builtins.fetchTarball {
    #   url = "https://github.com/guibou/nixGL/archive/9e33a6ecb11551b88a95ab134dc4600003330405.tar.gz";
    #   #sha256 = pkgs.lib.fakeSha256;
    #   sha256 = "0f10mazqf2fm01sx8ai699xccy0pcabw60n8k3bna7ryijgwy7jq";
    #   buildInputs = [prev.python3];
    #   installPhase = ''
    #     mkdir -p $out/bin
    #       ./nvidiaInstall.py 340.108 nixGLNvidia
    #       cp result/bin/nixGLNvidia $out/bin
    #   '';
    # }}/default.nix" {};

    librist = prev.librist.overrideAttrs (_old: rec {
      pname = "librist";
      version = "0.2.10";
      src = prev.fetchFromGitLab {
        domain = "code.videolan.org";
        owner = "rist";
        repo = "librist";
        rev = "v${version}";
        hash = "sha256-8N4wQXxjNZuNGx/c7WVAV5QS48Bff5G3t11UkihT+K0=";
      };
      patches = [./patches/darwin.patch];
    });

    nelua = prev.nelua.overrideAttrs (_old: {
      pname = "nelua";
      version = "unstable-2023-11-19";
      src = prev.fetchFromGitHub {
        owner = "edubart";
        repo = "nelua-lang";
        rev = "e82695abf0a68a30a593cefb0bf1143cf9e14b6b";
        hash = "sha256-Srgoq07JQirxmZcDvw4UdfoYZ5HFT0PbYPoHY99BW/c=";
      };
    });

    syncthingtray = prev.syncthingtray.overrideAttrs (_old: rec {
      pname = "syncthingtray";
      version = "1.4.12";
      src = prev.fetchFromGitHub {
        owner = "Martchus";
        repo = "syncthingtray";
        rev = "v${version}";
        sha256 = "sha256-KfJ/MEgQdvzAM+rnKGMsjnRrbFeFu6F8Or+rgFNLgFI=";
      };
    });

    waybar = prev.waybar;

    nix-inspect = prev.nix-inspect;

    cloneit = prev.cloneit;

    cyberre-grub-theme = prev.cyberre-grub-theme;
    catppuccin-plymouth = prev.catppuccin-plymouth;
    advmvcp = prev.advmvcp;
    icloud-photo-downloader = prev.icloud-photo-downloader;
    nautilus-annotations = prev.nautilus-annotations;
    thorium-browser = prev.thorium-browser;
    breeze-hacked-cursor = prev.breeze-hacked-cursor;
    sddm-astronaut-theme = prev.sddm-astronaut-theme;
    nix-cleanup = prev.nix-cleanup;
    imgclr = prev.callPackage ../pkgs/utils/image-colorizer {
      buildPythonPackage = prev.python310Packages.buildPythonPackage;
    };
    lutgen = prev.lutgen;
    vv = prev.vv;
    # st = prev.st.overrideAttrs (oldAttrs: {
    #   buildInputs = oldAttrs.buildInputs ++ [prev.harfbuzz];
    #   src = prev.fetchFromGitHub {
    #     owner = "chadcat7";
    #     repo = "st";
    #     rev = "3d9eb51d43981963638a1b5a8a6aa1ace4b90fbb";
    #     sha256 = "007pvimfpnmjz72is4y4g9a0vpq4sl1w6n9sdjq2xb2igys2jsyg";
    #   };
    # });

    # fonts
    font-cairo = prev.font-cairo;
    font-dubai = prev.font-dubai;
    font-noto-sans-arabic = prev.font-noto-sans-arabic;
    iosevka-q = prev.iosevka-q;
    serasa-gothic = prev.serasa-gothic;

    # mpv plugins
    mpv-anime4k = prev.mpv-anime4k;
    mpv-dynamic-crop = prev.mpv-dynamic-crop;
    mpv-modernx = prev.mpv-modernx;
    mpv-nextfile = prev.mpv-nextfile;
    mpv-subsearch = prev.mpv-subsearch;
    mpv-sub-select = prev.mpv-sub-select;
    mpv-thumbfast-osc = prev.mpv-thumbfast-osc;
    # youtube_tui = prev.youtube_tui;
    nix-whereis = prev.nix-whereis;
    gruvbox-dark = prev.gruvbox-dark;
  };

  # accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
