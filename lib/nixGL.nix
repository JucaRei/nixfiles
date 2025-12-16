# lib/nixGL.nix
# Pure nixGL wrapper — auto-detects driver at runtime, no impurities
{ pkgs }:

pkg: pkgs.runCommandLocal "${pkg.name}-nixgl"
{
  nativeBuildInputs = [ pkgs.makeWrapper ];
  preferLocalBuild = true;
  allowSubstitutes = false;
} ''
  mkdir -p $out/bin
  for bin in ${pkg}/bin/*; do
    filename=$(basename "$bin")
    makeWrapper "${pkgs.nixgl.auto.nixGLDefault}/bin/nixGL" "$out/bin/$filename" \
      --add-flags "$bin"
  done
  if [ -d ${pkg}/share ]; then
    cp -r ${pkg}/share $out/share
  fi
''
