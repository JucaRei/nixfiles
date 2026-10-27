#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2086,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

set -euo pipefail

        STATE_DIR="${XDG_STATE_HOME:-$HOME/.local/state}/wallpaper"
        CURRENT_FILE="$STATE_DIR/current"
        LAST_DIR_FILE="$STATE_DIR/last_dir"

        mode="$CONFIGURED_MODE"
        backend="$CONFIGURED_BACKEND"
        quiet=false
        action="apply"
        target=""
        custom_dir=""
        timer_interval=""

        show_help() {
          cat <<EOF
    Uso: set-wallpaper [OPÇÕES] [ARQUIVO | DIRETÓRIO]

    Gerenciador e aplicador agnóstico de papel de parede (X11 / Wayland).
    Suporta múltiplos monitores de forma nativa: no modo aleatório (--random),
    cada monitor recebe automaticamente um wallpaper diferente.
    Também suporta troca periódica por timer (--timer / --daemon).

    Argumentos:
      ARQUIVO                  Aplica a imagem especificada em todos os monitores.
      DIRETÓRIO                Seleciona e aplica wallpapers aleatórios para as telas a partir deste diretório.

    Opções:
      -r, --random [DIR]       Aplica wallpapers aleatórios e diferentes por monitor (do DIR ou da pasta padrão).
      -n, --next               Avança para os próximos wallpapers da pasta.
      -p, --prev               Retorna aos wallpapers anteriores da pasta.
      -t, --timer [TEMPO]      Executa em loop trocando periodicamente (ex: 30s, 5m, 15m, 1h).
      -d, --daemon [TEMPO]     Sinônimo de --timer.
      --restore, --reload      Reaplica os últimos wallpapers salvos por monitor.
      -c, --current            Exibe o(s) wallpaper(s) atualmente ativo(s) por monitor.
      -m, --mode MODO          Ajuste: fill (padrão), center, tile, scale, max.
      -b, --backend BACKEND    Backend: auto (padrão), feh, swaybg, hyprpaper, xfconf, gsettings.
      -q, --quiet              Não envia notificações de desktop (notify-send).
      -h, --help               Exibe esta mensagem de ajuda.

    Configuração do Host:
      Diretório configurado: ${CONFIGURED_DIR:-"(nenhum definido, usando fallback)"}
      Intervalo de rotação:  ${CONFIGURED_INTERVAL:-"(nenhum configurado)"}
      Backend padrão:        $CONFIGURED_BACKEND
      Modo de ajuste:        $CONFIGURED_MODE
EOF
        }

        # Converter string de duração (ex: 30s, 15m, 1h) em segundos
        parse_duration() {
          local val="$1"
          case "$val" in
            *s) printf '%d\n' "${val%s}" ;;
            *m) printf '%d\n' "$(( ${val%m} * 60 ))" ;;
            *h) printf '%d\n' "$(( ${val%h} * 3600 ))" ;;
            *d) printf '%d\n' "$(( ${val%d} * 86400 ))" ;;
            *)
              if [[ "$val" =~ ^[0-9]+$ ]]; then
                printf '%d\n' "$val"
              else
                printf '900\n' # 15 minutos padrão
              fi
              ;;
          esac
        }

        # Resolver diretório alvo com cadeia de fallbacks
        resolve_target_dir() {
          local candidate="${1:-}"
          if [ -n "$candidate" ] && [ -d "$candidate" ]; then
            printf '%s\n' "$candidate"
            return 0
          fi
          if [ -n "${WALLPAPER_DIR:-}" ] && [ -d "$WALLPAPER_DIR" ]; then
            printf '%s\n' "$WALLPAPER_DIR"
            return 0
          fi
          if [ -f "$LAST_DIR_FILE" ]; then
            local saved_dir
            saved_dir=$(cat "$LAST_DIR_FILE" 2>/dev/null || true)
            if [ -n "$saved_dir" ] && [ -d "$saved_dir" ]; then
              printf '%s\n' "$saved_dir"
              return 0
            fi
          fi
          if [ -n "$CONFIGURED_DIR" ] && [ -d "$CONFIGURED_DIR" ]; then
            printf '%s\n' "$CONFIGURED_DIR"
            return 0
          fi
          if [ -d "$HOME/Pictures/Wallpapers" ]; then
            printf '%s\n' "$HOME/Pictures/Wallpapers"
            return 0
          fi
          if [ -d "$HOME/Pictures/wallpapers" ]; then
            printf '%s\n' "$HOME/Pictures/wallpapers"
            return 0
          fi
          if [ -d "$HOME/Pictures/backgrounds" ]; then
            printf '%s\n' "$HOME/Pictures/backgrounds"
            return 0
          fi
          if [ -d "/usr/share/backgrounds" ]; then
            printf '%s\n' "/usr/share/backgrounds"
            return 0
          fi
          if [ -n "$CONFIGURED_DIR" ]; then
            printf '%s\n' "$CONFIGURED_DIR"
            return 0
          fi
          printf '%s\n' "$HOME/Pictures/Wallpapers"
        }

        # Detectar o backend adequado para o ambiente atual
        detect_backend() {
          local chosen="${1:-auto}"
          if [ "$chosen" != "auto" ]; then
            printf '%s\n' "$chosen"
            return 0
          fi

          # 1. Sessão Wayland
          if [ -n "${WAYLAND_DISPLAY:-}" ] || [ "${XDG_SESSION_TYPE:-}" = "wayland" ]; then
            if [ -n "${HYPRLAND_INSTANCE_SIGNATURE:-}" ] || pgrep -x Hyprland >/dev/null 2>&1; then
              if command -v hyprctl >/dev/null 2>&1 && pgrep -x hyprpaper >/dev/null 2>&1; then
                printf 'hyprpaper\n'
                return 0
              fi
            fi
            if command -v swaybg >/dev/null 2>&1; then
              printf 'swaybg\n'
              return 0
            fi
            if command -v swww >/dev/null 2>&1; then
              printf 'swww\n'
              return 0
            fi
          fi

          # 2. Sessão X11
          if [ -n "${DISPLAY:-}" ] || [ "${XDG_SESSION_TYPE:-}" = "x11" ]; then
            if pgrep -x xfdesktop >/dev/null 2>&1 || [ "${XDG_CURRENT_DESKTOP:-}" = "XFCE" ]; then
              if command -v xfconf-query >/dev/null 2>&1; then
                printf 'xfconf\n'
                return 0
              fi
            fi

            if pgrep -x gnome-shell >/dev/null 2>&1 || [ "${XDG_CURRENT_DESKTOP:-}" = "GNOME" ]; then
              if command -v gsettings >/dev/null 2>&1; then
                printf 'gsettings\n'
                return 0
              fi
            fi

            # Padrão para BSPWM, DWM, i3 e gerenciadores X11 em geral
            if command -v feh >/dev/null 2>&1; then
              printf 'feh\n'
              return 0
            fi
          fi

          # 3. Fallbacks universais
          if command -v feh >/dev/null 2>&1; then
            printf 'feh\n'
          elif command -v swaybg >/dev/null 2>&1; then
            printf 'swaybg\n'
          else
            printf 'unknown\n'
          fi
        }

        # Detectar lista de monitores conectados/ativos
        detect_monitors() {
          local b="$1"
          local mons=()

          if [ "$b" = "swaybg" ] || [ "$b" = "hyprpaper" ] || [ "$b" = "swww" ] || [ -n "${WAYLAND_DISPLAY:-}" ]; then
            # Wayland
            if command -v wlr-randr >/dev/null 2>&1; then
              while IFS= read -r line; do
                local m
                m=$(echo "$line" | awk '{print $1}')
                [ -n "$m" ] && mons+=("$m")
              done < <(wlr-randr 2>/dev/null | grep -E '^[A-Za-z0-9-]+' || true)
            elif command -v hyprctl >/dev/null 2>&1; then
              while IFS= read -r line; do
                local m
                m=$(echo "$line" | awk '{print $2}')
                [ -n "$m" ] && mons+=("$m")
              done < <(hyprctl monitors 2>/dev/null | grep '^Monitor ' || true)
            elif command -v swaymsg >/dev/null 2>&1; then
              while IFS= read -r line; do
                local m
                m=$(echo "$line" | cut -d'"' -f4)
                [ -n "$m" ] && mons+=("$m")
              done < <(swaymsg -t get_outputs 2>/dev/null | grep '"name":' || true)
            fi
          else
            # X11 (BSPWM, DWM, etc.)
            if command -v xrandr >/dev/null 2>&1; then
              while IFS= read -r line; do
                local m
                m=$(echo "$line" | awk '{print $NF}')
                [ -n "$m" ] && mons+=("$m")
              done < <(xrandr --listactivemonitors 2>/dev/null | tail -n +2 || true)

              if [ "${#mons[@]}" -eq 0 ]; then
                while IFS= read -r line; do
                  local m
                  m=$(echo "$line" | cut -d' ' -f1)
                  [ -n "$m" ] && mons+=("$m")
                done < <(xrandr --query 2>/dev/null | grep -w 'connected' || true)
              fi
            fi
          fi

          if [ "${#mons[@]}" -eq 0 ]; then
            mons=("default")
          fi

          printf '%s\n' "${mons[@]}"
        }

        # Aplicar wallpaper(s) de acordo com o backend e quantidade de telas
        apply_to_desktop() {
          local b="$1"
          local m="$2"
          shift 2
          local -a imgs=("$@")

          case "$b" in
            feh)
              local feh_flag="--bg-fill"
              case "$m" in
                center) feh_flag="--bg-center" ;;
                tile)   feh_flag="--bg-tile" ;;
                scale)  feh_flag="--bg-scale" ;;
                max)    feh_flag="--bg-max" ;;
                fill|*) feh_flag="--bg-fill" ;;
              esac
              # feh aceita múltiplas imagens: atribui uma a cada tela Xinerama/XRandr
              feh --no-fehbg "$feh_flag" "${imgs[@]}"
              ;;

            swaybg)
              local sway_m="fill"
              case "$m" in
                center) sway_m="center" ;;
                tile)   sway_m="tile" ;;
                scale)  sway_m="fit" ;;
                max|fill|*) sway_m="fill" ;;
              esac

              local sway_args=()
              for idx in "${!imgs[@]}"; do
                local mon="${monitors[$idx]:-}"
                local img="${imgs[$idx]}"
                if [ -n "$mon" ] && [ "$mon" != "default" ]; then
                  sway_args+=("-o" "$mon" "-i" "$img" "-m" "$sway_m")
                else
                  sway_args+=("-i" "$img" "-m" "$sway_m")
                fi
              done

              local old_pids
              old_pids=$(pgrep -x swaybg 2>/dev/null || true)
              swaybg "${sway_args[@]}" >/dev/null 2>&1 &
              if [ -n "$old_pids" ]; then
                sleep 0.1
                kill $old_pids 2>/dev/null || true
              fi
              ;;

            hyprpaper)
              if command -v hyprctl >/dev/null 2>&1; then
                hyprctl hyprpaper unload all >/dev/null 2>&1 || true
                for idx in "${!imgs[@]}"; do
                  local mon="${monitors[$idx]:-}"
                  local img="${imgs[$idx]}"
                  hyprctl hyprpaper preload "$img" >/dev/null 2>&1 || true
                  if [ -n "$mon" ] && [ "$mon" != "default" ]; then
                    hyprctl hyprpaper wallpaper "$mon,$img" >/dev/null 2>&1 || true
                  else
                    hyprctl hyprpaper wallpaper ",$img" >/dev/null 2>&1 || true
                  fi
                done
              fi
              ;;

            xfconf)
              if command -v xfconf-query >/dev/null 2>&1; then
                for prop in $(xfconf-query -c xfce4-desktop -l 2>/dev/null | grep 'last-image$'); do
                  xfconf-query -c xfce4-desktop -p "$prop" -s "${imgs[0]}" 2>/dev/null || true
                done
              fi
              if [ -n "${DISPLAY:-}" ] && command -v feh >/dev/null 2>&1; then
                feh --no-fehbg --bg-fill "${imgs[@]}" 2>/dev/null || true
              fi
              ;;

            gsettings)
              if command -v gsettings >/dev/null 2>&1; then
                local g_opt="zoom"
                case "$m" in
                  center) g_opt="centered" ;;
                  tile)   g_opt="wallpaper" ;;
                  scale)  g_opt="scaled" ;;
                  max|fill|*) g_opt="zoom" ;;
                esac
                gsettings set org.gnome.desktop.background picture-options "$g_opt" 2>/dev/null || true
                gsettings set org.gnome.desktop.background picture-uri "file://${imgs[0]}" 2>/dev/null || true
                gsettings set org.gnome.desktop.background picture-uri-dark "file://${imgs[0]}" 2>/dev/null || true
              fi
              ;;

            *)
              if [ -n "${DISPLAY:-}" ] && command -v feh >/dev/null 2>&1; then
                feh --no-fehbg --bg-fill "${imgs[@]}"
              elif [ -n "${WAYLAND_DISPLAY:-}" ] && command -v swaybg >/dev/null 2>&1; then
                local old_pids
                old_pids=$(pgrep -x swaybg 2>/dev/null || true)
                swaybg -i "${imgs[0]}" -m fill >/dev/null 2>&1 &
                if [ -n "$old_pids" ]; then
                  sleep 0.1
                  kill $old_pids 2>/dev/null || true
                fi
              else
                printf 'set-wallpaper: Nenhum backend suportado encontrado para aplicar wallpaper\n' >&2
                return 1
              fi
              ;;
          esac
        }

        # Parse de argumentos CLI
        while [ $# -gt 0 ]; do
          case "$1" in
            -h|--help)
              show_help
              exit 0
              ;;
            -q|--quiet)
              quiet=true
              shift
              ;;
            -m|--mode)
              mode="$2"
              shift 2
              ;;
            -b|--backend)
              backend="$2"
              shift 2
              ;;
            -c|--current)
              action="current"
              shift
              ;;
            -t|--timer|-d|--daemon)
              action="daemon"
              shift
              if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
                timer_interval="$1"
                shift
              fi
              ;;
            -r|--random)
              action="random"
              shift
              if [ $# -gt 0 ] && [[ "$1" != -* ]]; then
                custom_dir="$1"
                shift
              fi
              ;;
            -n|--next)
              action="next"
              shift
              ;;
            -p|--prev)
              action="prev"
              shift
              ;;
            --restore|--reload)
              action="restore"
              shift
              ;;
            -*)
              printf 'set-wallpaper: Opção desconhecida: %s\n' "$1" >&2
              printf 'Execute "set-wallpaper --help" para ver as opções.\n' >&2
              exit 1
              ;;
            *)
              if [ -f "$1" ]; then
                action="set_file"
                target="$1"
              elif [ -d "$1" ]; then
                action="random"
                custom_dir="$1"
              else
                printf 'set-wallpaper: Caminho inválido ou não encontrado: %s\n' "$1" >&2
                exit 1
              fi
              shift
              ;;
          esac
        done

        # Modo Daemon / Timer contínuo
        if [ "$action" = "daemon" ]; then
          interval_spec="${timer_interval:-${CONFIGURED_INTERVAL:-15m}}"
          sleep_sec=$(parse_duration "$interval_spec")
          [ "$sleep_sec" -lt 5 ] && sleep_sec=5

          # Sorteia imediatamente uma vez ao iniciar o daemon
          "$0" --random --mode "$mode" --backend "$backend" "${quiet:+--quiet}" || true

          while true; do
            sleep "$sleep_sec"
            "$0" --random --mode "$mode" --backend "$backend" "${quiet:+--quiet}" || true
          done
          exit 0
        fi

        # Identificar backend e monitores disponíveis
        effective_backend=$(detect_backend "$backend")
        monitors=()
        while IFS= read -r mon_line; do
          [ -n "$mon_line" ] && monitors+=("$mon_line")
        done < <(detect_monitors "$effective_backend")
        num_monitors="${#monitors[@]}"
        [ "$num_monitors" -lt 1 ] && num_monitors=1

        # Exibir wallpaper atual
        if [ "$action" = "current" ]; then
          if [ -f "$CURRENT_FILE" ]; then
            idx=0
            while IFS= read -r cur_line; do
              [ -z "$cur_line" ] && continue
              mon_name="${monitors[$idx]:-Monitor $((idx + 1))}"
              printf '%s: %s\n' "$mon_name" "$cur_line"
              idx=$((idx + 1))
            done < "$CURRENT_FILE"
            exit 0
          else
            printf 'set-wallpaper: Nenhum wallpaper registrado como ativo em %s\n' "$CURRENT_FILE" >&2
            exit 1
          fi
        fi

        # Imagens selecionadas para aplicação
        selected=()

        if [ "$action" = "set_file" ]; then
          # Arquivo específico passado pelo usuário: aplica a mesma imagem em todas as telas
          abs_target=$(readlink -f "$target")
          for ((i=0; i<num_monitors; i++)); do
            selected+=("$abs_target")
          done
        elif [ "$action" = "restore" ]; then
          # Tentar restaurar o estado salvo
          if [ -f "$CURRENT_FILE" ]; then
            restored=()
            while IFS= read -r line; do
              if [ -n "$line" ] && [ -f "$line" ]; then
                restored+=("$line")
              fi
            done < "$CURRENT_FILE"

            if [ "${#restored[@]}" -gt 0 ]; then
              # Se salvamos menos imagens do que monitores atuais, preenche ciclicamente
              for ((i=0; i<num_monitors; i++)); do
                mod_idx=$(( i % ${#restored[@]} ))
                selected+=("${restored[$mod_idx]}")
              done
            fi
          fi
        fi

        # Se ainda precisamos selecionar imagens da pasta
        if [ "${#selected[@]}" -eq 0 ]; then
          target_dir=$(resolve_target_dir "$custom_dir")

          if [ ! -d "$target_dir" ]; then
            if [ -n "$CONFIGURED_DEFAULT" ] && [ -f "$CONFIGURED_DEFAULT" ]; then
              for ((i=0; i<num_monitors; i++)); do
                selected+=("$CONFIGURED_DEFAULT")
              done
            else
              if [ "$quiet" = false ]; then
                printf 'set-wallpaper: Diretório de wallpapers não encontrado: %s\n' "$target_dir" >&2
              fi
              exit 0
            fi
          else
            # Coletar todas as imagens suportadas da pasta
            images=()
            while IFS= read -r -d $'\0' img; do
              images+=("$img")
            done < <(find -L "$target_dir" -maxdepth 2 -type f \( \
              -iname "*.jpg" -o \
              -iname "*.jpeg" -o \
              -iname "*.png" -o \
              -iname "*.webp" -o \
              -iname "*.bmp" -o \
              -iname "*.svg" \
            \) -print0 | sort -z)

            if [ "${#images[@]}" -eq 0 ]; then
              if [ -n "$CONFIGURED_DEFAULT" ] && [ -f "$CONFIGURED_DEFAULT" ]; then
                for ((i=0; i<num_monitors; i++)); do
                  selected+=("$CONFIGURED_DEFAULT")
                done
              else
                if [ "$quiet" = false ]; then
                  printf 'set-wallpaper: Nenhuma imagem encontrada em %s\n' "$target_dir" >&2
                fi
                exit 0
              fi
            else
              case "$action" in
                next)
                  current_first=""
                  [ -f "$CURRENT_FILE" ] && current_first=$(head -n1 "$CURRENT_FILE" 2>/dev/null || true)
                  base_idx=-1
                  for i in "${!images[@]}"; do
                    if [ "${images[$i]}" = "$current_first" ]; then
                      base_idx=$i
                      break
                    fi
                  done
                  for ((m=0; m<num_monitors; m++)); do
                    target_idx=$(( (base_idx + 1 + m) % ${#images[@]} ))
                    selected+=("${images[$target_idx]}")
                  done
                  ;;

                prev)
                  current_first=""
                  [ -f "$CURRENT_FILE" ] && current_first=$(head -n1 "$CURRENT_FILE" 2>/dev/null || true)
                  base_idx=-1
                  for i in "${!images[@]}"; do
                    if [ "${images[$i]}" = "$current_first" ]; then
                      base_idx=$i
                      break
                    fi
                  done
                  if [ "$base_idx" -le 0 ]; then
                    base_idx="${#images[@]}"
                  fi
                  for ((m=0; m<num_monitors; m++)); do
                    target_idx=$(( (base_idx - 1 + m) % ${#images[@]} ))
                    selected+=("${images[$target_idx]}")
                  done
                  ;;

                random|*)
                  # Sorteio com imagens DIFERENTES para cada monitor
                  shuffled=()
                  if command -v shuf >/dev/null 2>&1; then
                    mapfile -t shuffled < <(printf '%s\n' "${images[@]}" | shuf)
                  else
                    pool=("${images[@]}")
                    while [ "${#pool[@]}" -gt 0 ]; do
                      r=$(( RANDOM % ${#pool[@]} ))
                      shuffled+=("${pool[$r]}")
                      pool=("${pool[@]:0:$r}" "${pool[@]:$((r + 1))}")
                    done
                  fi

                  # Evitar repetir imediatamente os wallpapers anteriores se houver imagens suficientes
                  prev_imgs=()
                  if [ -f "$CURRENT_FILE" ]; then
                    while IFS= read -r p_line; do
                      [ -n "$p_line" ] && prev_imgs+=("$p_line")
                    done < "$CURRENT_FILE"
                  fi

                  if [ "${#shuffled[@]}" -gt $(( num_monitors * 2 )) ] && [ "${#prev_imgs[@]}" -gt 0 ]; then
                    filtered=()
                    for s_img in "${shuffled[@]}"; do
                      was_prev=false
                      for p_img in "${prev_imgs[@]}"; do
                        if [ "$s_img" = "$p_img" ]; then
                          was_prev=true
                          break
                        fi
                      done
                      [ "$was_prev" = false ] && filtered+=("$s_img")
                    done
                    if [ "${#filtered[@]}" -ge "$num_monitors" ]; then
                      shuffled=("${filtered[@]}")
                    fi
                  fi

                  # Selecionar uma imagem distinta para cada monitor
                  for ((i=0; i<num_monitors; i++)); do
                    if [ "$i" -lt "${#shuffled[@]}" ]; then
                      selected+=("${shuffled[$i]}")
                    else
                      # Se houver menos imagens na pasta do que monitores, repete ciclicamente
                      fallback_idx=$(( i % ${#shuffled[@]} ))
                      selected+=("${shuffled[$fallback_idx]}")
                    fi
                  done
                  ;;
              esac
            fi
          fi
        fi

        if [ "${#selected[@]}" -eq 0 ]; then
          printf 'set-wallpaper: Não foi possível determinar imagens válidas para aplicar\n' >&2
          exit 1
        fi

        # Aplicar as imagens no desktop
        apply_to_desktop "$effective_backend" "$mode" "${selected[@]}"

        # Persistir estado
        mkdir -p "$STATE_DIR"
        printf '%s\n' "${selected[@]}" > "$CURRENT_FILE"
        printf '%s\n' "$(dirname "${selected[0]}")" > "$LAST_DIR_FILE"

        # Notificação visual
        if [ "$quiet" = false ] && command -v notify-send >/dev/null 2>&1; then
          if [ "${#selected[@]}" -gt 1 ]; then
            body=""
            for idx in "${!selected[@]}"; do
              mon_label="${monitors[$idx]:-Tela $((idx + 1))}"
              body+="${mon_label}: $(basename "${selected[$idx]}")"$'\n'
            done
            notify-send -a "Wallpaper" -i "${selected[0]}" "Papéis de Parede Atualizados" "$body" 2>/dev/null || true
          else
            notify-send -a "Wallpaper" -i "${selected[0]}" "Papel de Parede" "$(basename "${selected[0]}")" 2>/dev/null || true
          fi
        fi
