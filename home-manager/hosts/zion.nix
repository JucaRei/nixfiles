{ pkgs, lib, ... }:
let
  # For nixgl without having to always use nixgl.pkgs application before use it
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
  imports = [
    ../_mixins/apps/text-editor/vscode.nix
  ];
  home = {
    packages = [
      (nixGLVulkanMesaWrap pkgs.thorium)
      # (nixGLVulkanMesaWrap pkgs.unstable.vscode)
    ] ++ (with pkgs;[
      st
    ]);
  };
}
