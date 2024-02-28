{
  lib,
  stdenv,
  pkg-config,
  fetchFromGitHub,
  cmake,
  wrapGAppsHook,
  avahi,
  avahi-compat,
  openssl,
  gst_all_1,
  libplist,
}:
stdenv.mkDerivation rec {
  pname = "uxplay";
  version = "1.57";

  src = fetchFromGitHub {
    owner = "FDH2";
    repo = "UxPlay";
    rev = "v${version}";
    sha256 = "sha256-KdKpZi5OiC5GNON4rKy5vs1dt+CCWic7SKwZYN6jY9E=";
  };

  nativeBuildInputs = [cmake openssl libplist pkg-config wrapGAppsHook];

  buildInputs = [
    avahi
    avahi-compat
    gst_all_1.gstreamer
    gst_all_1.gst-plugins-base
    gst_all_1.gst-plugins-good
    gst_all_1.gst-plugins-bad
    gst_all_1.gst-plugins-ugly
    gst_all_1.gst-libav
  ];

  meta = with lib; {
    homepage = "https://github.com/FDH2/UxPlay";
    description = "AirPlay Unix mirroring server";
    license = licenses.gpl3Plus;
    maintainers = with maintainers; [azuwis];
    platforms = platforms.unix;
  };
}
