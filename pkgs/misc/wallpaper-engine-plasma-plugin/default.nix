{ mkDerivation, fetchFromGitHub, cmake, extra-cmake-modules, plasma-framework
, gst-libav, mpv, websockets, qtwebsockets, qtwebchannel, qtdeclarative
, qtx11extras, vulkan-headers, vulkan-loader, vulkan-tools, pkg-config, lz4
, glslang }:

mkDerivation rec {
  pname = "wallpaper-engine-kde-plugin";
  version = "0.5.3";

  cmakeFlags = [ "-DUSE_PLASMAPKG=ON" ];
  nativeBuildInputs = [ cmake extra-cmake-modules pkg-config ];
  buildInputs = [
    plasma-framework
    mpv
    qtwebsockets
    websockets
    qtwebchannel
    qtdeclarative
    qtx11extras
    lz4
    vulkan-headers
    vulkan-tools
    vulkan-loader
  ];

  postPatch = ''
    rmdir src/backend_scene/third_party/glslang
    ln -s ${glslang.src} src/backend_scene/third_party/glslang
  '';

  src = fetchFromGitHub {
    owner = "catsout";
    repo = pname;
    rev = "v${version}";
    sha256 = "qmg+g1you3rm1EAfZWRUBBkEQm1QQ0V9/mIn8bBgbu4=";
  };
}

# let
#   engine = pkgs.plasma5Packages.callPackage ./wallpaper-engine-plasma-plugin.nix {
#     inherit (pkgs.gst_all_1) gst-libav;
#     inherit (pkgs.python3Packages) websockets;
#   };
# in
