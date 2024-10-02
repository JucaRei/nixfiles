{ lib
, pkgs
, username
, ...
}:
let
  installFor = [ "juca" ];
  inherit (pkgs.stdenv) isLinux;
in
lib.mkIf (lib.elem username installFor && isLinux) {
  home = {
    packages = with pkgs; [ unstable.zed-editor ];
  };
}
