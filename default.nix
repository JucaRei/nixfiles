(import
  (fetchTarball {
    url = "https://github.com/edolstra/flake-compat/archive/master.tar.gz";
    sha256 = "0x2jz3jcis8q2pr4fqy0mhlm9v8xd3yp8w9s9p1p2ykf7z5c9sgp";
  })
  {
    src = ./.;
  }).defaultNix
