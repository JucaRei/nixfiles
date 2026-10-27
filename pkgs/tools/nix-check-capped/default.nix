{ writeShellScriptBin }:

writeShellScriptBin "nix-check-capped" ''
  set -euo pipefail

  # Limites de recursos configuráveis via ambiente (padrão: 40% CPU e até metade da RAM física do host)
  CPU_PERCENT="''${CPU_PERCENT:-40}"
  RAM_PERCENT="''${RAM_PERCENT:-50}"
  MAX_RAM_GB="''${MAX_RAM_GB:-}"

  # Detecta quantidade de núcleos no host e calcula quota
  CORES=$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
  TARGET_CORES=$(( (CORES * CPU_PERCENT) / 100 ))
  [ "$TARGET_CORES" -lt 1 ] && TARGET_CORES=1
  CPU_QUOTA="$(( CORES * CPU_PERCENT ))%"

  # Detecta memória total em KB e calcula limite de até metade da RAM física do host (50%)
  TOTAL_MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
  if [ "$TOTAL_MEM_KB" -gt 0 ]; then
    MEM_CALCULATED_BYTES=$(( TOTAL_MEM_KB * 1024 * RAM_PERCENT / 100 ))
    if [ -n "$MAX_RAM_GB" ]; then
      MAX_ALLOWED_BYTES=$(( MAX_RAM_GB * 1024 * 1024 * 1024 ))
      if [ "$MEM_CALCULATED_BYTES" -gt "$MAX_ALLOWED_BYTES" ]; then
        MEM_CALCULATED_BYTES="$MAX_ALLOWED_BYTES"
      fi
    fi
    MEM_LIMIT_BYTES="$MEM_CALCULATED_BYTES"
    MEM_LIMIT_ARG="MemoryMax=''${MEM_LIMIT_BYTES}"
    MEM_HUMAN="$(( MEM_LIMIT_BYTES / 1024 / 1024 )) MB (''${RAM_PERCENT}% da RAM do host)"
  else
    MEM_LIMIT_ARG="MemoryMax=''${RAM_PERCENT}%"
    MEM_HUMAN="''${RAM_PERCENT}% da RAM"
  fi

  echo "==> ⚡ Executando 'nix flake check --no-build' limitado a ''${CPU_PERCENT}% CPU e até ''${RAM_PERCENT}% RAM:"
  echo "    • CPU: ''${CPU_PERCENT}% ($TARGET_CORES de $CORES núcleos | Quota cgroups: $CPU_QUOTA)"
  echo "    • RAM: $MEM_HUMAN"

  # Tenta executar sob cgroups v2 com systemd-run --user para limites rígidos de RAM e CPU
  USE_SYSTEMD=0
  if command -v systemd-run >/dev/null 2>&1 && systemd-run --user --scope true >/dev/null 2>&1; then
    USE_SYSTEMD=1
  fi

  if [ "$USE_SYSTEMD" -eq 1 ]; then
    exec systemd-run --user --scope \
      -p CPUQuota="$CPU_QUOTA" \
      -p "$MEM_LIMIT_ARG" \
      --quiet \
      nix flake check --no-build --max-jobs "$TARGET_CORES" --cores "$TARGET_CORES" "$@"
  else
    # Fallback sem systemd: taskset para afinidade de núcleos de CPU + nice
    if command -v taskset >/dev/null 2>&1 && [ "$CORES" -gt 1 ]; then
      CPULIST="0-$(( TARGET_CORES - 1 ))"
      exec nice -n 10 taskset -c "$CPULIST" nix flake check --no-build --max-jobs "$TARGET_CORES" --cores "$TARGET_CORES" "$@"
    else
      exec nice -n 10 nix flake check --no-build --max-jobs "$TARGET_CORES" --cores "$TARGET_CORES" "$@"
    fi
  fi
''
