{ lib
, stdenv
, fetchFromGitHub
, qtgraphicaleffects
}:

stdenv.mkDerivation rec {
  pname = "sddm-astronaut-theme.nix";
  version = "";

  src = fetchFromGitHub {
    repo = "sddm-astronaut-theme";
    owner = "JucaRei";
    rev = "468a100460d5feaa701c2215c737b55789cba0fc";
    sha256 = "1h20b7n6a4pbqnrj22y8v5gc01zxs58lck3bipmgkpyp52ip3vig";
  };

  dontPatchELF = true;
  dontWrapQtApps = true;
  dontRewriteSymlinks = true;

  propagatedBuildInputs = [
    qtgraphicaleffects
  ];

  installPhase = ''
    mkdir -p $out/share/sddm/themes/astronaut
    mv * $out/share/sddm/themes/astronaut/
  '';

  postFixup = ''
    mkdir -p $out/nix-support
    echo ${qtgraphicaleffects} >> $out/nix-support/propagated-user-env-packages
  '';

  meta = with lib; {
    description = "Sddm theme for my dotfiles (v2).";
    homepage = src.meta.homepage;
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
# nix-shell -p nix-prefetch-git --run 'nix-prefetch-git https://github.com/JucaRei/sddm-astronaut-theme.git refs/heads/master'
