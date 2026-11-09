{ pkgs, lib }:

let
  myLib =
    (import ../../../lib/options.nix { inherit lib; })
    // (import ../../../lib/import-dir.nix { inherit lib; })
    // {
      disk = {
        btrfs = import ../../../lib/disk/btrfs.nix;
      };
      theme = import ../../../modules/home-manager/desktop/theme/lib.nix { inherit lib; };
    };

  extendedLib = lib.extend (
    _self: _super: {
      my = myLib;
    }
  );

  commonArgs = {
    inherit pkgs;
    inputs = { };
    inherit myLib;
    desktop = null;
    hostname = "docs";
    username = "juca";
    waylandShell = "traditional";
    platform = "x86_64-linux";
    stateVersion = "26.05";
    isISO = false;
    isInstall = true;
    isWorkstation = false;
    isVM = false;
    notVM = true;
    hostid = null;
    nixGLWrapper = lib.id;
    nixGLType = null;
    useNixGL = false;
    osConfig = null;
  };

  # Evaluate Home Manager modules in isolation to extract declarations
  evalHM = extendedLib.evalModules {
    modules = [
      ../../../modules/home-manager
      {
        config = {
          _module = {
            check = false;
            args = {
              lib = extendedLib;
              inherit pkgs;
            };
          };
        };
        options.home = {
          keyboard = lib.mkOption {
            default = null;
            type = lib.types.anything;
          };
          homeDirectory = lib.mkOption {
            default = "/home/juca";
            type = lib.types.str;
          };
          username = lib.mkOption {
            default = "juca";
            type = lib.types.str;
          };
        };
      }
    ];
    specialArgs = commonArgs;
  };

  # Evaluate NixOS modules in isolation
  evalNixOS = extendedLib.evalModules {
    modules = [
      ../../../modules/nixos
      {
        config = {
          _module = {
            check = false;
            args = {
              lib = extendedLib;
              inherit pkgs;
            };
          };
        };
      }
    ];
    specialArgs = commonArgs;
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
    v: v.text or (if v ? _type && v._type == "literalExpression" then v.text else builtins.toJSON v);

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
