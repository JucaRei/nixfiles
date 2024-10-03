{ config
, uthash
, lib
, stdenv
, nv-codec-headers-12
, fetchFromGitHub
, fetchpatch
, fetchurl
, addDriverRunpath
, cmake
, fdk_aac
, ffmpeg
, jansson
, libjack2
, libxkbcommon
, libpthreadstubs
, libXdmcp
, qtbase
, qtsvg
, speex
, libv4l
, x264
, curl
, wayland
, xorg
, pkg-config
, libvlc
, libGL
, mbedtls
, wrapGAppsHook3
, scriptingSupport ? true
, luajit
, swig4
, python3
, alsaSupport ? stdenv.isLinux
, alsa-lib
, pulseaudioSupport ? config.pulseaudio or stdenv.isLinux
, libpulseaudio
, libcef
, pciutils
, pipewireSupport ? stdenv.isLinux
, withFdk ? true
, pipewire
, libdrm
, librist
, libva
, srt
, qtwayland
, wrapQtAppsHook
, nlohmann_json
, websocketpp
, asio
, decklinkSupport ? false
, blackmagic-desktop-video
, libdatachannel
, libvpl
, qrcodegencpp
, nix-update-script
}:

let
  inherit (lib) optional optionals;
  #libcef_obs = libcef.overrideAttrs (_: {
  #  version = "5060";
  #  src = fetchurl {
  #    url = "https://cdn-fastly.obsproject.com/downloads/cef_binary_5060_linux_x86_64_v3.tar.xz";
  #    hash = "sha256-ElOmo2w7isW17Om/226uardeSVFjdfxHXi6HF5Wtm+o=1";
  #  };
  #  postUnpack = "rm -r */build";
  #});
in

stdenv.mkDerivation (finalAttrs: {
  pname = "obs-studio";
  version = "30.2.3";

  src = fetchFromGitHub {
    owner = "obsproject";
    repo = "obs-studio";
    rev = finalAttrs.version;
    hash = "sha256-4bAzW62xX9apKOAJyn3iys1bFdHj4re2reMZtlGsn5s=";
    fetchSubmodules = true;
  };

  patches = [
    # Lets obs-browser build against CEF 90.1.0+
    ./Enable-file-access-and-universal-access-for-file-URL.patch
    ./fix-nix-plugin-path.patch

    # Fix libobs.pc for plugins on non-x86 systems
    (fetchpatch {
      name = "fix-arm64-cmake.patch";
      url = "https://git.alpinelinux.org/aports/plain/community/obs-studio/broken-config.patch?id=a92887564dcc65e07b6be8a6224fda730259ae2b";
      hash = "sha256-yRSw4VWDwMwysDB3Hw/tsmTjEQUhipvrVRQcZkbtuoI=";
      includes = [ "*/CompilerConfig.cmake" ];
    })
  ];

  nativeBuildInputs = [
    addDriverRunpath
    cmake
    pkg-config
    wrapGAppsHook3
    wrapQtAppsHook
  ]
  ++ optional scriptingSupport swig4;

  buildInputs = [
    curl
    ffmpeg
    jansson
    libcef
    libjack2
    libv4l
    libxkbcommon
    libpthreadstubs
    libXdmcp
    qtbase
    qtsvg
    speex
    wayland
    x264
    libvlc
    mbedtls
    pciutils
    librist
    libva
    srt
    qtwayland
    nlohmann_json
    websocketpp
    asio
    libdatachannel
    libvpl
    qrcodegencpp
    uthash
    nv-codec-headers-12
  ]
  ++ optionals scriptingSupport [ luajit python3 ]
  ++ optional alsaSupport alsa-lib
  ++ optional pulseaudioSupport libpulseaudio
  ++ optionals pipewireSupport [ pipewire libdrm ]
  ++ optional withFdk fdk_aac;

  # Copied from the obs-linuxbrowser
  postUnpack = ''
    mkdir -p cef/Release cef/Resources cef/libcef_dll_wrapper/
    for i in ${libcef}/share/cef/*; do
      ln -s $i cef/Release/
      ln -s $i cef/Resources/
    done
    ln -s ${libcef}/lib/libcef.so cef/Release/
    ln -s ${libcef}/lib/libcef_dll_wrapper.a cef/libcef_dll_wrapper/
    ln -s ${libcef}/include cef/
  '';

  cmakeFlags = [
    "-DOBS_VERSION_OVERRIDE=${finalAttrs.version}"
    "-Wno-dev" # kill dev warnings that are useless for packaging
    # Add support for browser source
    "-DBUILD_BROWSER=ON"
    "-DCEF_ROOT_DIR=../../cef"
    "-DENABLE_JACK=ON"
    (lib.cmakeBool "ENABLE_QSV11" stdenv.hostPlatform.isx86_64)
    (lib.cmakeBool "ENABLE_LIBFDK" withFdk)
    (lib.cmakeBool "ENABLE_ALSA" alsaSupport)
    (lib.cmakeBool "ENABLE_PULSEAUDIO" pulseaudioSupport)
    (lib.cmakeBool "ENABLE_PIPEWIRE" pipewireSupport)
    (lib.cmakeBool "ENABLE_AJA" false) # TODO: fix linking against libajantv2
  ];

  env.NIX_CFLAGS_COMPILE = toString [
    "-Wno-error=sign-compare" # https://github.com/obsproject/obs-studio/issues/10200
  ];

  dontWrapGApps = true;
  preFixup = let
    wrapperLibraries = [
      xorg.libX11
      libvlc
      libGL
    ] ++ optionals decklinkSupport [
      blackmagic-desktop-video
    ];
  in ''
    # Remove libcef before patchelf, otherwise it will fail
    rm $out/lib/obs-plugins/libcef.so

    qtWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : "$out/lib:${lib.makeLibraryPath wrapperLibraries}"
      ''${gappsWrapperArgs[@]}
    )
  '';

  postFixup = lib.optionalString stdenv.isLinux ''
    addDriverRunpath $out/lib/lib*.so
    addDriverRunpath $out/lib/obs-plugins/*.so

    # Link libcef again after patchelfing other libs
    ln -s ${libcef}/lib/* $out/lib/obs-plugins/
  '';

  passthru.updateScript = nix-update-script { };

  meta = with lib; {
    description = "Free and open source software for video recording and live streaming";
    longDescription = ''
      This project is a rewrite of what was formerly known as "Open Broadcaster
      Software", software originally designed for recording and streaming live
      video content, efficiently
    '';
    homepage = "https://obsproject.com";
    maintainers = with maintainers; [ eclairevoyant jb55 materus fpletz ];
    license = with licenses; [ gpl2Plus ] ++ optional withFdk fraunhofer-fdk;
    platforms = [ "x86_64-linux" "i686-linux" "aarch64-linux" ];
    mainProgram = "obs";
  };
})