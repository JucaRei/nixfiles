{ config, ... }: {
  # if [[ $(xrandr -1 | grep 'HDMI-1 connected') ]]; then
  # 	xrandr --output eDP-1 --primary --mode 1920x1080 --rotate normal --output HDMI-1 --mode 1600x900 --rotate normal --right-of eDP-1
  # fi
  extraConfig = ''
    bspc monitor eDP-1 -d 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰊠 󰮯 󰮯

    wmname LG3D

    bspc config pointer_modifier mod4
    bspc config pointer_action1 move
    bspc config pointer_action2 resize_side
    bspc config pointer_action2 resize_corner

    bspc config border_width         2
    bspc config window_gap           10

    bspc config split_ratio          0.52
    bspc config borderless_monocle   true
    bspc config gapless_monocle      true

    bspc config normal_border_color     "#1E1F29"
    bspc config focused_border_color    "#BD93F9"
    bspc config presel_border_color     "#FF79C6"

    bspc rule -a Chromium desktop='^2'
    bspc rule -a Blueman-manager state=floating center=true
    bspc rule -a kitty state=pseudo_tiled center=true
    bspc rule -a mplayer2 state=floating
    bspc rule -a Kupfer.py focus=on
    bspc rule -a Screenkey manage=off
  '';
}
