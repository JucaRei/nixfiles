{ pkgs, lib, ... }:
let

  nixGLMesaWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
        wrapped_bin=$out/bin/$(basename $bin)
        echo "exec ${lib.getExe pkgs.nixgl.nixGLIntel} $bin \$@" > $wrapped_bin
        chmod +x $wrapped_bin
      done
    '';

  nixGLVulkanWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
        wrapped_bin=$out/bin/$(basename $bin)
        echo "exec ${
          lib.getExe pkgs.nixgl.nixVulkanIntel
        } $bin \$@" > $wrapped_bin
        chmod +x $wrapped_bin
      done
    '';

  nixGLVulkanMesaWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
        wrapped_bin=$out/bin/$(basename $bin)
        echo "${lib.getExe pkgs.nixgl.nixGLIntel} ${
          lib.getExe pkgs.nixgl.nixVulkanIntel
        } $bin \$@" > $wrapped_bin
        chmod +x $wrapped_bin
      done
    '';


in
{
  nixGLMesaWrap = nixGLMesaWrap;
  nixGLVulkanWrap = nixGLVulkanWrap;
  nixGLVulkanMesaWrap = nixGLVulkanMesaWrap;
}
