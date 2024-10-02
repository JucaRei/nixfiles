{ lib
, pkgs
, username
, ...
}:
let
  installFor = [ "juca" ];
in
lib.mkIf (lib.elem username installFor) {
  environment.systemPackages = with pkgs; [
    _1password
    _1password-gui
  ];
}
