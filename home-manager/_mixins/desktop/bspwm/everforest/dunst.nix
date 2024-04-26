{ pkgs, ... }: {
  services.dunst = {
    configFile = {
      text = ''
        [global]
        title = Dunst
        class = Dunst
        monitor = 0
        follow = mouse
        width = 300
        height = 300
        origin = top-right
        offset = 10x92
        indicate_hidden = yes
        shrink = yes

        transparency = 0
        separator_height = 2
        padding = 8
        horizontal_padding = 11
        frame_width = 6
        frame_color = "#1a1b26"
        separator_color = "#c0caf5"

        font = JetBrainsMono Nerd Font Medium 9

        line_height = 0
        markup = full
        format = "<span size='x-large' font_desc='Cantarell 9' weight='bold' foreground='#f9f9f9'>%s</span>\n%b"
        alignment = center

        idle_threshold = 120
        show_age_threshold = 60
        sort = no
        word_wrap = yes
        ignore_newline = no
        stack_duplicates = false
        hide_duplicate_count = yes
        show_indicators = no
        sticky_history = no
        history_length = 20
        always_run_script = true
        corner_radius = 4
        icon_position = left
        max_icon_size = 80

        icon_path = /usr/share/icons/Papirus-Dark/48x48/actions/:/usr/share/icons/Papirus-Dark/48x48/apps/:/usr/share/icons/Papirus-Dark/48x48/devices/:/usr/share/icons/Papirus-Dark/48x48/emblems/:/usr/share/icons/Papirus-Dark/48x48/emotes/:/usr/share/icons/Papirus-Dark/48x48/mimetypes/:/usr/share/icons/Papirus-Dark/48x48/places/:/usr/share/icons/Papirus-Dark/48x48/status/

        browser = firefox

        mouse_left_click = close_current
        mouse_middle_click = do_action
        mouse_right_click = close_all

        [urgency_low]
        timeout = 3
        background = "#1a1b26"
        foreground = "#c0caf5"

        [urgency_normal]
        timeout = 6
        background = "#1a1b26"
        foreground = "#c0caf5"

        [urgency_critical]
        timeout = 0
        background = "#1a1b26"
        foreground = "#c0caf5"
      '';
    };
  };
}
