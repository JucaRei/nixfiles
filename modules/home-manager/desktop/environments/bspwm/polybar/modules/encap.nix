{
  lib,
  colors,
  customGlyphColor,
  currentEncap,
  ...
}:
let
  colorList = [
    "pill"
    "pill-alt"
    "pill-active"
    "red"
    "orange"
    "yellow"
    "green"
    "teal"
    "cyan"
    "blue"
    "purple"
    "pink"
    "accent"
    "ice"
    "coral"
    "mint"
    "nord"
    "dark"
    "surface0"
    "surface1"
    "surface2"
    "shade1"
    "shade2"
    "shade3"
    "shade4"
    "shade5"
    "shade6"
    "shade7"
    "shade8"
  ];

  mkColoredEncapModules = lib.foldl' (
    acc: cName:
    let
      cVal = colors.${cName} or colors.pill;
    in
    acc
    // {
      "module/shape-left-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/shape-right-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/round-left-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/round-right-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/slant-left-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/slant-right-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/powerline-left-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/powerline-right-${cName}" = {
        type = "custom/text";
        format = "<label>";
        label = "%{T5}%{T-}";
        label-foreground = cVal;
      };
      "module/sp-${cName}" = {
        type = "custom/text";
        format = "<label>";
        format-background = cVal;
        label = " ";
        label-background = cVal;
      };
    }
  ) { } colorList;

  baseEncapModules = {
    # --- Encapsulamento Dinâmico (pill, shapes, slant, powerline) ---
    "module/encap-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}${currentEncap.left}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/encap-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}${currentEncap.right}%{T-}";
      label-foreground = customGlyphColor;
    };

    # Aliases de cápsula arredondada (pill)
    "module/round-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/round-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/bi" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/bd" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    # Módulos explícitos com glifos fixos
    "module/pill-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/pill-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/shape-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/shape-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/shapes-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/shapes-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    # Estilo Slant / Diagonal Paralelo
    "module/slant-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/slant-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/slant-down-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/slant-down-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/slant-up-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/slant-up-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    # Estilo Powerline
    "module/powerline-left" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    "module/powerline-right" = {
      type = "custom/text";
      format = "<label>";
      label = "%{T5}%{T-}";
      label-foreground = customGlyphColor;
    };

    # Módulos de Transição Sombreada Estilo Shapes
    "module/left1" = {
      type = "custom/text";
      format = "<label>";
      format-background = colors.shade2;
      format-foreground = colors.shade1;
      label = "%{T5}%{T-}";
    };

    "module/left2" = {
      type = "custom/text";
      format = "<label>";
      format-background = colors.shade3;
      format-foreground = colors.shade2;
      label = "%{T5}%{T-}";
    };

    "module/left3" = {
      type = "custom/text";
      format = "<label>";
      format-background = colors.dark;
      format-foreground = colors.shade3;
      label = "%{T5}%{T-}";
    };

    "module/left4" = {
      type = "custom/text";
      format = "<label>";
      format-background = colors.dark;
      format-foreground = colors.shade4;
      label = "%{T5}%{T-}";
    };

    "module/right1" = {
      type = "custom/text";
      format = "<label>";
      format-background = colors.shade2;
      format-foreground = colors.shade1;
      label = "%{T5}%{T-}";
    };

    "module/right2" = {
      type = "custom/text";
      format = "<label>";
      format-background = colors.shade3;
      format-foreground = colors.shade2;
      label = "%{T5}%{T-}";
    };

    "module/right3" = {
      type = "custom/text";
      format = "<label>";
      format-background = colors.shade4;
      format-foreground = colors.shade3;
      label = "%{T5}%{T-}";
    };

    "module/right4" = {
      type = "custom/text";
      format = "<label>";
      format-background = colors.dark;
      format-foreground = colors.shade4;
      label = "%{T5}%{T-}";
    };

    "module/sp" = {
      type = "custom/text";
      format = "<label>";
      label = " ";
    };

    "module/sp-pill" = {
      type = "custom/text";
      format = "<label>";
      format-background = customGlyphColor;
      label = " ";
      label-background = customGlyphColor;
    };

    "module/space" = {
      type = "custom/text";
      format = "<label>";
      label = " ";
    };
  };
in
baseEncapModules // mkColoredEncapModules
