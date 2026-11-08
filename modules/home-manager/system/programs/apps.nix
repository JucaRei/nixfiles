# Easy package installation by string name for CLI and GUI applications.
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
      pkg = pkgs.${name} or (throw "pacote '${name}' não encontrado; procure em search.nixos.org");
    in
    if isGui then nixGLWrapper pkg else pkg;
in
{
  options.my.apps = {
    cli = lib.my.mkListOf lib.types.str [ ] "Lista de programas CLI para instalar pelo nome.";
    gui =
      lib.my.mkListOf lib.types.str [ ]
        "Lista de programas GUI para instalar pelo nome (com aceleração gráfica automática).";
  };

  config = {
    home.packages = (map (resolvePkg false) cfg.cli) ++ (map (resolvePkg true) cfg.gui);
  };
}
