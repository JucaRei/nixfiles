{ lib
, stdenv
, fetchFromGitHub
, gtk-engine-murrine
, jdupes
, themeVariants ? [ ]
,
}:
let
  inherit (builtins) toString;
  inherit (lib.trivial) checkListOfEnum;
in
checkListOfEnum "$Everforest: GTK Theme Variants" [
  "B"
  "B-LB"
  "B-GS"
  "BL"
  "BL-LB"
  "BL-GS"
]
  themeVariants
  stdenv.mkDerivation
{
  pname = "everforest-gtk";
  version = "unstable-2023-12-30";

  src = fetchFromGitHub {
    owner = "Fausto-Korpsvart";
    repo = "Everforest-GKT-Theme";
    rev = "8481714cf9ed5148694f1916ceba8fe21e14937b";
    hash = "sha256-NO12ku8wnW/qMHKxi5TL/dqBxH0+cZbe+fU0iicb9JU=";
  };

  nativeBuildInputs = [ jdupes ];

  propagatedUserEnvPkgs = [ gtk-engine-murrine ];

  installPhase =
    let
      gtkTheme = "Everforest-${toString themeVariants}";
    in
    ''
      runHook preInstall

      mkdir -p $out/share/{icons,themes}

      cp -r $src/themes/${gtkTheme} $out/share/themes
      cp -r $src/icons/Everforest $out/share/icons

      # Duplicate files -> hard-links = reduced install-size!
      jdupes -L -r $out/share

      runHook postInstall
    '';

  meta = with lib; {
    description = "A GTK theme based on the Everforest colour palette";
    homepage = "https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme";
    license = licenses.gpl3Only;
    # maintainers = [ juca ];
    platforms = platforms.all;
  };
}

# nix-shell -p nix-prefetch-git --run 'nix-prefetch-git https://github.com/Fausto-Korpsvart/Everforest-GTK-Theme.git refs/heads/master'
