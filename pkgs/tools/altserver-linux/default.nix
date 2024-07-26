{ stdenv
, autoPatchelfHook
, makeWrapper
, avahi-compat
, lib
, ...
}:

stdenv.mkDerivation rec {
  pname = "altserver-linux";
  version = "0.0.5";

  src = builtins.fetchurl {
    url = "https://github.com/NyaMisty/AltServer-Linux/releases/download/v${version}/AltServer-x86_64";
    sha256 = "1yqpxarkihk2rlww9ja7zgzf9l656y73naq32mx1ghcyqsnw7rqb";
  };

  dontUnpack = true;

  nativeBuildInputs = [
    autoPatchelfHook
    makeWrapper
  ];

  runtimeDependencies = [
    avahi-compat
  ];

  installPhase = ''
    mkdir -p $out/{bin,share}
    cp $src $out/share/alt-server
    chmod +x $out/share/alt-server
    
    makeWrapper $out/share/alt-server $out/bin/alt-server \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath runtimeDependencies}
  '';
}
