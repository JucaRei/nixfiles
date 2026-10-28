#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT_DIR"

nix_files=$(find . -name "*.nix" -not -path "*/.git/*" -not -path "*/result/*" -not -path "*/.snapshots/*")
files_count=$(echo "$nix_files" | wc -l)
lines_count=$(echo "$nix_files" | xargs cat | wc -l)
mkoption_count=$(grep -rn "mkOption" --include="*.nix" --exclude-dir=".git" --exclude-dir=".snapshots" . | wc -l)
mkforce_count=$(grep -rn "mkForce" --include="*.nix" --exclude-dir=".git" --exclude-dir=".snapshots" . | wc -l)
with_pkgs_count=$(grep -rn "with pkgs;" --include="*.nix" --exclude-dir=".git" --exclude-dir=".snapshots" . | wc -l)
rec_count=$(grep -rn "rec {" --include="*.nix" --exclude-dir=".git" --exclude-dir=".snapshots" . | wc -l)

stubs_count=0
while IFS= read -r f; do
  [ -z "$f" ] && continue
  trimmed=$(tr -d '[:space:]' < "$f")
  if [ "$trimmed" = "{}" ] || [ "$trimmed" = "{}:{}" ]; then
    stubs_count=$((stubs_count + 1))
  fi
done <<< "$nix_files"

statix_count=0
if command -v statix >/dev/null 2>&1; then
  statix_count=$(statix check . 2>&1 | grep -c "Warning:" || true)
fi

deadnix_count=0
if command -v deadnix >/dev/null 2>&1; then
  deadnix_count=$(deadnix . 2>&1 | grep -c "Warning:" || true)
fi

echo "=== Métricas do Repositório ==="
echo "Arquivos .nix:      $files_count"
echo "Linhas .nix:        $lines_count"
echo "mkOption:           $mkoption_count"
echo "mkForce:            $mkforce_count"
echo "with pkgs;:         $with_pkgs_count"
echo "rec {:              $rec_count"
echo "Stubs:              $stubs_count"
echo "Avisos statix:      $statix_count"
echo "Avisos deadnix:     $deadnix_count"

