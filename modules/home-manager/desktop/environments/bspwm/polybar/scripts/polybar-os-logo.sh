#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

if [ -n "${OS_LOGO_ICON:-}" ]; then
      echo "$OS_LOGO_ICON"
      exit 0
    fi

    os_id=""
    os_like=""

    if [ -r /etc/os-release ]; then
      . /etc/os-release 2>/dev/null
      os_id="${ID:-}"
      os_like="${ID_LIKE:-}"
    elif [ -r /usr/lib/os-release ]; then
      . /usr/lib/os-release 2>/dev/null
      os_id="${ID:-}"
      os_like="${ID_LIKE:-}"
    fi

    if [ -z "$os_id" ] && [ -e /etc/NIXOS ]; then
      os_id="nixos"
    fi

    os_id=$(echo "$os_id" | tr '[:upper:]' '[:lower:]')
    os_like=$(echo "$os_like" | tr '[:upper:]' '[:lower:]')

    icon=""
    color="${COLOR_YELLOW:-}"

    case "$os_id" in
      nixos)
        icon="󱄅"
        color="${COLOR_SKY:-}"
        ;;
      debian)
        icon=""
        color="${COLOR_RED:-}"
        ;;
      fedora)
        icon=""
        color="${COLOR_BLUE:-}"
        ;;
      arch|archarm)
        icon="󰣇"
        color="${COLOR_SAPPHIRE:-}"
        ;;
      endeavouros)
        icon=""
        color="${COLOR_MAUVE:-}"
        ;;
      artix)
        icon=""
        color="${COLOR_SAPPHIRE:-}"
        ;;
      ubuntu)
        icon=""
        color="${COLOR_PEACH:-}"
        ;;
      pop)
        icon=""
        color="${COLOR_TEAL:-}"
        ;;
      linuxmint|mint)
        icon=""
        color="${COLOR_GREEN:-}"
        ;;
      void)
        icon=""
        color="${COLOR_GREEN:-}"
        ;;
      opensuse*|suse)
        icon=""
        color="${COLOR_GREEN:-}"
        ;;
      gentoo)
        icon=""
        color="${COLOR_LAVENDER:-}"
        ;;
      alpine)
        icon=""
        color="${COLOR_BLUE:-}"
        ;;
      manjaro)
        icon=""
        color="${COLOR_TEAL:-}"
        ;;
      centos)
        icon=""
        color="${COLOR_MAUVE:-}"
        ;;
      rhel|redhat|almalinux|rocky)
        icon=""
        color="${COLOR_RED:-}"
        ;;
      kali)
        icon=""
        color="${COLOR_BLUE:-}"
        ;;
      *)
        case "$os_like" in
          *arch*)
            icon="󰣇"
            color="${COLOR_SAPPHIRE:-}"
            ;;
          *debian*)
            icon=""
            color="${COLOR_RED:-}"
            ;;
          *fedora*|*rhel*)
            icon=""
            color="${COLOR_BLUE:-}"
            ;;
          *ubuntu*)
            icon=""
            color="${COLOR_PEACH:-}"
            ;;
          *suse*)
            icon=""
            color="${COLOR_GREEN:-}"
            ;;
          *)
            icon=""
            color="${COLOR_YELLOW:-}"
            ;;
        esac
        ;;
    esac

    if [ "${1:-}" = "--pill" ]; then
      echo "%{T5}%{F$color}%{F-}%{T-}%{O-1}%{B$color}%{F${COLOR_CRUST:-}}%{T4}$icon%{T-}%{F-}%{B-}%{O-1}%{T5}%{F$color}%{F-}%{T-}"
    elif [ "${1:-}" = "--icon-only" ]; then
      echo "$icon"
    elif [ "${1:-}" = "--color-only" ]; then
      echo "$color"
    else
      echo "%{F$color}$icon%{F-}"
    fi
