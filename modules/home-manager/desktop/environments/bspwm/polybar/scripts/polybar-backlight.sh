#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

dev=""
for d in intel_backlight nv_backlight apple_backlight acpi_video0; do
  if [ -d "/sys/class/backlight/$d" ]; then
    dev="$d"
    break
  fi
done
if [ -z "$dev" ] && [ -d /sys/class/backlight ]; then
  for b in /sys/class/backlight/*; do
    if [ -d "$b" ]; then
      dev=$(basename "$b")
      break
    fi
  done
fi

dev_args=()
if [ -n "$dev" ]; then
  dev_args=(-d "$dev")
fi

notify_osd() {
  local b_out val icon
  b_out=$(brightnessctl "${dev_args[@]}" -m 2>/dev/null || true)
  val=""
  if [[ "$b_out" =~ ,([0-9]+)% ]]; then
    val="${BASH_REMATCH[1]}"
  fi
  if [ -n "$val" ] && command -v dunstify >/dev/null 2>&1; then
    if [ "$val" -lt 33 ]; then
      icon="display-brightness-low"
    elif [ "$val" -lt 66 ]; then
      icon="display-brightness-medium"
    else
      icon="display-brightness-high"
    fi

    dunstify -a "OSD" \
      -u low \
      -i "$icon" \
      -h string:x-dunst-stack-tag:brightness \
      -h int:value:"$val" \
      -t 1500 \
      "Brilho da Tela: $val%"
  fi
}

case "${1:-}" in
  up)
    prev=$(brightnessctl "${dev_args[@]}" get 2>/dev/null)
    brightnessctl "${dev_args[@]}" set +5% >/dev/null 2>&1
    curr=$(brightnessctl "${dev_args[@]}" get 2>/dev/null)
    if [ "$prev" = "$curr" ]; then
      brightnessctl "${dev_args[@]}" set +1 >/dev/null 2>&1
    fi
    notify_osd
    command -v polybar-msg >/dev/null 2>&1 && polybar-msg action "#backlight.update" >/dev/null 2>&1 || true
    ;;
  down)
    prev=$(brightnessctl "${dev_args[@]}" get 2>/dev/null)
    brightnessctl "${dev_args[@]}" set 5%- >/dev/null 2>&1
    curr=$(brightnessctl "${dev_args[@]}" get 2>/dev/null)
    if [ "$prev" = "$curr" ]; then
      brightnessctl "${dev_args[@]}" set 1- >/dev/null 2>&1
    fi
    notify_osd
    command -v polybar-msg >/dev/null 2>&1 && polybar-msg action "#backlight.update" >/dev/null 2>&1 || true
    ;;
  *)
    b_out=$(brightnessctl "${dev_args[@]}" -m 2>/dev/null || true)
    if [[ "$b_out" =~ ,([0-9]+)% ]]; then
      echo "%{F${COLOR_YELLOW:-}}󰃠%{F-} ${BASH_REMATCH[1]}%"
    fi
    ;;
esac
