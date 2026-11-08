# What it is: Simple package installer for CLI and GUI applications by name.
# How to enable: Set `my.apps.cli = [ "..." ];` or `my.apps.gui = [ "..." ];` in settings.nix.
# Example: my.apps.cli = [ "htop" "ripgrep" ]; my.apps.gui = [ "firefox" ];
{
  config,
  lib,
  pkgs,
  nixGLWrapper ? lib.id,
  ...
}:

let
  cfg = config.my.apps;

  # Resolve package attribute from nixpkgs with user-friendly error message
  resolvePkg =
    isGui: name:
    let
      pkg =
        pkgs.${name}
          or (throw "O pacote '${name}' não foi encontrado no Nixpkgs. Procure o nome correto com: ./scripts/nx search ${name} (ou em search.nixos.org).");
    in
    if isGui then nixGLWrapper pkg else pkg;
in
{
  options.my.apps = {
    cli = lib.my.mkListOfEx lib.types.str [ ] "Lista de programas CLI para instalar pelo nome." [
      "htop"
      "ripgrep"
    ];
    gui =
      lib.my.mkListOfEx lib.types.str [ ]
        "Lista de programas GUI para instalar pelo nome (com aceleração gráfica automática)."
        [
          "firefox"
          "vlc"
        ];
  };

  config = {
    home.packages = (map (resolvePkg false) cfg.cli) ++ (map (resolvePkg true) cfg.gui);
  };
}
