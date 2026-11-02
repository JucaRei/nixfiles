{
  config,
  lib,
  pkgs,
  osConfig ? null,
  nixGLWrapper ? lib.id,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.desktop.shared.picom;

  isNixOS = osConfig != null;
  gpuDriver = if isNixOS then (osConfig.hardware.graphics.cards.gpu or "generic") else "generic";
  isNvidiaLegacy = gpuDriver == "nvidia-legacy";
  isNouveauOrLegacy = isNvidiaLegacy || gpuDriver == "nouveau";
  hasBlur = cfg.blur.enable && (!isNouveauOrLegacy) && (cfg.backend != "xrender");
  picomPkg = nixGLWrapper pkgs.picom;
in
{
  options.desktop.shared.picom = {
    enable = lib.my.mkBool false "Habilitar compositor Picom compartilhado para X11 (BSPWM, DWM, etc.).";

    environment = lib.my.mkEnum [
      "bspwm"
      "dwm"
      "generic"
    ] "generic" "Perfil de ambiente desktop para regras e animações específicas de janela.";

    backend =
      lib.my.mkEnum
        [
          "xrender"
          "glx"
          "egl"
        ]
        (if isNouveauOrLegacy then "xrender" else "glx")
        "Backend de renderização do Picom (glx para aceleração por GPU, xrender para VMs/legado)";

    cornerRadius = lib.my.mkInt (
      if isNouveauOrLegacy then 10 else 16
    ) "Raio dos cantos arredondados das janelas em pixels";

    activeOpacity =
      lib.my.mkOpt (lib.types.numbers.between 0.0 1.0) 1.0
        "Opacidade das janelas ativas em foco (1.0 = totalmente opaco)";

    inactiveOpacity =
      lib.my.mkOpt (lib.types.numbers.between 0.0 1.0) 0.97
        "Opacidade das janelas inativas/desfocadas";

    blur = {
      enable = lib.my.mkBool (
        !isNouveauOrLegacy && cfg.backend != "xrender"
      ) "Habilitar blur de fundo dual_kawase (requer backend glx/egl e GPU compatível)";

      strength = lib.my.mkInt 7 "Intensidade do blur Dual-Kawase (1-20)";
    };

    animations = {
      enable = lib.my.mkBool (
        !isNouveauOrLegacy
      ) "Habilitar animações modernas suaves de janela no picom";
    };

    shadows = {
      enable = lib.my.mkBool true "Habilitar sombras de janela no picom";
    };

    useDamage = lib.my.mkBool isNouveauOrLegacy "Repintar apenas regiões modificadas da tela (economia em legado/VM)";
  };

  config = mkIf cfg.enable {
    home.packages = [ picomPkg ];

    # Recarregar automaticamente o compositor Picom ao rodar switch-home
    home.activation.reloadPicom = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD systemctl --user restart picom 2>/dev/null || ${pkgs.procps}/bin/pkill -USR1 -x picom 2>/dev/null || (${pkgs.procps}/bin/pkill -x picom 2>/dev/null && sleep 0.2 && ${picomPkg}/bin/picom -b 2>/dev/null || true)
    '';

    # Configuração declarativa libconfig v12 moderna
    xdg.configFile."picom/picom.conf".text = import ./_picom-template.nix {
      inherit
        cfg
        lib
        isNouveauOrLegacy
        hasBlur
        ;
    };

    # Serviço systemd do usuário gerenciando o Picom
    systemd.user.services.picom = {
      Unit = {
        Description = "Picom X11 compositor";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
      };
      Service = {
        ExecStart = "${picomPkg}/bin/picom";
        Restart = "on-failure";
        RestartSec = 2;
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
