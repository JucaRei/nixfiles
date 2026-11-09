#!/usr/bin/env bash
set -euo pipefail

# Directory of this script and repository root
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# If arguments are provided:
# - if single argument and it's a directory, use it as ROOT_DIR
# - otherwise treat arguments as list of files to check
FILES=()
if [ $# -eq 1 ] && [ -d "$1" ]; then
  ROOT_DIR="$1"
  for f in "$ROOT_DIR"/home-manager/hosts/*/settings.nix "$ROOT_DIR"/nixos/hosts/*/settings.nix "$ROOT_DIR"/templates/host/settings.nix; do
    [ -f "$f" ] && FILES+=("$f")
  done
elif [ $# -gt 0 ]; then
  for arg in "$@"; do
    [ -f "$arg" ] && FILES+=("$arg")
  done
else
  for f in "$REPO_ROOT"/home-manager/hosts/*/settings.nix "$REPO_ROOT"/nixos/hosts/*/settings.nix "$REPO_ROOT"/templates/host/settings.nix; do
    [ -f "$f" ] && FILES+=("$f")
  done
fi

if [ ${#FILES[@]} -eq 0 ]; then
  echo "⚠️ Nenhum arquivo settings.nix encontrado para verificação." >&2
  exit 0
fi

FAILED=0
FORBIDDEN_REGEX='\blet\b|\bmk[A-Z][a-zA-Z0-9_]*|\blib\.'

for file in "${FILES[@]}"; do
  # Strip comments (single-line # and multiline /* ... */) while preserving lines and strings
  STRIPPED="$(awk '
    BEGIN { in_multiline = 0; }
    {
      line = $0;
      out = "";
      in_string = 0;
      len = length(line);
      i = 1;
      while (i <= len) {
        c = substr(line, i, 1);
        c2 = substr(line, i, 2);
        if (in_multiline) {
          if (c2 == "*/") {
            in_multiline = 0;
            i += 2;
          } else {
            i++;
          }
        } else if (in_string) {
          out = out c;
          if (c == "\\" && i < len) {
            i++;
            out = out substr(line, i, 1);
          } else if (c == "\"") {
            in_string = 0;
          }
          i++;
        } else {
          if (c2 == "/*") {
            in_multiline = 1;
            i += 2;
          } else if (c == "#") {
            break;
          } else {
            if (c == "\"") {
              in_string = 1;
            }
            out = out c;
            i++;
          }
        }
      }
      print out;
    }
  ' "$file")"

  MATCHES="$(printf '%s\n' "$STRIPPED" | grep -nE "$FORBIDDEN_REGEX" || true)"
  if [ -n "$MATCHES" ]; then
    echo "❌ Erro: O arquivo '$file' contém palavras-chave proibidas (let, mk*, lib.):" >&2
    while IFS= read -r match_line; do
      [ -z "$match_line" ] && continue
      LINE_NUM="${match_line%%:*}"
      ORIG_LINE="$(sed -n "${LINE_NUM}p" "$file")"
      echo "   Linha $LINE_NUM: $ORIG_LINE" >&2
    done <<< "$MATCHES"
    FAILED=1
  fi
done

if [ "$FAILED" -ne 0 ]; then
  echo "" >&2
  echo "💡 Dica: Os arquivos settings.nix devem conter apenas atribuições simples (ex: tema, programas, monitores)." >&2
  echo "   Configurações avançadas com 'let', 'lib.' ou 'mk*' devem ficar em 'avancado.nix'." >&2
  exit 1
fi

echo "✔ Todos os arquivos settings.nix são simples e válidos."
exit 0
