{
  config,
  lib,
  ...
}:
let
  encapStyleEnum = [
    "pill"
    "shapes"
    "slant"
    "powerline"
  ];

  encapStyleWithDefaultEnum = [ "default" ] ++ encapStyleEnum;

  # Submódulo flexível para cada cápsula: aceita string de estilo ou attrset com { style, color, accent }
  mkEncapModuleType =
    {
      defaultStyle ? "default",
      allowDefault ? true,
      ...
    }:
    let
      validStyles = if allowDefault then encapStyleWithDefaultEnum else encapStyleEnum;
      submoduleType = lib.types.submodule {
        options = {
          style =
            lib.my.mkEnum validStyles defaultStyle
              "Estilo geométrico do encapsulamento ('pill', 'shapes', 'slant', 'powerline'${
                if allowDefault then ", ou 'default' para herdar" else ""
              })";

          color =
            lib.my.mkOpt (lib.types.nullOr lib.types.str) null
              "Cor de fundo da cápsula e de seus glifos delimitadores (nome da paleta ou HEX direto)";

          accent =
            lib.my.mkOpt (lib.types.nullOr lib.types.str) null
              "Cor de destaque dos ícones, textos ativos ou elementos de destaque dentro da cápsula";
        };
      };
    in
    lib.types.coercedTo (lib.types.enum validStyles) (val: {
      style = val;
      color = null;
      accent = null;
    }) submoduleType;
in
{
  options.desktop.bspwm.polybar = {
    enable = lib.my.mkBool config.desktop.bspwm.enable "Habilitar Polybar modular para BSPWM";

    style =
      lib.my.mkEnum
        [
          "modern"
          "zproger"
          "pills"
          "shapes"
        ]
        "zproger"
        "Estilo visual da Polybar: 'zproger'/'pills' (cápsulas flutuantes), 'shapes' (blocos de pixel) ou 'modern' (estilo Waybar / Catppuccin coeso)";

    encapsulation =
      lib.my.mkOpt
        (lib.types.coercedTo (lib.types.enum encapStyleEnum)
          (val: {
            default = {
              style = val;
              color = null;
              accent = null;
            };
            workspaces = "default";
            stats = "default";
            netspeed = "default";
            date = "default";
            tray = "default";
            color = null;
            accent = null;
            colors = { };
          })
          (
            lib.types.submodule {
              options = {
                default = lib.my.mkOpt (mkEncapModuleType
                  {
                    defaultStyle = "pill";
                    allowDefault = false;
                    description = "Encapsulamento padrão herdado por todas as cápsulas";
                  }
                ) "pill" "Encapsulamento padrão herdado por todas as cápsulas (string ou { style, color, accent })";

                workspaces =
                  lib.my.mkOpt
                    (mkEncapModuleType {
                      defaultStyle = "default";
                      allowDefault = true;
                      description = "Encapsulamento da cápsula de workspaces";
                    })
                    "default"
                    "Encapsulamento específico da cápsula de workspaces (string ou { style, color, accent })";

                stats =
                  lib.my.mkOpt
                    (mkEncapModuleType {
                      defaultStyle = "default";
                      allowDefault = true;
                      description = "Encapsulamento da cápsula de métricas/hardware (cpu, ram, temp, disk)";
                    })
                    "default"
                    "Encapsulamento específico da cápsula de métricas/hardware (string ou { style, color, accent })";

                netspeed =
                  lib.my.mkOpt
                    (mkEncapModuleType {
                      defaultStyle = "default";
                      allowDefault = true;
                      description = "Encapsulamento da cápsula de velocidade de rede (netspeed)";
                    })
                    "default"
                    "Encapsulamento específico da cápsula de velocidade de rede (string ou { style, color, accent })";

                date =
                  lib.my.mkOpt
                    (mkEncapModuleType {
                      defaultStyle = "default";
                      allowDefault = true;
                      description = "Encapsulamento da cápsula de data/relógio";
                    })
                    "default"
                    "Encapsulamento específico da cápsula de data/relógio (string ou { style, color, accent })";

                tray = lib.my.mkOpt (mkEncapModuleType {
                  defaultStyle = "default";
                  allowDefault = true;
                  description = "Encapsulamento da cápsula da bandeja (stalonetray)";
                }) "default" "Encapsulamento específico da cápsula da bandeja (string ou { style, color, accent })";

                color =
                  lib.my.mkOpt (lib.types.nullOr lib.types.str) null
                    "Cor de fundo padrão global para todas as cápsulas (nome da paleta ou HEX direto com ou sem '#')";

                accent =
                  lib.my.mkOpt (lib.types.nullOr lib.types.str) null
                    "Cor de destaque padrão global para todas as cápsulas (nome da paleta ou HEX direto com ou sem '#')";

                colors =
                  lib.my.mkOpt (lib.types.attrsOf (lib.types.either lib.types.str (lib.types.nullOr lib.types.str)))
                    { }
                    "Cores customizadas opcionais para glifos, fundos e destaques das cápsulas (detalhes em polybar/AGENTS.md)";
              };
            }
          )
        )
        "pill"
        "Formato de encapsulamento e estilização de cores e destaques das cápsulas (detalhes e sintaxe em polybar/AGENTS.md)";

    battery = lib.my.mkStr "BAT0" "Nome do dispositivo da bateria em /sys/class/power_supply";

    adapter = lib.my.mkStr "ADP1" "Nome do adaptador AC em /sys/class/power_supply";

    tray = {
      enable = lib.my.mkBool false "Habilitar módulo e serviço de bandeja do sistema (Stalonetray) na Polybar";
    };
  };
}
