{
  cfg,
  lib,
  isNouveauOrLegacy,
  hasBlur,
}:
''
  # ==============================================================================
  #  PICOM v12 MODERNO — CONFIGURAÇÃO PURA (CANTOS ARREDONDADOS & FROSTED GLASS)
  # ==============================================================================

  # --- 1. Backend e Renderização ---
  backend = "${cfg.backend}";
  vsync = ${if !isNouveauOrLegacy then "true" else "false"};
  use-damage = ${if cfg.useDamage then "true" else "false"};

  dithered-present = false;
  detect-rounded-corners = true;
  detect-client-opacity = true;
  detect-transient = true;
  detect-client-leader = false;
  use-ewmh-active-win = true;
  unredir-if-possible = false;

  corner-radius = ${toString cfg.cornerRadius};

  # --- 2. Sombras Suaves e Profundas (Deep Soft Elevation) ---
  shadow = ${if cfg.shadows.enable then "true" else "false"};
  shadow-radius = 20;
  shadow-opacity = 0.55;
  shadow-offset-x = -16;
  shadow-offset-y = -16;
  shadow-color = "#000000"; # exceção: sombra preta de compositor

  # --- 3. Transições e Fading Suave ---
  fading = true;
  fade-in-step = 0.038;
  fade-out-step = 0.038;
  fade-delta = ${if isNouveauOrLegacy then "4" else "6"};
  no-fading-openclose = false;
  no-fading-destroyed-argb = false;

  # --- 4. Background Blur Dual-Kawase (Frosted Glass Refinado) ---
  ${lib.optionalString hasBlur ''
    blur: {
      method = "dual_kawase";
      strength = ${toString cfg.blur.strength};
      background = false;
      background-frame = false;
      background-fixed = false;
    };
  ''}

  # --- 5. Regras Declarativas Modernas (Rules v12) ---
  # --- 5. Regras Declarativas Modernas (Rules v12) ---
  ${import ./_picom-rules.nix { inherit cfg lib hasBlur; }}
''
