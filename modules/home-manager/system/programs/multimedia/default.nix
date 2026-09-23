# Roteador de imports — cada sub-módulo declara suas próprias options.
# Segue o mesmo padrão de editors/default.nix e browsers/default.nix.
_: {
  imports = [
    ./audio-recorder
    ./mpv
    ./rhythmbox
    ./scrcpy
    ./sonixd
  ];
}
