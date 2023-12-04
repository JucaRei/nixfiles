{ pkgs, lib, nixgl, ... }:
let
  # ...
  # nixgl = import <nixgl> {} ;
  nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
    mkdir $out
    ln -s ${pkg}/* $out
    rm $out/bin
    mkdir $out/bin
    for bin in ${pkg}/bin/*; do
      wrapped_bin=$out/bin/$(basename $bin)
      echo "exec ${lib.getExe nixgl.nixGLDefault} $bin \$@" > $wrapped_bin
      chmod +x $wrapped_bin
    done
  ''; 
  in
{
  home.packages = [
    (nixGLWrap pkgs.st)
    (nixGLWrap pkgs.firefox)
  ] ++ (with pkgs; [
    inxi
  ]);
}
