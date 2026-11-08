{ writeShellScriptBin }:

writeShellScriptBin "nix-capped" ''
  set -euo pipefail

  if [ $# -eq 0 ]; then
    echo "Uso: nix-capped <comando...>" >&2
    exit 1
  fi

  # In CI environments, run directly without resource caps
  if [ "''${CI:-false}" = "true" ]; then
    exec "$@"
  fi

  # Resource cap settings from environment or default
  CPU_PERCENT="''${CPU_PERCENT:-50}"
  RAM_PERCENT="''${RAM_PERCENT:-50}"
  SWAP_PERCENT="''${SWAP_PERCENT:-20}"
  MAX_RAM_GB="''${MAX_RAM_GB:-}"
  MAX_SWAP_GB="''${MAX_SWAP_GB:-}"

  # Calculate target CPU cores and quota
  CORES=$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
  TARGET_CORES=$(( (CORES * CPU_PERCENT) / 100 ))
  [ "$TARGET_CORES" -lt 1 ] && TARGET_CORES=1
  CPU_QUOTA="$(( CORES * CPU_PERCENT ))%"

  # Calculate RAM limit based on total system memory
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
    MEM_HIGH_BYTES=$(( MEM_LIMIT_BYTES * 85 / 100 ))
    MEM_LIMIT_ARG="MemoryMax=''${MEM_LIMIT_BYTES}"
    MEM_HIGH_ARG="MemoryHigh=''${MEM_HIGH_BYTES}"
    MEM_HUMAN="$(( MEM_LIMIT_BYTES / 1024 / 1024 )) MB (''${RAM_PERCENT}% da RAM do host)"
  else
    MEM_LIMIT_ARG="MemoryMax=''${RAM_PERCENT}%"
    MEM_HIGH_ARG="MemoryHigh=''${RAM_PERCENT}%"
    MEM_HUMAN="''${RAM_PERCENT}% da RAM"
  fi

  # Calculate Swap limit based on total system swap
  TOTAL_SWAP_KB=$(awk '/SwapTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
  if [ "$TOTAL_SWAP_KB" -gt 0 ]; then
    SWAP_CALCULATED_BYTES=$(( TOTAL_SWAP_KB * 1024 * SWAP_PERCENT / 100 ))
    if [ -n "$MAX_SWAP_GB" ]; then
      MAX_SWAP_BYTES=$(( MAX_SWAP_GB * 1024 * 1024 * 1024 ))
      if [ "$SWAP_CALCULATED_BYTES" -gt "$MAX_SWAP_BYTES" ]; then
        SWAP_CALCULATED_BYTES="$MAX_SWAP_BYTES"
      fi
    fi
    SWAP_LIMIT_BYTES="$SWAP_CALCULATED_BYTES"
    SWAP_LIMIT_ARG="MemorySwapMax=''${SWAP_LIMIT_BYTES}"
    SWAP_HUMAN="$(( SWAP_LIMIT_BYTES / 1024 / 1024 )) MB (''${SWAP_PERCENT}% do Swap do host)"
  else
    SWAP_LIMIT_ARG="MemorySwapMax=0"
    SWAP_HUMAN="0 MB (host sem swap)"
  fi

  echo "==> ⚡ Executando com limite de recursos (''${CPU_PERCENT}% CPU, ''${RAM_PERCENT}% RAM e ''${SWAP_PERCENT}% Swap):"
  echo "    • CPU: ''${CPU_PERCENT}% ($TARGET_CORES de $CORES núcleos | Quota: $CPU_QUOTA)"
  echo "    • RAM: $MEM_HUMAN"
  echo "    • Swap: $SWAP_HUMAN"

  export NIX_BUILD_CORES="$TARGET_CORES"

  # Pass computed cores to nix commands
  if [ "$1" = "nix" ]; then
    CMD=(nix --max-jobs "$TARGET_CORES" --cores "$TARGET_CORES" "''${@:2}")
  else
    CMD=("$@")
  fi

  # Check controller delegation in systemd user slice
  USER_UID="''${UID:-$(id -u)}"
  USER_CGROUP_CONTROLLERS="/sys/fs/cgroup/user.slice/user-''${USER_UID}.slice/user@''${USER_UID}.service/cgroup.controllers"
  DELEGATED_CPU=0
  DELEGATED_MEM=0

  if [ -f "$USER_CGROUP_CONTROLLERS" ]; then
    if grep -qw "cpu" "$USER_CGROUP_CONTROLLERS"; then
      DELEGATED_CPU=1
    fi
    if grep -qw "memory" "$USER_CGROUP_CONTROLLERS"; then
      DELEGATED_MEM=1
    fi
  fi

  USE_SYSTEMD=0
  if command -v systemd-run >/dev/null 2>&1 && systemd-run --user --scope true >/dev/null 2>&1; then
    USE_SYSTEMD=1
  fi

  SYSTEMD_ARGS=()
  if [ "$DELEGATED_CPU" -eq 1 ]; then
    SYSTEMD_ARGS+=(-p "CPUQuota=$CPU_QUOTA" -p "CPUWeight=50")
  else
    if [ "$USE_SYSTEMD" -eq 1 ]; then
      echo "⚠️ Aviso: O controlador cgroups 'cpu' não está delegado. Limite de CPU via cgroup será ignorado (usando taskset + nice)." >&2
    fi
  fi

  if [ "$DELEGATED_MEM" -eq 1 ]; then
    SYSTEMD_ARGS+=(-p "$MEM_LIMIT_ARG" -p "$MEM_HIGH_ARG" -p "$SWAP_LIMIT_ARG")
  else
    if [ "$USE_SYSTEMD" -eq 1 ]; then
      echo "⚠️ Aviso: O controlador cgroups 'memory' não está delegado. Limites de RAM e Swap serão ignorados." >&2
    fi
  fi

  if [ "$USE_SYSTEMD" -eq 1 ] && [ "''${#SYSTEMD_ARGS[@]}" -gt 0 ]; then
    # Fallback to taskset inside systemd scope if CPU controller is missing
    if [ "$DELEGATED_CPU" -eq 0 ] && command -v taskset >/dev/null 2>&1 && [ "$CORES" -gt 1 ]; then
      CPULIST="0-$(( TARGET_CORES - 1 ))"
      exec systemd-run --user --scope "''${SYSTEMD_ARGS[@]}" --quiet nice -n 15 taskset -c "$CPULIST" "''${CMD[@]}"
    else
      exec systemd-run --user --scope "''${SYSTEMD_ARGS[@]}" --quiet nice -n 15 "''${CMD[@]}"
    fi
  else
    # Fallback without systemd
    echo "⚠️ Aviso: systemd-run não disponível ou sem controladores delegados. Executando com taskset e nice. Atenção: RAM e Swap NÃO estão limitados neste modo." >&2
    if command -v taskset >/dev/null 2>&1 && [ "$CORES" -gt 1 ]; then
      CPULIST="0-$(( TARGET_CORES - 1 ))"
      exec nice -n 15 taskset -c "$CPULIST" "''${CMD[@]}"
    else
      exec nice -n 15 "''${CMD[@]}"
    fi
  fi
''
