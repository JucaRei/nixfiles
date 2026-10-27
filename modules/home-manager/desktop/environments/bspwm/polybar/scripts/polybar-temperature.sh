#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

temp_file=""
    # 1. Tentar encontrar sensor de CPU em hwmon (coretemp, k10temp, zenpower, applesmc)
    for f in /sys/class/hwmon/hwmon*/name; do
      if [ -f "$f" ]; then
        name=$(cat "$f" 2>/dev/null)
        case "$name" in
          coretemp*|k10temp*|zenpower*|applesmc*|cpu*|it87*|nct6775*)
            dir=$(dirname "$f")
            for t in "$dir"/temp1_input "$dir"/temp2_input "$dir"/temp*_input; do
              if [ -r "$t" ]; then
                temp_file="$t"
                break 2
              fi
            done
            ;;
        esac
      fi
    done

    # 2. Fallback: procurar qualquer hwmon ou thermal_zone com leitura válida
    if [ -z "$temp_file" ]; then
      for t in /sys/class/hwmon/hwmon*/temp1_input /sys/class/thermal/thermal_zone*/temp; do
        if [ -r "$t" ]; then
          val=$(cat "$t" 2>/dev/null)
          if [ -n "$val" ] && [ "$val" -gt 0 ] 2>/dev/null; then
            temp_file="$t"
            break
          fi
        fi
      done
    fi

    if [ -n "$temp_file" ]; then
      raw=$(cat "$temp_file" 2>/dev/null)
      if [ -n "$raw" ] && [ "$raw" -gt 0 ] 2>/dev/null; then
        if [ "$raw" -ge 1000 ]; then
          deg=$((raw / 1000))
        else
          deg=$raw
        fi

        if [ "$deg" -ge 80 ]; then
          icon=""
          color="${COLOR_RED:-}"
        elif [ "$deg" -ge 65 ]; then
          icon=""
          color="${COLOR_PEACH:-}"
        else
          icon=""
          color="${COLOR_TEAL:-}"
        fi

        echo "%{F$color}$icon%{F-} ${deg}°C"
        exit 0
      fi
    fi

    echo "%{F${COLOR_SUBTEXT0:-}} --°C%{F-}"
