#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

# Garantir que o Dunst esteja em execução
if ! pgrep -x dunst >/dev/null 2>&1; then
  if command -v systemctl >/dev/null 2>&1 && [ -n "$DISPLAY" ]; then
    systemctl --user import-environment DISPLAY XAUTHORITY DBUS_SESSION_BUS_ADDRESS 2>/dev/null || true
    systemctl --user start dunst 2>/dev/null || true
  fi

  if ! pgrep -x dunst >/dev/null 2>&1; then
    nohup dunst >/dev/null 2>&1 &
    sleep 0.3
  fi
fi

        while true; do
          # Fecha notificações ativas na tela para movê-las ao histórico para que fiquem listadas no Rofi
          count_disp=$(dunstctl count displayed 2>/dev/null || echo "0")
          if [ "$count_disp" -gt 0 ]; then
            dunstctl close-all 2>/dev/null || true
            sleep 0.1
          fi

          is_paused=$(dunstctl is-paused 2>/dev/null || echo "false")
          if [ "$is_paused" = "true" ]; then
            dnd_label="Desativar Modo Não Perturbe (DND está ATIVADO)"
            dnd_icon="󰂛"
          else
            dnd_label="Ativar Modo Não Perturbe (DND está DESATIVADO)"
            dnd_icon="󰂚"
          fi

          history_err_file="/tmp/dunstctl_err_$USER.txt"
          history_raw_file="/tmp/dunstctl_raw_$USER.json"
          jq_err_file="/tmp/dunstctl_jq_err_$USER.txt"

          history_json=$(dunstctl history 2>"$history_err_file")
          hist_exit=$?

          if [ $hist_exit -ne 0 ] || [ -z "$history_json" ]; then
            history_json='{"data":[[]]}'
          else
            echo "$history_json" > "$history_raw_file" 2>/dev/null || true
          fi

          mapfile -t notif_entries < <(echo "$history_json" | jq -r '
            [
              .. | objects |
              select(has("summary") or has("message") or has("body")) |
              [
                (try (.id.data // .id // 0 | tostring) catch "0"),
                (try ((.appname.data // .appname // "Sistema") | tostring | gsub("[\r\n\t]"; " ")) catch "Sistema"),
                (try ((.summary.data // .summary // .message.data // .message // "Sem título") | tostring | gsub("[\r\n\t]"; " ")) catch "Sem título"),
                (try ((.body.data // .body // "") | tostring | gsub("[\r\n\t]"; " ")) catch "")
              ]
            ] | reverse | .[]? | @tsv
          ' 2>"$jq_err_file")

          clean_entries=()
          for entry in "${notif_entries[@]}"; do
            [ -n "$entry" ] && clean_entries+=("$entry")
          done
          notif_entries=("${clean_entries[@]}")
          total_notifs=${#notif_entries[@]}

          menu_lines=()
          unset item_to_id item_to_app item_to_summary item_to_body
          declare -A item_to_id=()
          declare -A item_to_app=()
          declare -A item_to_summary=()
          declare -A item_to_body=()

          OPT_DND="$dnd_icon  $dnd_label"
          OPT_CLEAR="󰆴  Limpar todo o histórico de notificações"
          OPT_POP="󰵅  Reexibir última notificação na tela"
          OPT_SEP="────────────────────────────────────────────────────────"

          menu_lines+=("$OPT_DND")
          if [ "$total_notifs" -gt 0 ]; then
            menu_lines+=("$OPT_CLEAR")
            menu_lines+=("$OPT_POP")
            menu_lines+=("$OPT_SEP")

            idx=0
            for line in "${notif_entries[@]}"; do
              [ -z "$line" ] && continue
              IFS=$'\t' read -r nid napp nsum nbody <<< "$line"

              [ -z "$napp" ] && napp="Sistema"
              [ -z "$nsum" ] && nsum="Sem título"

              preview="$nsum"
              if [ -n "$nbody" ]; then
                preview="$preview — $nbody"
              fi
              if [ ${#preview} -gt 75 ]; then
                preview="${preview:0:72}..."
              fi

              idx=$(( idx + 1 ))
              label="󰂞  [$idx] #$nid [$napp] $preview"
              menu_lines+=("$label")
              item_to_id["$label"]="$nid"
              item_to_app["$label"]="$napp"
              item_to_summary["$label"]="$nsum"
              item_to_body["$label"]="$nbody"
            done
          else
            count_hist=$(dunstctl count history 2>/dev/null || echo "0")
            count_wait=$(dunstctl count waiting 2>/dev/null || echo "0")
            count_disp=$(dunstctl count displayed 2>/dev/null || echo "0")
            menu_lines+=("󰂚  Nenhuma notificação no histórico ($count_hist no Dunst, $count_wait na fila, $count_disp na tela)")

            if [ -s "$history_err_file" ]; then
              err_txt=$(head -n 1 "$history_err_file" | tr '\n' ' ')
              [ -n "$err_txt" ] && menu_lines+=("󰅖  Erro dunstctl: $err_txt")
            fi
            if [ -s "$jq_err_file" ]; then
              jq_txt=$(head -n 1 "$jq_err_file" | tr '\n' ' ')
              [ -n "$jq_txt" ] && menu_lines+=("󰅖  Erro jq: $jq_txt")
            fi

            if [ "$count_wait" -gt 0 ]; then
              menu_lines+=("󰵅  Liberar $count_wait notificação(ões) pendente(s) na fila")
            fi
            menu_lines+=("󰂞  Enviar notificação de teste")
          fi

          prompt="Notificações ($total_notifs)"
          chosen=$(printf "%s\n" "${menu_lines[@]}" | rofi -dmenu -i -p " $prompt " \
            -theme-str 'window { width: 750px; border-radius: 14px; } listview { lines: 12; }')

          [ -z "$chosen" ] && exit 0

          if [ "$chosen" = "$OPT_DND" ]; then
            dunstctl set-paused toggle
            sleep 0.1
            continue
          elif [ "$chosen" = "$OPT_CLEAR" ]; then
            dunstctl history-clear
            continue
          elif [ "$chosen" = "$OPT_POP" ]; then
            dunstctl history-pop
            exit 0
          elif [[ "$chosen" == "󰵅  Liberar "* ]]; then
            dunstctl set-paused false 2>/dev/null || true
            sleep 0.1
            dunstctl close-all 2>/dev/null || true
            sleep 0.1
            continue
          elif [ "$chosen" = "󰂞  Enviar notificação de teste" ]; then
            dunstify -u normal -a "Sistema" "Teste de Notificação" "O Dunst e o Rofi estão funcionando perfeitamente!" 2>/dev/null || true
            sleep 0.3
            dunstctl close-all 2>/dev/null || true
            sleep 0.1
            continue
          elif [ "$chosen" = "$OPT_SEP" ] || [[ "$chosen" == "󰂚  Nenhuma notificação"* ]] || [[ "$chosen" == "󰅖  Erro "* ]]; then
            continue
          else
            nid="${item_to_id["$chosen"]:-}"
            if [ -n "$nid" ]; then
              napp="${item_to_app["$chosen"]:-"Sistema"}"
              nsum="${item_to_summary["$chosen"]:-"Sem título"}"
              nbody="${item_to_body["$chosen"]:-""}"

              detail_text="Origem: $napp"
              detail_text="$detail_text
    Assunto: $nsum"
              if [ -n "$nbody" ]; then
                detail_text="$detail_text

    Mensagem:
    $nbody"
              fi

              ACT_POP="󰵅  Reexibir esta notificação na tela (Popup)"
              ACT_BACK="󰌍  Voltar à lista"
              ACT_CLOSE="󰅖  Fechar"

              detail_choice=$(printf "%s\n%s\n%s\n" "$ACT_POP" "$ACT_BACK" "$ACT_CLOSE" | rofi -dmenu -i \
                -mesg "$detail_text" \
                -p " [$napp] Detalhes " \
                -theme-str 'window { width: 750px; border-radius: 14px; } listview { lines: 3; }')

              if [ "$detail_choice" = "$ACT_POP" ]; then
                dunstctl history-pop "$nid"
                exit 0
              elif [ "$detail_choice" = "$ACT_BACK" ]; then
                continue
              else
                exit 0
              fi
            fi
          fi
        done
