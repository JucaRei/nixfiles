{ pkgs, lib, config, hostname, ... }:
let
  vars = import ../vars.nix { inherit pkgs config hostname; };
  nixgl = import ../../../../../lib/nixGL.nix { inherit config pkgs; };
  isGeneric = if (config.targets.genericLinux.enable) then true else false;
  _ = lib.getExe;
in
{
  home = {
    file = {
      "${config.xdg.configHome}/rofi/configurations/screenshot.rasi".text = ''
        @theme "/dev/null"

        * {
          bg:			#0C0F09;
          fg:			#05E289;
          bgAlt:		#1B1E25;
          background-color:	@bg;
          text-color:		@fg;
        }
        @import "./Themes/style.rasi"

        window {
          transparency:	"real";
          width:		  100px;
          height:		  260px;
          location: east;
          x-offset: -10px;
        }

        mainbox { children: [ listview ]; }

        listview {
            cycle:      true;
            dynamic:    true;
            layout:     vertical;
            padding:    10px;
        }

        element {
          padding:		0px 0px 0px 0px;
          border-radius:	8px;
        }

        element-text {
          margin:		5px 8px 5px 12px;
          padding:		4px 5px 4px 5px;
          font:			"FiraCode Nerd Font 35";
          background-color:	inherit;
          text-color:		inherit;
        }
        element selected {
          background-color:	@fg;
          text-color:		@bgAlt;
        }
      '';
      "${config.xdg.configHome}/rofi/configurations/Themes/Nord/purple.rasi".text = ''
        @theme "/dev/null"

        * {
          bg:			#2E3440;
          fg:			#B48EAD;
          button:		#3B4252;
          background-color:	@bg;
          text-color:		@fg;
        }

        window {
          transparency:	"real";
          width:		  100px;
          height:		  260px;
          location: east;
          x-offset: -10px;
        }

        mainbox { children: [ listview ]; }

        listview {
            cycle:      true;
            dynamic:    true;
            layout:     vertical;
            padding:    10px;
        }

        element {
          padding:		0px 0px 0px 0px;
          border-radius:	8px;
        }

        element-text {
          margin:		5px 8px 5px 12px;
          padding:		4px 5px 4px 5px;
          font:			"FiraCode Nerd Font 35";
          background-color:	inherit;
          text-color:		inherit;
        }
        element selected {
          background-color:	@bg;
          text-color:		@bg;
        }
      '';
      "${config.xdg.configHome}/rofi/configurations/Themes/Forest/colors.rasi".text = ''
        * {
            background:     #323D43FF;
            background-alt: #3C474DFF;
            foreground:     #DAD1BEFF;
            selected:       #7FBBB3FF;
            active:         #A7C080FF;
            urgent:         #E67E80FF;
        }
      '';
      "${config.xdg.configHome}/rofi/configurations/Themes/Forest/launcher.rasi".text = ''
        /*****----- Configuration -----*****/
        configuration {
        	modi:                       "drun";
            show-icons:                 true;
            display-drun:               "";
        	drun-display-format:        "{name}";
        }

        /*****----- Global Properties -----*****/
        @import                          "colors.rasi"

        /*****----- Main Window -----*****/
        window {
            transparency:                "real";
            location:                    center;
            anchor:                      center;
            fullscreen:                  false;
            width:                       700px;
            x-offset:                    0px;
            y-offset:                    0px;

            enabled:                     true;
            margin:                      0px;
            padding:                     0px;
            border:                      0px solid;
            border-radius:               12px;
            border-color:                @selected;
            background-color:            @background;
            cursor:                      "default";
        }

        /*****----- Main Box -----*****/
        mainbox {
            enabled:                     true;
            spacing:                     10px;
            margin:                      0px;
            padding:                     20px;
            border:                      0px solid;
            border-radius:               0px 0px 0px 0px;
            border-color:                @selected;
            background-color:            transparent;
            children:                    [ "inputbar", "listview" ];
        }

        /*****----- Inputbar -----*****/
        inputbar {
            enabled:                     true;
            spacing:                     10px;
            margin:                      0px;
            padding:                     15px;
            border:                      0px solid;
            border-radius:               12px;
            border-color:                @selected;
            background-color:            @background-alt;
            text-color:                  @foreground;
            children:                    [ "prompt", "entry" ];
        }

        prompt {
            enabled:                     true;
            background-color:            inherit;
            text-color:                  inherit;
        }
        textbox-prompt-colon {
            enabled:                     true;
            expand:                      false;
            str:                         "::";
            background-color:            inherit;
            text-color:                  inherit;
        }
        entry {
            enabled:                     true;
            background-color:            inherit;
            text-color:                  inherit;
            cursor:                      text;
            placeholder:                 "Search...";
            placeholder-color:           inherit;
        }

        /*****----- Listview -----*****/
        listview {
            enabled:                     true;
            columns:                     2;
            lines:                       8;
            cycle:                       true;
            dynamic:                     true;
            scrollbar:                   false;
            layout:                      vertical;
            reverse:                     false;
            fixed-height:                true;
            fixed-columns:               true;

            spacing:                     5px;
            margin:                      0px;
            padding:                     0px;
            border:                      0px solid;
            border-radius:               0px;
            border-color:                @selected;
            background-color:            transparent;
            text-color:                  @foreground;
            cursor:                      "default";
        }
        scrollbar {
            handle-width:                5px ;
            handle-color:                @selected;
            border-radius:               0px;
            background-color:            @background-alt;
        }

        /*****----- Elements -----*****/
        element {
            enabled:                     true;
            spacing:                     10px;
            margin:                      0px;
            padding:                     5px;
            border:                      0px solid;
            border-radius:               12px;
            border-color:                @selected;
            background-color:            transparent;
            text-color:                  @foreground;
            cursor:                      pointer;
        }
        element normal.normal {
            background-color:            @background;
            text-color:                  @foreground;
        }
        element selected.normal {
            background-color:            @selected;
            text-color:                  @background;
        }
        element-icon {
            background-color:            transparent;
            text-color:                  inherit;
            size:                        32px;
            cursor:                      inherit;
        }
        element-text {
            background-color:            transparent;
            text-color:                  inherit;
            highlight:                   inherit;
            cursor:                      inherit;
            vertical-align:              0.5;
            horizontal-align:            0.0;
        }

        /*****----- Message -----*****/
        error-message {
            padding:                     15px;
            border:                      2px solid;
            border-radius:               12px;
            border-color:                @selected;
            background-color:            @background;
            text-color:                  @foreground;
        }
        textbox {
            background-color:            @background;
            text-color:                  @foreground;
            vertical-align:              0.5;
            horizontal-align:            0.0;
            highlight:                   none;
        }
      '';

      "${config.xdg.configHome}/rofi/configurations/Themes/Forest/launcher-polybar.rasi".text = ''
        /*****----- Configuration -----*****/
        configuration {
        	modi:                       "drun,run,filebrowser,window";
            show-icons:                 true;
            display-drun:               "";
            display-run:                "";
            display-filebrowser:        "";
            display-window:             "";
        	drun-display-format:        "{name}";
        	window-format:              "{w} · {c} · {t}";
        }

        /*****----- Global Properties -----*****/
        * {
            font:                        "JetBrains Mono Nerd Font 10";
            /* background:                  #2D1B14; */
            /* background-alt:              #462D23; */
            /* foreground:                  #FFFFFF; */
            /* selected:                    #E25F3E; */
            /* active:                      #7B6C5B; */
            /* urgent:                      #934A1C; */

            background:     #323D43FF;
            background-alt: #3C474DFF;
            foreground:     #DAD1BEFF;
            selected:       #7FBBB3FF;
            active:         #A7C080FF;
            urgent:         #E67E80FF;
        }

        /*****----- Main Window -----*****/
        window {
            /* properties for window widget */
            transparency:                "real";
            location:                    west;
            anchor:                      west;
            fullscreen:                  false;
            width:                       500px;
            height:                      100%;
            x-offset:                    0px;
            y-offset:                    0px;

            /* properties for all widgets */
            enabled:                     true;
            border-radius:               0px;
            cursor:                      "default";
            background-color:            @background;
        }

        /*****----- Main Box -----*****/
        mainbox {
            enabled:                     true;
            spacing:                     0px;
            background-color:            transparent;
            orientation:                 vertical;
            children:                    [ "inputbar", "listbox", "mode-switcher" ];
        }

        listbox {
            spacing:                     15px;
            padding:                     15px;
            background-color:            transparent;
            orientation:                 vertical;
            children:                    [ "message", "listview" ];
        }

        /*****----- Inputbar -----*****/
        inputbar {
            enabled:                     true;
            spacing:                     10px;
            padding:                     40px 40px 155px;
            background-color:            transparent;
            background-image:            url("~/.config/rofi/configurations/images/d.png", width);
            text-color:                  @foreground;
            orientation:                 horizontal;
            children:                    [ "textbox-prompt-colon", "entry" ];
        }
        textbox-prompt-colon {
            enabled:                     true;
            expand:                      false;
            str:                         "";
            padding:                     12px 15px;
            border-radius:               0px;
            background-color:            @background-alt;
            text-color:                  inherit;
        }
        entry {
            enabled:                     true;
            expand:                      true;
            padding:                     12px 16px;
            border-radius:               0px;
            background-color:            @background-alt;
            text-color:                  inherit;
            cursor:                      text;
            placeholder:                 "Search";
            placeholder-color:           inherit;
        }
        dummy {
            expand:                      true;
            background-color:            transparent;
        }

        /*****----- Mode Switcher -----*****/
        mode-switcher{
            enabled:                     true;
            padding:                     15px;
            spacing:                     10px;
            background-color:            transparent;
            text-color:                  @foreground;
        }
        button {
            padding:                     12px;
            border-radius:               0px;
            background-color:            @background-alt;
            text-color:                  inherit;
            cursor:                      pointer;
        }
        button selected {
            background-color:            @selected;
            text-color:                  @foreground;
        }

        /*****----- Listview -----*****/
        listview {
            enabled:                     true;
            columns:                     1;
            lines:                       10;
            cycle:                       true;
            dynamic:                     true;
            scrollbar:                   false;
            layout:                      vertical;
            reverse:                     false;
            fixed-height:                true;
            fixed-columns:               true;

            spacing:                     10px;
            background-color:            transparent;
            text-color:                  @foreground;
            cursor:                      "default";
        }

        /*****----- Elements -----*****/
        element {
            enabled:                     true;
            spacing:                     10px;
            padding:                     8px;
            border-radius:               0px;
            background-color:            transparent;
            text-color:                  @foreground;
            cursor:                      pointer;
        }
        element normal.normal {
            background-color:            inherit;
            text-color:                  inherit;
        }
        element normal.urgent {
            background-color:            @urgent;
            text-color:                  @foreground;
        }
        element normal.active {
            background-color:            @active;
            text-color:                  @foreground;
        }
        element selected.normal {
            background-color:            @selected;
            text-color:                  @foreground;
        }
        element selected.urgent {
            background-color:            @urgent;
            text-color:                  @foreground;
        }
        element selected.active {
            background-color:            @urgent;
            text-color:                  @foreground;
        }
        element-icon {
            background-color:            transparent;
            text-color:                  inherit;
            size:                        24px;
            cursor:                      inherit;
        }
        element-text {
            background-color:            transparent;
            text-color:                  inherit;
            cursor:                      inherit;
            vertical-align:              0.5;
            horizontal-align:            0.0;
        }

        /*****----- Message -----*****/
        message {
            background-color:            transparent;
        }
        textbox {
            padding:                     12px;
            border-radius:               0px;
            background-color:            @background-alt;
            text-color:                  @foreground;
            vertical-align:              0.5;
            horizontal-align:            0.0;
        }
        error-message {
            padding:                     12px;
            border-radius:               0px;
            background-color:            @background;
            text-color:                  @foreground;
        }
      '';
      "${config.xdg.configHome}/rofi/configurations/images" = {
        source = ../../../config/rofi/everforest/images;
        recursive = true;
      };
      "${config.xdg.configHome}/rofi/configurations/scripts/powermenu.sh" = {
        executable = true;
        text = ''
          #!${pkgs.stdenv.shell}
          # Current Theme
          dir="$HOME/.config/rofi/configurations/Themes/Forest"
          theme='powermenu'

          # CMDs
          uptime="`${pkgs.procps}/bin/uptime -p | sed -e 's/up //g'`"
          host=`hostname`

          # Options
          shutdown=''
          reboot=''
          lock=''
          suspend=''
          logout=''
          yes=''
          no=''

          # Rofi CMD
          rofi_cmd() {
          	${config.programs.rofi.package}/bin/rofi -dmenu \
          		-p "Uptime: $uptime" \
          		-mesg "Uptime: $uptime" \
          		-theme $dir/$theme.rasi
          }

          # Confirmation CMD
          confirm_cmd() {
          	${config.programs.rofi.package}/bin/rofi -theme-str 'window {location: center; anchor: center; fullscreen: false; width: 350px;}' \
          		-theme-str 'mainbox {children: [ "message", "listview" ];}' \
          		-theme-str 'listview {columns: 2; lines: 1;}' \
          		-theme-str 'element-text {horizontal-align: 0.5;}' \
          		-theme-str 'textbox {horizontal-align: 0.5;}' \
          		-dmenu \
          		-p 'Confirmation' \
          		-mesg 'Are you Sure?' \
          		-theme $dir/$theme.rasi
          }

          # Ask for confirmation
          confirm_exit() {
          	echo -e "$yes\n$no" | confirm_cmd
          }

          # Pass variables to rofi dmenu
          run_rofi() {
          	echo -e "$lock\n$suspend\n$logout\n$reboot\n$shutdown" | rofi_cmd
          }

          # Execute Command
          run_cmd() {
          	selected="$(confirm_exit)"
          	if [[ "$selected" == "$yes" ]]; then
          		if [[ $1 == '--shutdown' ]]; then
          			${pkgs.systemdMinimal}/bin/systemctl poweroff
          		elif [[ $1 == '--reboot' ]]; then
          			${pkgs.systemdMinimal}/bin/systemctl reboot
          		elif [[ $1 == '--suspend' ]]; then
          			mpc -q pause
          			amixer set Master mute
          			${pkgs.systemdMinimal}/bin/systemctl suspend
          		elif [[ $1 == '--logout' ]]; then
          			if [[ "$DESKTOP_SESSION" == 'openbox' ]]; then
          				openbox --exit
          			elif [[ "$DESKTOP_SESSION" == 'bspwm' ]]; then
          				#bspc quit
                  ${pkgs.elogind}/bin/loginctl terminate-session $XDG_SESSION_ID
          			elif [[ "$DESKTOP_SESSION" == 'i3' ]]; then
          				i3-msg exit
          			elif [[ "$DESKTOP_SESSION" == 'plasma' ]]; then
          				qdbus org.kde.ksmserver /KSMServer logout 0 0 0
          			fi
          		fi
          	else
          		exit 0
          	fi
          }

          # Actions
          chosen="$(run_rofi)"
          case $chosen in
              $shutdown)
          		run_cmd --shutdown
                  ;;
              $reboot)
          		run_cmd --reboot
                  ;;
              $lock)
          		if [[ -x '/usr/bin/betterlockscreen' ]]; then
          			betterlockscreen -l
          		elif [[ -x '/usr/bin/i3lock' ]]; then
          			i3lock
          		fi
                  ;;
              $suspend)
          		run_cmd --suspend
                  ;;
              $logout)
          		run_cmd --logout
                  ;;
          esac

        '';
      };
      "${config.xdg.configHome}/rofi/configurations/Themes/Forest/powermenu.rasi".text = ''
        configuration {
            show-icons:                 false;
        }

        /*****----- Global Properties -----*****/
        @import                          "~/.config/rofi/configurations/Themes/Forest/colors.rasi"

        /*
        USE_BUTTONS=YES
        */

        /*****----- Main Window -----*****/
        window {
            /* properties for window widget */
            transparency:                "real";
            location:                    east;
            anchor:                      east;
            fullscreen:                  false;
            width:                       115px;
            x-offset:                    -15px;
            y-offset:                    0px;

            /* properties for all widgets */
            enabled:                     true;
            margin:                      0px;
            padding:                     0px;
            border:                      0px solid;
            border-radius:               0px;
            border-color:                @selected;
            cursor:                      "default";
            background-color:            @background;
        }

        /*****----- Main Box -----*****/
        mainbox {
            enabled:                     true;
            spacing:                     15px;
            margin:                      0px;
            padding:                     15px;
            border:                      0px solid;
            border-radius:               0px;
            border-color:                @selected;
            background-color:            transparent;
            children:                    [ "listview" ];
        }

        /*****----- Inputbar -----*****/
        inputbar {
            enabled:                     true;
            spacing:                     0px;
            margin:                      0px;
            padding:                     0px;
            border:                      0px;
            border-radius:               0px;
            border-color:                @selected;
            background-color:            transparent;
            text-color:                  @foreground;
            children:                    [ "textbox-prompt-colon", "prompt"];
        }

        dummy {
            background-color:            transparent;
        }

        textbox-prompt-colon {
            enabled:                     true;
            expand:                      false;
            str:                         "";
            padding:                     12px 16px;
            border-radius:               0px;
            background-color:            @urgent;
            text-color:                  @background;
        }
        prompt {
            enabled:                     true;
            padding:                     12px;
            border-radius:               0px;
            background-color:            @active;
            text-color:                  @background;
        }

        /*****----- Message -----*****/
        message {
            enabled:                     true;
            margin:                      0px;
            padding:                     12px;
            border:                      0px solid;
            border-radius:               0px;
            border-color:                @selected;
            background-color:            @background-alt;
            text-color:                  @foreground;
        }
        textbox {
            background-color:            inherit;
            text-color:                  inherit;
            vertical-align:              0.5;
            horizontal-align:            0.5;
            placeholder-color:           @foreground;
            blink:                       true;
            markup:                      true;
        }
        error-message {
            padding:                     12px;
            border:                      0px solid;
            border-radius:               0px;
            border-color:                @selected;
            background-color:            @background;
            text-color:                  @foreground;
        }

        /*****----- Listview -----*****/
        listview {
            enabled:                     true;
            columns:                     1;
            lines:                       5;
            cycle:                       true;
            dynamic:                     true;
            scrollbar:                   false;
            layout:                      vertical;
            reverse:                     false;
            fixed-height:                true;
            fixed-columns:               true;

            spacing:                     15px;
            margin:                      0px;
            padding:                     0px;
            border:                      0px solid;
            border-radius:               0px;
            border-color:                @selected;
            background-color:            transparent;
            text-color:                  @foreground;
            cursor:                      "default";
        }

        /*****----- Elements -----*****/
        element {
            enabled:                     true;
            spacing:                     0px;
            margin:                      0px;
            padding:                     20px 0px;
            border:                      0px solid;
            border-radius:               0px;
            border-color:                @selected;
            background-color:            @background-alt;
            text-color:                  @foreground;
            cursor:                      pointer;
        }
        element-text {
            font:                        "feather bold 24";
            background-color:            transparent;
            text-color:                  inherit;
            cursor:                      inherit;
            vertical-align:              0.5;
            horizontal-align:            0.5;
        }
        element selected.normal {
            background-color:            var(selected);
            text-color:                  var(background);
        }
      '';
      "${config.xdg.configHome}/rofi/configurations/scripts/screenshots.sh" = {
        executable = true;
        text = ''
          #!${pkgs.stdenv.shell}

          # Import Current Theme
          source "$HOME"/.config/rofi/configurations/applets/theme.bash
          theme="$type/$style"

          # Theme Elements
          prompt='Screenshot'
          mesg="DIR: `xdg-user-dir PICTURES`/Pictures/screenshots"

          if [[ "$theme" == *'type-1'* ]]; then
          	list_col='1'
          	list_row='5'
          	win_width='400px'
          elif [[ "$theme" == *'type-3'* ]]; then
          	list_col='1'
          	list_row='5'
          	win_width='120px'
          elif [[ "$theme" == *'type-5'* ]]; then
          	list_col='1'
          	list_row='5'
          	win_width='520px'
          elif [[ ( "$theme" == *'type-2'* ) || ( "$theme" == *'type-4'* ) ]]; then
          	list_col='5'
          	list_row='1'
          	win_width='670px'
          fi

          # Options
          layout=`cat $theme | grep 'USE_ICON' | cut -d'=' -f2`
          if [[ "$layout" == 'NO' ]]; then
          	option_1=" Capture Desktop"
          	option_2=" Capture Area"
          	option_3=" Capture Window"
          	option_4=" Capture in 5s"
          	option_5=" Capture in 10s"
          else
          	option_1=""
          	option_2=""
          	option_3=""
          	option_4=""
          	option_5=""
          fi

          # Rofi CMD
          rofi_cmd() {
          	${config.programs.rofi.package}/bin/rofi -theme-str "window {width: $win_width;}" \
          		-theme-str "listview {columns: $list_col; lines: $list_row;}" \
          		-theme-str 'textbox-prompt-colon {str: "";}' \
          		-dmenu \
          		-p "$prompt" \
          		-mesg "$mesg" \
          		-markup-rows \
          		-theme $theme
          }

          # Pass variables to rofi dmenu
          run_rofi() {
          	echo -e "$option_1\n$option_2\n$option_3\n$option_4\n$option_5" | rofi_cmd
          }

          # Screenshot
          time=`${pkgs.coreutils}/bin/date +%Y-%m-%d-%H-%M-%S`
          geometry=`${pkgs.xorg.xrandr}/bin/xrandr | grep 'current' | head -n1 | cut -d',' -f2 | tr -d '[:blank:],current'`
          dir="`xdg-user-dir PICTURES`/Pictures/screenshots"
          file="Screenshot_$time_$geometry.png"

          if [[ ! -d "$dir" ]]; then
          	mkdir -p "$dir"
          fi

          # notify and view screenshot
          notify_view() {
          	notify_cmd_shot='${pkgs.dunst}/bin/dunstify -u low --replace=699'
          	$notify_cmd_shot "Copied to clipboard."
          	${pkgs.viewnior}/bin/viewnior $dir/"$file"
          	if [[ -e "$dir/$file" ]]; then
          		$notify_cmd_shot "Screenshot Saved."
          	else
          		$notify_cmd_shot "Screenshot Deleted."
          	fi
          }

          # Copy screenshot to clipboard
          copy_shot () {
          	tee "$file" | ${pkgs.xclip}/bin/xclip -selection clipboard -t image/png
          }

          # countdown
          countdown () {
          	for sec in `seq $1 -1 1`; do
          		${pkgs.dunst}/bin/dunstify -t 1000 --replace=699 "Taking shot in : $sec"
          		${pkgs.coreutils}/bin/sleep 1
          	done
          }

          # take shots
          shotnow () {
          	cd $dir && ${pkgs.coreutils}/bin/sleep 0.5 && ${pkgs.maim}/bin/maim -u -f png | copy_shot
          	notify_view
          }

          shot5 () {
          	countdown '5'
          	${pkgs.coreutils}/bin/sleep 1 && cd $dir && ${pkgs.maim}/bin/maim -u -f png | copy_shot
          	notify_view
          }

          shot10 () {
          	countdown '10'
          	${pkgs.coreutils}/bin/sleep 1 && cd $dir && ${pkgs.maim}/bin/maim -u -f png | copy_shot
          	notify_view
          }

          shotwin () {
          	cd $dir && ${pkgs.maim}/bin/maim -u -f png -i `${pkgs.xdotool}/bin/xdotool getactivewindow` | copy_shot
          	notify_view
          }

          shotarea () {
          	cd $dir && ${pkgs.maim}/bin/maim -u -f png -s -b 2 -c 0.35,0.55,0.85,0.25 -l | copy_shot
          	notify_view
          }

          # Execute Command
          run_cmd() {
          	if [[ "$1" == '--opt1' ]]; then
          		shotnow
          	elif [[ "$1" == '--opt2' ]]; then
          		shotarea
          	elif [[ "$1" == '--opt3' ]]; then
          		shotwin
          	elif [[ "$1" == '--opt4' ]]; then
          		shot5
          	elif [[ "$1" == '--opt5' ]]; then
          		shot10
          	fi
          }

          # Actions
          chosen="$(run_rofi)"
          case $chosen in
              $option_1)
          		run_cmd --opt1
                  ;;
              $option_2)
          		run_cmd --opt2
                  ;;
              $option_3)
          		run_cmd --opt3
                  ;;
              $option_4)
          		run_cmd --opt4
                  ;;
              $option_5)
          		run_cmd --opt5
                  ;;
          esac
        '';
      };
      "${config.xdg.configHome}/rofi/configurations/applets/theme.bash".text = ''
        ## Current Theme

        type="$HOME/.config/rofi/configurations/applets/type-1"
        style='style-1.rasi'
      '';
      "${config.xdg.configHome}/rofi/configurations/applets/type-1/style-1.rasi".text = ''
        /*****----- Configuration -----*****/
        configuration {
            show-icons:                 false;
        }

        /*****----- Global Properties -----*****/
        @import                          "../../Themes/Forest/colors.rasi"

        /*
        USE_ICON=NO
        */

        /*****----- Main Window -----*****/
        window {
            transparency:                "real";
            location:                    center;
            anchor:                      center;
            fullscreen:                  false;
            width:                       400px;
            x-offset:                    0px;
            y-offset:                    0px;
            margin:                      0px;
            padding:                     0px;
            border:                      1px solid;
            border-radius:               12px;
            border-color:                @selected;
            cursor:                      "default";
            background-color:            @background;
        }

        /*****----- Main Box -----*****/
        mainbox {
            enabled:                     true;
            spacing:                     10px;
            margin:                      0px;
            padding:                     20px;
            background-color:            transparent;
            children:                    [ "inputbar", "message", "listview" ];
        }

        /*****----- Inputbar -----*****/
        inputbar {
            enabled:                     true;
            spacing:                     10px;
            padding:                     0px;
            border:                      0px;
            border-radius:               0px;
            border-color:                @selected;
            background-color:            transparent;
            text-color:                  @foreground;
            children:                    [ "textbox-prompt-colon", "prompt"];
        }

        textbox-prompt-colon {
            enabled:                     true;
            expand:                      false;
            str:                         "";
            padding:                     10px 13px;
            border-radius:               12px;
            background-color:            @urgent;
            text-color:                  @background;
        }
        prompt {
            enabled:                     true;
            padding:                     10px;
            border-radius:               12px;
            background-color:            @active;
            text-color:                  @background;
        }

        /*****----- Message -----*****/
        message {
            enabled:                     true;
            margin:                      0px;
            padding:                     10px;
            border:                      0px solid;
            border-radius:               12px;
            border-color:                @selected;
            background-color:            @background-alt;
            text-color:                  @foreground;
        }
        textbox {
            background-color:            inherit;
            text-color:                  inherit;
            vertical-align:              0.5;
            horizontal-align:            0.0;
        }

        /*****----- Listview -----*****/
        listview {
            enabled:                     true;
            columns:                     1;
            lines:                       6;
            cycle:                       true;
            scrollbar:                   false;
            layout:                      vertical;

            spacing:                     5px;
            background-color:            transparent;
            cursor:                      "default";
        }

        /*****----- Elements -----*****/
        element {
            enabled:                     true;
            padding:                     10px;
            border:                      0px solid;
            border-radius:               12px;
            border-color:                @selected;
            background-color:            transparent;
            text-color:                  @foreground;
            cursor:                      pointer;
        }
        element-text {
            background-color:            transparent;
            text-color:                  inherit;
            cursor:                      inherit;
            vertical-align:              0.5;
            horizontal-align:            0.0;
        }

        element normal.normal,
        element alternate.normal {
            background-color:            var(background);
            text-color:                  var(foreground);
        }
        element normal.urgent,
        element alternate.urgent,
        element selected.active {
            background-color:            var(urgent);
            text-color:                  var(background);
        }
        element normal.active,
        element alternate.active,
        element selected.urgent {
            background-color:            var(active);
            text-color:                  var(background);
        }
        element selected.normal {
            background-color:            var(selected);
            text-color:                  var(background);
        }
      '';
    };
  };
  programs.rofi = {
    enable = true;
    # font =
    package = if (isGeneric) then (nixgl pkgs.rofi) else pkgs.rofi;
    plugins = with pkgs; [
      rofimoji
      rofi-calc
      rofi-bluetooth
      pinentry-rofi
    ];
    pass = {
      enable = true;
      package = pkgs.rofi-pass;
      extraConfig = ''
        # workaround for https://github.com/carnager/rofi-pass/issues/226
        help_color="#FF0000"'';
    };
    terminal = "${_ vars.alacritty-custom}";
    extraConfig = {
      modi = "drun,run,filebrowser,window";
      case-sensitive = false;
      cycle = true;
      filter = "";
      scroll-method = 0;
      normalize-match = true;
      show-icons = true;
      icon-theme = "${pkgs.papirus-icon-theme}/share/icons/Papirus";

      # Matching setting
      matching = "normal";
      tokenize = true;

      #   SSH settings
      ssh-client = "ssh";
      ssh-command = "{terminal} -e {ssh-client} {host} [-p {port}]";
      parse-hosts = true;
      parse-known-hosts = true;

      #   Drun settings
      drun-categories = "";
      drun-match-fields = "name,generic,exec,categories,keywords";
      drun-display-format = "{name} [<span weight='light' size='small'><i>({generic})</i></span>]";
      drun-show-actions = false;
      drun-url-launcher = "${pkgs.xdg-utils}/bin/xdg-open";
      drun-use-desktop-cache = false;
      drun-parse-user = true; #Parse user desktop files.
      drun-parse-system = true; #Parse system desktop files.

      #   Run settings
      run-command = "{cmd}";
      run-list-command = "";
      run-shell-command = "{terminal} -e {cmd}";

      #   Fallback Icon
      run-fallback-icon = "application-x-addon";
      drun-fallback-icon = "application-x-addon";

      #   Window switcher settings
      window-match-fields = "title,class,role,name,desktop";
      window-command = "${pkgs.wmctrl}/bin/wmctrl -i -R {window}";
      window-format = "{w} - {c} - {t:0}";
      window-thumbnail = false;

      # Combi settings
      # 	combi-modi = "window,run";
      #   combi-hide-mode-prefix = false;
      #   combi-display-format = "{mode} {text}";

      #   History and Sorting
      disable-history = false;
      sorting-method = "normal";
      max-history-size = 25;

      #   Display settings
      display-window = "Windows";
      display-windowcd = "Window CD";
      display-run = "Run";
      display-ssh = "SSH";
      display-drun = "Apps";
      display-combi = "Combi";
      display-keys = "Keys";
      display-filebrowser = "Files";

      #   Misc setting
      terminal = "rofi-sensible-terminal";
      #   font= "Mono 12";
      #   sort= false;
      #   threads= 0;
      #   click-to-exit = true;
      #   ignored-prefixes: "";
      #   pid= "/run/user/1000/rofi.pid";

      #   File browser settings
      #   filebrowser-directories-first = true;
      filebrowser-directory = "/home";
      filebrowser-sorting-method = "name";

      #   Other settings
      timeout-action = "kb-cancel";
      timeout-delay = 0;
    };
  };
}
