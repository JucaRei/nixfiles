{ test }:
with test;
{
  home.file.text = ''
    ${test.name}
  '';
}
