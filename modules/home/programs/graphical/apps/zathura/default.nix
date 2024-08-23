{
  config,
  lib,
  namespace,
  pkgs,
  ...
}:
let
  inherit (lib) mkEnableOption mkIf;

  cfg = config.${namespace}.programs.graphical.apps.zathura;
in
{
  options.${namespace}.programs.graphical.apps.zathura = {
    enable = mkEnableOption "zathura";
  };

  config = mkIf cfg.enable {
    programs.zathura =
      let
        windowsize = pkgs.writeShellScriptBin "windowsize" ''
          #!/bin/sh
          ${pkgs.zathura}/bin/zathura "$@" & PID="$!"

          while true; do
            window_id="$(${pkgs.xdotool}/bin/xdotool search --onlyvisible --pid "$PID")"
            if [ -n "$window_id" ]; then
              ${pkgs.xdotool}/bin/xdotool windowactivate --sync "$window_id" windowfocus --sync "$window_id" \
                key s key --delay 0 g g
              break
            fi
          done
        '';
      in
      {
        enable = true;

        options = {
          adjust-open = "best-fit";
          font = "Iosevka 14";
          pages-per-row = "1";
          # recolor-lightcolor = "rgba(0,0,0,0)";
          first-page-column = "1:2:1:2:1:2";
          window-title-basename = true;
          window-title-home-tilde = true;
          window-title-page = true;
          statusbar-home-tilde = true;
          guioptions = "n"; # none
          # "render-loading" = "false";
          unmap = "f";
          # font = "RobotoMono Nerd Font 12";
          smooth-scroll = true;
          scroll-step = "40"; # "100";
          scroll-hstep = 5;
          scroll-full-overlap = "0.01";
          scroll-page-aware = "true";
          selection-clipboard = "clipboard";
          selection-notification = true;
          zoom-min = "10";

          notification-error-bg = "#1d2021"; # bg
          notification-error-fg = "#fb4934"; # bright:red
          notification-warning-bg = "#1d2021"; # bg
          notification-warning-fg = "#fabd2f"; # bright:yellow
          notification-bg = "#1d2021"; # bg
          notification-fg = "#b8bb26"; # bright:green

          completion-bg = "#504945"; # bg2
          completion-fg = "#ebdbb2"; # fg
          completion-group-bg = "#3c3836"; # bg1
          completion-group-fg = "#928374"; # gray
          completion-highlight-bg = "#83a598"; # bright:blue
          completion-highlight-fg = "#504945"; # bg2

          # # Define the color in index mode
          index-bg = "#504945"; # bg2
          index-fg = "#ebdbb2"; # fg
          index-active-bg = "#83a598"; # bright:blue
          index-active-fg = "#504945"; # bg2

          inputbar-bg = "#1d2021"; # bg
          inputbar-fg = "#ebdbb2"; # fg

          statusbar-bg = "#504945"; # bg2
          statusbar-fg = "#ebdbb2"; # fg

          highlight-color = "#96cdfb"; # "#fabd2f"; # bright:yellow
          highlight-active-color = "#fe8019"; # bright:orange

          default-bg = "#1d2021"; # bg
          default-fg = "#ebdbb2"; # fg
          render-loading = true;
          render-loading-bg = "#1d2021"; # bg
          render-loading-fg = "#ebdbb2"; # fg

          # # Recolor book content's color
          recolor-lightcolor = "#1d2021"; # bg
          recolor-darkcolor = "#ebdbb2"; # fg
          recolor = true;
          # recolor-keephue             true      # keep original color

          database = "sqlite";
          incremental-search = true;
          abort-clear-search = true;
          dbus-service = false;
          show-recent = 10;
          show-hidden = true;
          link-zoom = true;
          link-hadjust = true;
          show-directories = true;

          n-completion-items = 25;
          continuous-hist-save = true;
        };
        extraConfig = ''
          # set adjust-open width

          map <C-Tab> toggle_statusbar
          map <C-i> zoom in
          map <C-o> zoom out
          # map [normal] l jumplist backward
          # map [normal] L jumplist forward

          map H navigate previous
          map [fullscreen] H navigate previous
          map L navigate next
          map [fullscreen] L navigate next
          map D toggle_page_mode
          map r reload
          map R rotate

          map <C-1> feedkeys ":set pages-per-row 1"<Return>
          map <C-2> feedkeys ":set pages-per-row 2"<Return>
          map <C-3> feedkeys ":set pages-per-row 3"<Return>
          map <C-4> feedkeys ":set pages-per-row 4"<Return>
          map t toggle_page_mode
          map T feedkeys ":set pages-per-row "

          # map f set 'toggle_fullscreen'
          # map [fullscreen] f set 'toggle_fullscreen'
          map F toggle_fullscreen
          map [fullscreen] F toggle_fullscreen

          # Color Schemes
          map <A-F1> set 'recolor-lightcolor "#2c333d"'
          map <A-F2> set 'recolor-darkcolor "#FFFFFF"'
          map <A-F3> set 'recolor-lightcolor "#d8cfbf"'
          map <A-F4> set 'recolor-darkcolor "#000000"'
          map <A-F5> set 'recolor-lightcolor "#181E27"'
          map <A-F6> set 'recolor-darkcolor "#EFE7DD"'
          set recolor-keephue true

          # Keybinds for Colorschemes
          map <F1> feedkeys "<A-F1><A-F2>"
          map <F2> feedkeys "<A-F3><A-F4>"
          map <F3> feedkeys "<A-F5><A-F6>"
          map i recolor

          # One page per row by default
          set pages-per-row 1

          # stop at page boundries
          set scroll-page-aware "true"
          set scroll-full-overlap 0.01
          set scroll-step 50 # 100

          set page-padding 5

          # Open document in fit-width mode by default
          # set adjust-open "best-fit"
          set ${windowsize}/bin/windowsize
        '';
      };
  };
}
