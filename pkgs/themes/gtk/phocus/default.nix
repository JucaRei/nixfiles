{ stdenvNoCC, fetchFromGitHub, nodePackages, colors, }:
stdenvNoCC.mkDerivation rec {
  pname = "phocus";
  version = "0cf0eb35a927bffcb797db8a074ce240823d92de";

  src = fetchFromGitHub {
    owner = "phocus";
    repo = "gtk";
    rev = version;
    sha256 = "sha256-URuoDJVRQ05S+u7mkz1EN5HWquhTC4OqY8MqAbl0crk=";
  };

  patches = [ ./npm.diff ./gradients.diff ./substitute.diff ];

  postPatch = ''
    substituteInPlace scss/gtk-3.0/_colors.scss \
      --replace "@bg0@" "#${colors.background}" \
      --replace "@bg1@" "#${colors.contrast}" \
      --replace "@bg2@" "#${colors.color8}"\
      --replace "@bg3@" "#${colors.color0}" \
      --replace "@bg4@" "#${colors.comment}" \
      --replace "@red@" "#${colors.color1}" \
      --replace "@lred@" "#${colors.color9}" \
      --replace "@orange@" "#${colors.color3}" \
      --replace "@lorange@" "#${colors.color11}" \
      --replace "@yellow@" "#${colors.color3}" \
      --replace "@lyellow@" "#${colors.color11}" \
      --replace "@green@" "#${colors.color2}" \
      --replace "@lgreen@" "#${colors.color10}" \
      --replace "@cyan@" "#${colors.color6}" \
      --replace "@lcyan@" "#${colors.color15}" \
      --replace "@blue@" "#${colors.color4}" \
      --replace "@lblue@" "#${colors.color12}" \
      --replace "@purple@" "#${colors.color5}" \
      --replace "@lpurple@" "#${colors.color14}" \
      --replace "@pink@" "#${colors.color5}" \
      --replace "@lpink@" "#${colors.color14}" \
      --replace "@primary@" "#${colors.foreground}" \
      --replace "@secondary@" "#${colors.color15}"
  '';

  nativeBuildInputs = [ nodePackages.sass ];
  installFlags = [ "DESTDIR=$(out)" "PREFIX=" ];
}

