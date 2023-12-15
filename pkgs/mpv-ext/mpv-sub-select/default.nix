{ lib, stdenvNoCC, fetchgit }:
stdenvNoCC.mkDerivation rec {
  name = "mpv-sub-select";
  version = "1.0.0";

  src = fetchgit {
    url = "https://github.com/CogentRedTester/mpv-sub-select.git";
    rev = "a23111e181b0051854cc543a31bee4f6741183ac";
    sha256 = "0qkckq9wiln12rpdxhjx6v1w8n2pz3zrz5dj3s6sh4ksp973q23p";
    # hash = "sha256-dwg8Trp6EqiNHrKVn//4V1jEwzZdwt5uFsHSyBOebGI=";
  };

  dontBuild = true;

  installPhase = ''
    runHook preInstall

    mkdir -p $out/share/mpv/scripts
    cp sub-select.lua $out/share/mpv/scripts/sub-select.lua

    runHook postInstall
  '';

  passthru.scriptName = "sub-select.lua";

  meta = {
    description = "Automatically skip chapters based on title";
    homepage = "https://github.com/CogentRedTester/mpv-sub-select";
    maintainers = [ lib.maintainers.juca ];
  };
}

# nix-shell -p nix-prefetch-git --run 'nix-prefetch-git https://github.com/CogentRedTester/mpv-sub-select refs/heads/master'
