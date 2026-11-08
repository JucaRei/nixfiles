{ pkgs, lib }:

let
  # Evaluate Home Manager modules in isolation to extract declarations
  evalHM = lib.evalModules {
    modules = [
      ../../../modules/home-manager
      { _module.check = false; }
    ];
    specialArgs = {
      inputs = { };
      myLib = import ../../../lib/options.nix { inherit lib; };
      nixGLWrapper = lib.id;
      osConfig = null;
    };
  };

  # Evaluate NixOS modules in isolation
  evalNixOS = lib.evalModules {
    modules = [
      ../../../modules/nixos
      { _module.check = false; }
    ];
    specialArgs = {
      inputs = { };
      myLib = import ../../../lib/options.nix { inherit lib; };
    };
  };

  # Recursively collect options into a flat list
  flattenOptions =
    prefix: set:
    lib.concatLists (
      lib.mapAttrsToList (
        name: value:
        let
          fullName = if prefix == "" then name else "${prefix}.${name}";
        in
        if lib.isOption value then
          [
            {
              inherit fullName;
              opt = value;
            }
          ]
        else if builtins.isAttrs value && !(value ? _type && value._type == "derivation") then
          flattenOptions fullName value
        else
          [ ]
      ) set
    );

  # Only document our custom namespaces declared in this repository
  customHMOptions =
    (flattenOptions "desktop" (evalHM.options.desktop or { }))
    ++ (flattenOptions "system" (evalHM.options.system or { }))
    ++ (flattenOptions "my" (evalHM.options.my or { }));

  customNixOSOptions =
    (flattenOptions "desktop" (evalNixOS.options.desktop or { }))
    ++ (flattenOptions "system" (evalNixOS.options.system or { }))
    ++ (flattenOptions "my" (evalNixOS.options.my or { }));

  # Merge and deduplicate option list by full name
  allOptions = lib.sort (a: b: a.fullName < b.fullName) (
    lib.foldl' (
      acc: item: if lib.any (x: x.fullName == item.fullName) acc then acc else acc ++ [ item ]
    ) [ ] (customHMOptions ++ customNixOSOptions)
  );

  escapePipes = s: lib.replaceStrings [ "|" "\n" "`" ] [ "\\|" " " "'" ] (builtins.toString s);

  formatValue =
    v:
    v.text or (
      if v ? _type && v._type == "literalExpression" then v.text else builtins.toJSON v
    );

  renderRow =
    { fullName, opt }:
    let
      typeName = escapePipes (opt.type.description or "any");
      defaultVal = if opt ? default then escapePipes (formatValue opt.default) else "-";
      desc =
        if opt ? description then
          escapePipes (
            if builtins.isAttrs opt.description then (opt.description.text or "") else opt.description
          )
        else
          "-";
    in
    "| `${fullName}` | ${typeName} | `${defaultVal}` | ${desc} |";

  header = ''
    # Catálogo Declarativo de Opções (OPTIONS.md)

    Este documento lista as opções customizadas dos namespaces `desktop.*`, `system.*` e `my.*` declaradas neste repositório.

    | Caminho | Tipo | Padrão | Descrição |
    |:---|:---|:---|:---|
  '';

  rows = map renderRow allOptions;
  content = header + (lib.concatStringsSep "\n" rows) + "\n";
in
pkgs.writeTextDir "share/doc/nixfiles/OPTIONS.md" content
