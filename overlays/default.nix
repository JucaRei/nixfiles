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

    nixgl-legacy = prev.nixgl-legacy;

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
      patches = [./darwin.patch];
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

    cyberre-grub-theme = prev.cyberre-grub-theme;
  };

  packages = final: prev: {
    cyberre = final.cyberre-grub-theme;
    advcp = final.advmvcp;
    # hacked-cursor = final.breeze-hacked-cursorr;
    clonegit = final.cloneit;
    # deezer-gui = final.deezer;
    icloudpd = final.icloud-photo-downloader;
    # nvchad = prev.nvchad;
    nautilus-ext = final.nautilus-annotations;
    thorium = final.thorium-browser;
    hacked-cursor = final.breeze-hacked-cursor;
    # lockman = final.lockman-wayland;
    # pulseaudio-control = final.polybar-pulseaudio-control;
    # fantezy = final.fantezy-font;
    # nixos-summary = final.nixos-change-summary;
    # apple-font = final.apple-fonts;
    # mpvconf = prev.mpv;
    # example = prev.example.overrideAttrs (oldAttrs: rec {
    # ...
    # });
    nix-cleanup = final.nix-cleanup;
    inspect = final.nix-inspect;
    imgclr = prev.callPackage ../pkgs/image-colorizer {
      buildPythonPackage = prev.python310Packages.buildPythonPackage;
    };
    lutgen = prev.lutgenn;
    vt-view = final.vv;
    st = prev.st.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [prev.harfbuzz];
      src = prev.fetchFromGitHub {
        owner = "chadcat7";
        repo = "st";
        rev = "3d9eb51d43981963638a1b5a8a6aa1ace4b90fbb";
        sha256 = "007pvimfpnmjz72is4y4g9a0vpq4sl1w6n9sdjq2xb2igys2jsyg";
      };
    });
    # distrobox-fix = prev.distrobox;

    # Music
    # tidal = final.tidal-dl;

    # nvchad = final.nvim-chad;
    # phospor-ttf = final.phospor;
    # material-symbols-ttf = final.material-symbols;
    cairo-ttf = final.font-cairo;
    dubai-ttf = final.font-dubai;
    noto-sans-arabic-ttf = final.font-noto-sans-arabic;

    # mpv plugins
    anime4k = final.mpv-anime4k;
    dynamic-crop = final.mpv-dynamic-crop;
    modernx = final.mpv-modernx;
    nextfile = final.mpv-nextfile;
    # subselect = final.mpv-sub-select;
    subsearch = final.mpv-subsearch;
    thumbfast = final.mpv-thumbfast-osc;

    # Utils
    # youtube-tui = final.youtube_tui;

    plymouth-catppuccin = final.catppuccin-plymouth;
    sddm-astronaut = final.sddm-astronaut-theme;

    # Scripts
    nix-whereis = final.nix-whereis;

    gruvbox = final.gruv;
    # phocus = final.phocus-gtk;

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
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    # unstable = import inputs.nixpkgs-unstable {
    unstable = import inputs.unstable {
      system = final.system;
      config.allowUnfree = true;
    };
  };
}
