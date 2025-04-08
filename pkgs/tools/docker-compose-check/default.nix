{ lib
, stdenv
, writeShellScript
, systemd
, util-linux
, coreutils
, ...
}:

stdenv.mkDerivation rec {
  pname = "docker-compose-check";
  version = "1.0.0";

  src = writeShellScript "docker-compose-check" ''
    running="$(docker-compose ps --services --filter "status=running")"
    services="$(docker-compose ps --services)"

    if [ "$running" != "$services" ]; then
      echo "Following services are not running:"
      # Bash specific
      comm -13 <(sort <<<"$running") <(sort <<<"$services")
      exit 1
    fi

    echo "All services are running"
  '';

  dontUnpack = true;

  installPhase = ''
    mkdir -p $out/bin
    cp $src $out/bin/docker-compose-check
    chmod +x $out/bin/*
  '';
}
