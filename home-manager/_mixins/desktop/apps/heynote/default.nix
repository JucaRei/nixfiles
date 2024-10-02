{ lib
, pkgs
, platform
, username
, ...
}:
let
  installFor = [ "juca" ];
  inherit (pkgs.stdenv) isLinux;
in
lib.mkIf (lib.elem username installFor) {
  home = {
    packages = [ pkgs.heynote ];
  };
}
