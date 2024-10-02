{ lib
, pkgs
, username
, ...
}:
let
  installFor = [ "juca" ];
in
lib.mkIf (builtins.elem username installFor) {
  home = {
    packages = with pkgs; [
      cider
      youtube-music
    ];
  };
}
