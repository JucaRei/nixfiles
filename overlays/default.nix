# This file defines overlays
{ inputs, ... }: {
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {

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
    inspect = final.nix-inspect;
    imgclr = prev.callPackage ../pkgs/image-colorizer {
      buildPythonPackage = prev.python310Packages.buildPythonPackage;
    };
    lutgen = prev.lutgenn;
    vt-view = final.vv;
    st = prev.st.overrideAttrs (oldAttrs: {
      buildInputs = oldAttrs.buildInputs ++ [ prev.harfbuzz ];
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
    material-symbols-ttf = final.material-symbols;
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
    nixclean = final.nix-cleanup;
    nixwhereis = final.nix-whereis;

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
