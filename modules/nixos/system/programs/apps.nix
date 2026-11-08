# Easy package installation by string name on NixOS system level.
{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.my.apps;

  # Resolve package attribute from nixpkgs with user-friendly error message
  resolvePkg =
    name: pkgs.${name} or (throw "pacote '${name}' não encontrado; procure em search.nixos.org");
in
{
  options.my.apps = {
    cli = lib.my.mkListOf lib.types.str [ ] "Lista de programas CLI para instalar pelo nome.";
    gui = lib.my.mkListOf lib.types.str [ ] "Lista de programas GUI para instalar pelo nome.";
  };

  config = {
    environment.systemPackages = (map resolvePkg cfg.cli) ++ (map resolvePkg cfg.gui);
  };
}
