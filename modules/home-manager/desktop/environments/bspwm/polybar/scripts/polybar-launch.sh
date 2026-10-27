#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

MY_PID=$$

    # 1. Prevenir concorrência entre invocações simultâneas via lock (flock)
    LOCK_FILE="/tmp/polybar-launch.lock"
    exec 200>"$LOCK_FILE"
    if ! flock -n 200; then
      flock -w 3 200 || exit 0
    fi

    # 2. Debounce: se a Polybar real já estiver ativa e foi iniciada há menos de 1s, sai
    LAST_RUN_FILE="/tmp/.polybar-last-launch"
    now=$(date +%s)
    if [ -f "$LAST_RUN_FILE" ]; then
      last_run=$(cat "$LAST_RUN_FILE" 2>/dev/null || echo 0)
      if [ $((now - last_run)) -lt 1 ]; then
        if pgrep -u "$UID" -x "polybar" >/dev/null 2>&1 || \
           pgrep -u "$UID" -x ".polybar-wrapped" >/dev/null 2>&1 || \
           pgrep -u "$UID" -f "polybar.*--reload" >/dev/null 2>&1; then
          flock -u 200
          exec 200>&-
          exit 0
        fi
      fi
    fi

    # 3. Limpar cache de estado, arquivos temporários e sockets IPC da Polybar
    rm -f /tmp/.polybar-netspeed-cache 2>/dev/null || true
    rm -f /tmp/polybar_redshift_* 2>/dev/null || true
    rm -f /tmp/polybar_mqueue.* 2>/dev/null || true
    rm -rf /tmp/polybar-*.log 2>/dev/null || true
    rm -rf /tmp/polybar-*.sock 2>/dev/null || true
    [ -n "${XDG_RUNTIME_DIR:-}" ] && rm -rf "$XDG_RUNTIME_DIR"/polybar*.sock 2>/dev/null || true
    rm -rf "$HOME/.cache/polybar" 2>/dev/null || true

    # 4. Encerrar instâncias anteriores da Polybar (NUNCA matando o próprio polybar-launch)
    polybar-msg cmd quit 2>/dev/null || true
    pkill -u "$UID" -x "polybar" 2>/dev/null || true
    pkill -u "$UID" -x ".polybar-wrapped" 2>/dev/null || true
    pkill -u "$UID" -f "polybar.*--reload" 2>/dev/null || true

    # Matar quaisquer outros processos do polybar (excluindo explicitamente este script)
    for p in $(pgrep -u "$UID" -f "polybar" 2>/dev/null); do
      if [ "$p" != "$MY_PID" ] && ! grep -q "polybar-launch" "/proc/$p/cmdline" 2>/dev/null; then
        kill -15 "$p" 2>/dev/null || true
      fi
    done

    # Aguardar até 0.5s para que processos e janelas X11 sejam liberados
    wait_count=0
    while [ "$wait_count" -lt 5 ]; do
      active_pids=0
      for p in $(pgrep -u "$UID" -f "polybar" 2>/dev/null); do
        if [ "$p" != "$MY_PID" ] && ! grep -q "polybar-launch" "/proc/$p/cmdline" 2>/dev/null; then
          active_pids=1
          break
        fi
      done
      [ "$active_pids" -eq 0 ] && break
      sleep 0.1
      wait_count=$((wait_count + 1))
    done

    # Forçar término de processos rebeldes da Polybar se ainda restarem
    for p in $(pgrep -u "$UID" -f "polybar" 2>/dev/null); do
      if [ "$p" != "$MY_PID" ] && ! grep -q "polybar-launch" "/proc/$p/cmdline" 2>/dev/null; then
        kill -9 "$p" 2>/dev/null || true
      fi
    done

    # 5. Sincronizar detecção de telas e layout multi-monitor
    if command -v xrandr >/dev/null 2>&1; then
      export _POLYBAR_LAUNCHING=1

      # Se nenhum monitor primário estiver configurado e houver setup-monitors, sincroniza o layout
      if ! xrandr --query 2>/dev/null | grep -q " connected primary"; then
        if command -v setup-monitors >/dev/null 2>&1; then
          setup-monitors 2>/dev/null || true
        fi
      fi

      # Identificar saídas ativas com resolução configurada (evita saídas fantasmas)
      active_mons=($(xrandr --query 2>/dev/null | awk '/ connected/ && /[0-9]+x[0-9]+\+[0-9]+\+[0-9]+/ {print $1}'))
      [ ${#active_mons[@]} -eq 0 ] && active_mons=($(xrandr --query 2>/dev/null | awk '/ connected/ {print $1}'))

      # Identificar monitor primário de forma determinística
      primary_mon=$(xrandr --query 2>/dev/null | awk '/ connected primary/ {print $1}')
      [ -z "$primary_mon" ] && command -v bspc >/dev/null 2>&1 && primary_mon=$(bspc query -M -m primary --names 2>/dev/null || true)
      [ -z "$primary_mon" ] && [ ${#active_mons[@]} -gt 0 ] && primary_mon="${active_mons[0]}"

      mon_count=${#active_mons[@]}

      # Atualizar timestamp de inicialização e liberar lock antes do spawn em background
      echo "$(date +%s)" > "$LAST_RUN_FILE"
      flock -u 200
      exec 200>&-

      if [ "$mon_count" -gt 1 ]; then
        # Multi-Monitor: Barra 1 (primary) no monitor principal e Barra 2 (secondary) nas demais telas
        for m in "${active_mons[@]}"; do
          if [ "$m" = "$primary_mon" ]; then
            MONITOR=$m polybar --reload primary &
          else
            MONITOR=$m polybar --reload secondary &
          fi
        done
      elif [ "$mon_count" -eq 1 ]; then
        # Monitor Único: Barra completa com todos os módulos essenciais
        MONITOR="$primary_mon" polybar --reload main &
      else
        polybar --reload main &
      fi
    else
      echo "$(date +%s)" > "$LAST_RUN_FILE"
      flock -u 200
      exec 200>&-
      polybar --reload main &
    fi
