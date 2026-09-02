# Roteador de imports — cada sub-módulo declara suas próprias options.
# Segue o mesmo padrão de editors/default.nix e browsers/default.nix.
_: {
  imports = [
    ./mpv
    ./rhythmbox
  ];
}
