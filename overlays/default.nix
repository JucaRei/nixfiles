# This file defines overlays
{ inputs, ... }:
let
  polybar-scripts = inputs.polybar-scripts // {
    version = "git-" + builtins.substring 0 7 inputs.polybar-scripts.rev;
  };
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: _prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  # Get 1.3.0 to addres infinite loop:
  # - https://github.com/Cisco-Talos/clamav/pull/1047
  modifications = _final: prev: {
    gnome = prev.gnome.overrideScope' (gself: gsuper: {
      nautilus = gsuper.nautilus.overrideAttrs (nsuper: {
        buildInputs =
          nsuper.buildInputs
          ++ (with prev.gst_all_1; [
            gst-plugins-good
            gst-plugins-bad
          ]);
      });
    });

    mpv = prev.pkgs.wrapMpv
      (prev.pkgs.unstable.mpv-unwrapped.override {
        # mpv 0.37
        # (prev.pkgs.mpv-unwrapped.override {
        vapoursynthSupport = true;
        cddaSupport = true; # Support for playing CDs with `mpv cdda:///dev/sr0`
        waylandSupport = true;
        jackaudioSupport = true; # Add jack support to mpv.
        # webp support
        ffmpeg = prev.pkgs.ffmpeg_7-full;
      })
      {
        extraMakeWrapperArgs = [
          "--prefix"
          "LD_LIBRARY_PATH"
          ":"
          "${prev.pkgs.vapoursynth-mvtools}/lib/vapoursynth"
        ];
        scripts = with prev.pkgs.mpvScripts;
          [
            # thumbnail
            thumbfast # High-performance on-the-fly thumbnailer.
            autoload # Automatically load playlist entries before and after the currently playing file, by scanning the directory.
            mpris
            uosc # Adds a minimalist but highly customisable GUI.
            acompressor
            webtorrent-mpv-hook # Adds a hook that allows mpv to stream torrents. It provides an osd overlay to show info/progress.
            inhibit-gnome
            autodeint # Automatically insert the appropriate deinterlacing filter based on a short section of the current video, triggered by key bind.
            sponsorblock
          ];
      };

    cloneit = prev.cloneit;
    lima-bin = prev.lima-bin;
    thorium = prev.thorium;
    fluent = prev.fluent;
    # chatgpt-cli = prev.chatgpt-cli;
    advmvcp = prev.advmvcp;
    nix-cleanup = prev.nix-cleanup;
    nix-whereis = prev.nix-whereis;
    nix-inspect = prev.nix-inspect;
    nixos-tweaker = prev.nixos-tweaker;
    sarasa-gothic = prev.sarasa-gothic;
    iosevka-q = prev.iosevka-q;
    nf-iosevka = prev.nf-iosevka;
    bebasNeue = prev.bebasNeue;
    feather = prev.feather;
    abel = prev.abel;
    catppuccin-grub = prev.catppuccin-grub;
    cyberre-grub-theme = prev.cyberre-grub-theme;
    astronaut-sddm = prev.astronaut-sddm;
    # spotdl = prev.callPackage ../pkgs/tools/spotdl {
    #   buildPythonApplication = prev.python311Packages.buildPythonApplication;
    # };
    juca-avatar = prev.juca-avatar;

    player-mpris-tail = prev.pkgs.callPackage ../pkgs/scripts/polybar-scripts/player-mpris-tail {
      inherit polybar-scripts;
      inherit (prev) stdenv;
      inherit (prev.python3Packages) wrapPython dbus-python pygobject3;
    };
    polywins = prev.polywins;
    weather-bar = prev.weather-bar;
    cava-polybar = prev.cava-polybar;
    xqp = prev.xqp;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: _prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };

  legacy-packages = final: _prev: {
    legacy = import inputs.nixpkgs-legacy {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
