{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (lib)
    mkEnableOption
    mkIf
    ;
  cfg = config.system.programs.tools.fastfetch;
  shouldInstall = cfg.installPackage && !cfg.useSystemPackage && !cfg.useSystemPackages;

  defaultModules = [
    "title"
    "separator"
    "os"
    "host"
    "kernel"
    "uptime"
    "packages"
    "shell"
    "display"
    "de"
    "wm"
    "wmtheme"
    "theme"
    "icons"
    "font"
    "cursor"
    "terminal"
    "terminalfont"
    "cpu"
    "gpu"
    "memory"
    "swap"
    "disk"
    "localip"
    "battery"
    "poweradapter"
    "locale"
    "break"
    "colors"
  ];
in
{
  options.system.programs.tools.fastfetch = {
    enable = mkEnableOption "Enable Fastfetch system information fetch tool with custom display modules.";

    package = lib.my.mkPkg pkgs.fastfetch "Pacote do Fastfetch a ser utilizado.";

    installPackage = lib.my.mkBool true ''
      Se deve instalar o executável do fastfetch via Nix.
      Se false, apenas a configuração (~/.config/fastfetch/config.jsonc) será gerenciada, utilizando o binário nativo da distro hospedeira.
    '';

    useSystemPackage = lib.my.mkBool false "Atalho conveniente: quando true, equivale a installPackage = false.";

    useSystemPackages = lib.my.mkBool false "Alias para useSystemPackage.";

    modules =
      lib.my.mkListOf (lib.types.either lib.types.str lib.types.attrs) defaultModules
        "Lista declarativa de módulos a serem exibidos no Fastfetch (baseado na suíte do LambBread).";

    logo = lib.my.mkOpt lib.types.attrs { } "Configurações de logo do Fastfetch.";

    display =
      lib.my.mkOpt lib.types.attrs { }
        "Configurações visuais de exibição (display) do Fastfetch.";

    extraSettings =
      lib.my.mkOpt lib.types.attrs { }
        "Configurações adicionais mescladas ao config.jsonc gerado pelo Home Manager.";
  };

  config = mkIf cfg.enable {
    programs.fastfetch = {
      enable = true;
      package = if shouldInstall then cfg.package else pkgs.emptyDirectory;
      settings = lib.mkMerge [
        {
          "$schema" = "https://github.com/fastfetch-cli/fastfetch/raw/dev/doc/json_schema.json";
          inherit (cfg) modules;
        }
        (lib.optionalAttrs (cfg.logo != { }) {
          inherit (cfg) logo;
        })
        (lib.optionalAttrs (cfg.display != { }) {
          inherit (cfg) display;
        })
        cfg.extraSettings
      ];
    };

    # Compatibilidade com chamadas manuais como `fastfetch --preset default`
    xdg.configFile."fastfetch/presets/default.jsonc".source =
      config.xdg.configFile."fastfetch/config.jsonc".source;
  };
}
