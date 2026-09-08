{
  pkgs,
  colors,
  ...
}:
{
  # --- Script de Rede Dinâmico e Otimizado ---
  networkScript = pkgs.writeShellScript "polybar-network" ''
    export PATH="${pkgs.networkmanager}/bin:${pkgs.iproute2}/bin:${pkgs.gnugrep}/bin:${pkgs.gawk}/bin:$PATH"

    # Verificar conexão ativa via nmcli de forma instantânea
    active_con=$(nmcli -t -f TYPE,STATE,CONNECTION device 2>/dev/null | grep ":connected:")
    if [ -n "$active_con" ]; then
      type=$(echo "$active_con" | head -n1 | cut -d: -f1)
      name=$(echo "$active_con" | head -n1 | cut -d: -f3)

      if [ "$type" = "wifi" ]; then
        # Obter sinal Wi-Fi
        signal=$(nmcli -t -f IN-USE,SIGNAL device wifi 2>/dev/null | grep '^\*' | cut -d: -f2)
        [ -z "$signal" ] && signal=0
        if [ "$signal" -ge 70 ]; then
          icon="󰤨"
        elif [ "$signal" -ge 40 ]; then
          icon="󰤥"
        elif [ "$signal" -ge 20 ]; then
          icon="󰤢"
        else
          icon="󰤟"
        fi
        echo "%{F${colors.lavender}}$icon%{F-} %{F${colors.text}}$name%{F-}"
        exit 0
      elif [ "$type" = "ethernet" ]; then
        echo "%{F${colors.lavender}}󰈀%{F-} %{F${colors.text}}Cabo%{F-}"
        exit 0
      fi
    fi

    echo "%{F${colors.red}}󰤭%{F-} %{F${colors.subtext0}}Offline%{F-}"
  '';

  # --- Menu de Energia Rofi ---
  powerMenuScript = pkgs.writeShellScript "polybar-powermenu" ''
    chosen=$(printf "󰌾 Bloquear\n󰤄 Suspender\n󰍃 Encerrar Sessão\n󰑐 Reiniciar\n󰐥 Desligar" | ${pkgs.rofi}/bin/rofi -dmenu -p " 󰐥 Energia " -theme-str 'window {width: 320px; height: 320px;} listview {columns: 1; lines: 5;}')
    case "$chosen" in
      *"Bloquear")
        if command -v ${pkgs.betterlockscreen}/bin/betterlockscreen >/dev/null 2>&1; then
          ${pkgs.betterlockscreen}/bin/betterlockscreen -l
        elif command -v ${pkgs.xlockmore}/bin/xlock >/dev/null 2>&1; then
          ${pkgs.xlockmore}/bin/xlock
        else
          pkill -u $USER -x xscreensaver || true
        fi
        ;;
      *"Suspender") systemctl suspend ;;
      *"Encerrar Sessão") ${pkgs.bspwm}/bin/bspc quit ;;
      *"Reiniciar") systemctl reboot ;;
      *"Desligar") systemctl poweroff ;;
    esac
  '';
}
