{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf;
  cfg = config.system.programs.shells;
  fzfCfg = cfg.fzf;

  # Script inteligente de preview para fzf
  fzfPreview = pkgs.writeShellScriptBin "fzf-preview" ''
    set -euo pipefail
    target="''${1:-}"

    if [ -z "$target" ]; then
      echo "Nenhum arquivo ou diretório especificado."
      exit 0
    fi

    # Diretório -> árvore visual com eza
    if [ -d "$target" ]; then
      ${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons "$target" 2>/dev/null | head -n 200
      exit 0
    fi

    # Arquivo não existe
    if [ ! -e "$target" ]; then
      echo "Arquivo ou diretório inexistente: $target"
      exit 0
    fi

    # Arquivos compactados / archives
    case "$target" in
      *.tar.gz|*.tgz)   tar -ztvf "$target" 2>/dev/null | head -n 100; exit 0 ;;
      *.tar.bz2|*.tbz2) tar -jtvf "$target" 2>/dev/null | head -n 100; exit 0 ;;
      *.tar.xz|*.txz)   tar -Jtvf "$target" 2>/dev/null | head -n 100; exit 0 ;;
      *.tar)            tar -tvf "$target" 2>/dev/null | head -n 100; exit 0 ;;
      *.zip)            ${pkgs.unzip}/bin/unzip -l "$target" 2>/dev/null | head -n 100; exit 0 ;;
    esac

    # Detecção por tipo MIME
    mime=$(${pkgs.file}/bin/file --mime-type -bL "$target" 2>/dev/null || echo "")

    case "$mime" in
      text/*|application/json|application/xml|application/javascript|application/x-sh|application/x-shellscript|application/x-yaml|application/toml)
        ${pkgs.bat}/bin/bat --style=numbers,changes --color=always --line-range :500 "$target" 2>/dev/null || head -n 500 "$target"
        ;;
      image/*)
        echo "🖼  Arquivo de imagem: $target"
        ${pkgs.file}/bin/file -b "$target" 2>/dev/null || true
        ;;
      *)
        if ${pkgs.bat}/bin/bat --style=numbers,changes --color=always --line-range :500 "$target" 2>/dev/null; then
          :
        else
          echo "📦 Binário / Dados: $target"
          ${pkgs.file}/bin/file -b "$target" 2>/dev/null || true
        fi
        ;;
    esac
  '';

  # Utilitário fif (Fuzzy Ripgrep): busca interativa dentro de arquivos e abre no $EDITOR na linha exata
  fifScript = pkgs.writeShellScriptBin "fif" ''
    if [ "$#" -eq 0 ]; then
      echo "Uso: fif <termo de busca>"
      exit 1
    fi

    pattern="$*"
    selection=$(${pkgs.ripgrep}/bin/rg --column --line-number --no-heading --color=always --smart-case "$pattern" 2>/dev/null | \
      ${pkgs.fzf}/bin/fzf --ansi \
          --delimiter : \
          --preview '${pkgs.bat}/bin/bat --style=numbers --color=always --highlight-line {2} {1} 2>/dev/null' \
          --preview-window 'right:60%:wrap' \
          --prompt "🔍 $pattern > " || true)

    if [ -n "$selection" ]; then
      file=$(echo "$selection" | cut -d: -f1)
      line=$(echo "$selection" | cut -d: -f2)
      ''${EDITOR:-nano} "+$line" "$file"
    fi
  '';

  # Utilitário fkill: mata processos interativamente com preview de detalhes
  fkillScript = pkgs.writeShellScriptBin "fkill" ''
    sig="''${1:-9}"
    pid=$(ps -u "$UID" -o pid,%cpu,%mem,time,comm 2>/dev/null | sed 1d | \
      ${pkgs.fzf}/bin/fzf -m \
          --header 'Selecione com TAB (múltiplos) ou navegue e aperte ENTER para finalizar' \
          --preview 'ps -fp {1} 2>/dev/null' \
          --preview-window 'down:3:wrap' \
          --prompt '󰅙 Kill > ' | awk '{print $1}' || true)

    if [ -n "$pid" ]; then
      echo "$pid" | xargs kill -"$sig" 2>/dev/null || true
      echo "Processo(s) $pid finalizado(s) com sinal -$sig."
    fi
  '';

  # Utilitário fpreview: abre arquivo selecionado com fzf no editor padrão
  fpreviewScript = pkgs.writeShellScriptBin "fpreview" ''
    target="''${1:-}"
    if [ -z "$target" ]; then
      target=$(${pkgs.fd}/bin/fd --type f --hidden --exclude .git --exclude .cache 2>/dev/null | \
        ${pkgs.fzf}/bin/fzf \
            --preview '${fzfPreview}/bin/fzf-preview {}' \
            --preview-window 'right:65%:wrap' \
            --prompt '📄 Arquivo > ' || true)
    fi

    if [ -n "$target" ] && [ -f "$target" ]; then
      ''${EDITOR:-nano} "$target"
    fi
  '';
in
{
  config = mkIf (cfg.enable && fzfCfg.enable) {
    programs.fzf = {
      enable = true;
      package = pkgs.fzf;
      enableBashIntegration = true;
      enableZshIntegration = true;
      enableFishIntegration = true;

      # Busca ultra-rápida usando fd em vez do find legado
      defaultCommand = "${pkgs.fd}/bin/fd --type f --hidden --strip-cwd-prefix --exclude .git --exclude .cache";
      fileWidgetCommand = "${pkgs.fd}/bin/fd --type f --hidden --strip-cwd-prefix --exclude .git --exclude .cache";
      changeDirWidgetCommand = "${pkgs.fd}/bin/fd --type d --hidden --strip-cwd-prefix --exclude .git --exclude .cache";

      # Opções ergonômicas de UI: layout invertido, bordas arredondadas e atalhos de controle
      defaultOptions = [
        "--height=85%"
        "--min-height=25"
        "--layout=reverse"
        "--border=rounded"
        "--inline-info"
        "--prompt='󰭎 '"
        "--pointer='▶ '"
        "--marker='✓ '"
        "--tabstop=2"
        "--preview-window='right:65%:wrap'"
        "--bind 'ctrl-/:toggle-preview'"
        "--bind 'ctrl-p:change-preview-window(right:80%|right:65%|right:50%|hidden)'"
        "--bind 'ctrl-u:preview-half-page-up,ctrl-d:preview-half-page-down'"
        "--bind 'alt-a:select-all,alt-d:deselect-all'"
        "--bind 'ctrl-y:execute-silent(echo -n {+} | wl-copy 2>/dev/null || xclip -selection clipboard 2>/dev/null || true)'"
      ];

      # Widget Ctrl-T: preview inteligente de arquivos com bat e pastas com eza
      fileWidgetOptions = [
        "--preview '${fzfPreview}/bin/fzf-preview {}'"
        "--preview-window 'right:65%:wrap'"
        "--bind 'ctrl-/:toggle-preview'"
        "--bind 'ctrl-p:change-preview-window(right:80%|right:65%|right:50%|hidden)'"
      ];

      # Widget Alt-C: navegação de diretórios com árvore eza e ícones
      changeDirWidgetOptions = [
        "--preview '${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons {} 2>/dev/null | head -200'"
        "--preview-window 'right:65%:wrap'"
        "--bind 'ctrl-/:toggle-preview'"
        "--bind 'ctrl-p:change-preview-window(right:80%|right:65%|right:50%|hidden)'"
      ];

      # Widget Ctrl-R: busca refinada no histórico de comandos com atalho de cópia
      historyWidgetOptions = [
        "--sort"
        "--exact"
        "--preview 'echo {}'"
        "--preview-window 'down:3:wrap:hidden'"
        "--bind 'ctrl-/:toggle-preview'"
        "--bind 'ctrl-y:execute-silent(echo -n {2..} | wl-copy 2>/dev/null || echo -n {2..} | xclip -selection clipboard 2>/dev/null || true)'"
      ];

      # Paleta Catppuccin Mocha oficial integrada ao tema global do sistema
      colors = {
        "bg+" = "#313244";
        bg = "#1e1e2e";
        spinner = "#f5e0dc";
        hl = "#f38ba8";
        fg = "#cdd6f4";
        header = "#f38ba8";
        info = "#cba6f7";
        pointer = "#f5e0dc";
        marker = "#b4befe";
        "fg+" = "#cdd6f4";
        prompt = "#cba6f7";
        "hl+" = "#f38ba8";
        "selected-bg" = "#45475a";
      };
    };

    home = {
      packages = [
        pkgs.fd
        pkgs.bat
        pkgs.eza
        pkgs.ripgrep
        pkgs.file
        fzfPreview
        fifScript
        fkillScript
        fpreviewScript
      ];

      sessionVariables = {
        FZF_DEFAULT_COMMAND = "${pkgs.fd}/bin/fd --type f --hidden --strip-cwd-prefix --exclude .git --exclude .cache";
        FZF_CTRL_T_COMMAND = "${pkgs.fd}/bin/fd --type f --hidden --strip-cwd-prefix --exclude .git --exclude .cache";
        FZF_ALT_C_COMMAND = "${pkgs.fd}/bin/fd --type d --hidden --strip-cwd-prefix --exclude .git --exclude .cache";
        FZF_PREVIEW_COMMAND = "${fzfPreview}/bin/fzf-preview {}";
      };

      shellAliases = {
        fz = "fzf";
        fzp = "fpreview";
      };
    };
  };
}
