{ writeShellScriptBin }:

writeShellScriptBin "nix-check-capped" ''
  set -euo pipefail

  # Detecta quantidade de núcleos no host e calcula 60%
  CORES=$(nproc 2>/dev/null || getconf _NPROCESSORS_ONLN 2>/dev/null || echo 1)
  TARGET_CORES=$(( (CORES * 60) / 100 ))
  [ "$TARGET_CORES" -lt 1 ] && TARGET_CORES=1
  CPU_QUOTA="$(( CORES * 60 ))%"

  # Detecta memória total em KB e calcula 60%
  TOTAL_MEM_KB=$(awk '/MemTotal/ {print $2}' /proc/meminfo 2>/dev/null || echo 0)
  if [ "$TOTAL_MEM_KB" -gt 0 ]; then
    MEM_LIMIT_BYTES=$(( TOTAL_MEM_KB * 1024 * 60 / 100 ))
    MEM_LIMIT_ARG="MemoryMax=''${MEM_LIMIT_BYTES}"
    MEM_HUMAN="$(( TOTAL_MEM_KB * 60 / 100 / 1024 )) MB"
  else
    MEM_LIMIT_ARG="MemoryMax=60%"
    MEM_HUMAN="60%"
  fi

  echo "==> ⚡ Executando 'nix flake check --no-build' limitado a 60% dos recursos:"
  echo "    • CPU: 60% ($TARGET_CORES de $CORES núcleos | Quota cgroups: $CPU_QUOTA)"
  echo "    • RAM: $MEM_HUMAN (60% da memória física do host)"

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
