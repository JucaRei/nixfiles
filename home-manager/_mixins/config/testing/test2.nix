{ test ? import ./test.nix, ... }:
with test;
{
  home.file.text = ''
    ${test.name}
  '';
}
