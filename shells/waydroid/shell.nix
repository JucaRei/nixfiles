### shell.nix for waydroid_script
{ pkgs ? import <nixpkgs> { } }:
let
  python-with-my-packages = pkgs.python3.withPackages (p:
    with p; [
      dbus-python
      tqdm
      requests
    ]);
in
with pkgs;
mkShell {
  packages = [ lzip python-with-my-packages sqlite ];
}
