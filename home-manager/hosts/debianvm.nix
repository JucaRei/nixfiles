{ pkgs, lib, ... }:
let
  # ...
  nixgl = import <nixgl> {} ;
  nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
    mkdir $out
    ln -s ${pkg}/* $out
    rm $out/bin
    mkdir $out/bin
    for bin in ${pkg}/bin/*; do
      wrapped_bin=$out/bin/$(basename $bin)
      echo "exec ${lib.getExe nixgl.auto.nixGLDefault} $bin \$@" > $wrapped_bin
      chmod +x $wrapped_bin
    done
  ''; 
  in
{
  home = {
    packages = with pkgs; [
      st
    ] ++ (nixgl.auto.nixGLDefault) (with nixGLWrap pkgs;[
      firefox
    ]);
  };
}
