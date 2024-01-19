{ pkgs, lib, inputs, config, ... }:
let
  nixGL = import ../../lib/nixGL.nix { inherit config pkgs; };

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
    ../_mixins/apps/video/mpv.nix
    ../_mixins/apps/browser/firefox.nix
    # ../_mixins/apps/terminal/alacritty.nix
    # inputs.vscode-server.nixosModules.default
  ];
  home = {
    packages = [
      # (nixGL pkgs.thorium)
      # (nixGL pkgs.alacritty)
      (nixGL pkgs.vlc)
    ] ++ (with pkgs;[
      st
      kbdlight
      cloneit
    ]);
  };
}
