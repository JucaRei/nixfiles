{ lib, username, ... }:
let
  installFor = [ "juca" ];
in
lib.mkIf (lib.elem username installFor) {
  homebrew = {
    casks = [
      "heynote"
      "joplin"
    ];
  };
}
