# This file defines overlays
{ inputs, ... }:
let
  polybar-scripts = inputs.polybar-scripts // {
    version = "git-" + builtins.substring 0 7 inputs.polybar-scripts.rev;
  };
in
{
  # This one brings our custom packages from the 'pkgs' directory
  additions = final: prev: import ../pkgs { pkgs = final; };

  # This one contains whatever you want to overlay
  # You can change versions, add patches, set compilation flags, anything really.
  # https://nixos.wiki/wiki/Overlays
  modifications = final: prev: {
    # https://discourse.nixos.org/t/davinci-resolve-studio-install-issues/37699/44
    # https://theholytachanka.com/posts/setting-up-resolve/
    davinci-resolve = prev.davinci-resolve.override (old: {
      buildFHSEnv =
        a:
        (old.buildFHSEnv (
          a
          // {
            extraBwrapArgs = a.extraBwrapArgs ++ [ "--bind /run/opengl-driver/etc/OpenCL /etc/OpenCL" ];
          }
        ));
    });
    davinci-resolve-studio = prev.davinci-resolve-studio.override (old: {
      buildFHSEnv =
        a:
        (old.buildFHSEnv (
          a
          // {
            extraBwrapArgs = a.extraBwrapArgs ++ [ "--bind /run/opengl-driver/etc/OpenCL /etc/OpenCL" ];
          }
        ));
    });

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

    #linuxPackages_latest = prev.linuxPackages_latest.extend (_lpself: lpsuper: {
    #  mwprocapture = lpsuper.mwprocapture.overrideAttrs ( old: rec {
    #    pname = "mwprocapture";
    #    subVersion = "4390";
    #    version = "1.3.0.${subVersion}";
    #    src = prev.fetchurl {
    #      url = "https://www.magewell.com/files/drivers/ProCaptureForLinux_${subVersion}.tar.gz";
    #      sha256 = "sha256-a2cU7PYQh1KR5eeMhMNx2Sc3HHd7QvCG9+BoJyVPp1Y=";
    #    };
    #  });
    #});

    # mpv 0.36
    mpv = prev.pkgs.wrapMpv
      # (prev.pkgs.unstable.mpv-unwrapped.override { # mpv 0.37
      (prev.pkgs.mpv-unwrapped.override {
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

    openasar = prev.openasar.overrideAttrs (old: rec {
      pname = "openasar";
      version = "0-unstable-2024-06-30";
      src = prev.fetchFromGitHub {
        owner = "GooseMod";
        repo = "OpenAsar";
        rev = "5c875eb048e96543f1ec711fae522ace5e4a836c";
        hash = "sha256-dlf4X+2W2GfL2E46ZM35PqpcoKHoZ4fhroOCLpye1D0=";
      };
    });

    # nixGL = prev.inputs.nixgl.overlay;

    nixLegacyGLNvidia = prev.nixLegacyGLNvidia;
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
    nixgl = inputs.nixgl.overlay;
    nur = inputs.nur.overlay;
  };

  # When applied, the unstable nixpkgs set (declared in the flake inputs) will
  # be accessible through 'pkgs.unstable'
  unstable-packages = final: prev: {
    unstable = import inputs.nixpkgs-unstable {
      inherit (final) system;
      config.allowUnfree = true;
    };
  };
}
