{ pkgs, lib, nixgl, ... }:
let
  # ...
  # imports =[ nixgl ];
  # nixGLWrap = pkg: pkgs.runCommand "${pkg.name}-nixgl-wrapper" {} ''
  #   mkdir $out
  #   ln -s ${pkg}/* $out
  #   rm $out/bin
  #   mkdir $out/bin
  #   for bin in ${pkg}/bin/*; do
  #     wrapped_bin=$out/bin/$(basename $bin)
  #     echo "exec ${lib.getExe nixgl.auto.nixGLDefault} $bin \"\$@\"" > $wrapped_bin
  #     chmod +x $wrapped_bin
  #   done
  # ''; 
  in
{
#   home.packages = [
#     nixgl.nixGLDefault
#     (nixGLWrap pkgs.st)
#     (nixGLWrap pkgs.firefox)
#   ] ++ (with pkgs; [
#     inxi
#   ]);

  home = {
    packages = with pkgs; [
      (nixGLVulkanMesaWrap firefox)
      st
    ];
  };
}
