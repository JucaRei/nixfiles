{
  pkgs,
  lib,
  config,
  ...
}:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.system.programs.documents.zathura;
  c = config.desktop.theme.colors;

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
  options = {
    system.programs.documents.zathura = {
      enable = mkEnableOption "Enables Zathura.";
    };
  };
  config = mkIf cfg.enable {
    home.packages = with pkgs; [ sf-mono-liga-bin ];
    programs = {
      zathura = {
        enable = true;
        package = pkgs.zathura;
        options = {
          selection-clipboard = "clipboard";
          adjust-open = "best-fit"; # "width";
          pages-per-row = 1;
          smooth-scroll = true;
          scroll-page-aware = true;
          scroll-full-overlap = "0.01";
          scroll-step = 40;
          scroll-hstep = 5;
          first-page-column = "1:2:1:2:1:2";
          zoom-min = 10;
          window-title-basename = true;
          window-title-home-tilde = true;
          window-title-page = true;
          # window-icon = "";
          statusbar-home-tilde = true;
          guioptions = "n"; # none
          unmap = "f";
          font = "Liga SFMono Nerd Font Italic 12";

          notification-error-bg = c.bg;
          notification-error-fg = c.red;
          notification-warning-bg = c.bg;
          notification-warning-fg = c.yellow;
          notification-bg = c.bg;
          notification-fg = c.green;

          completion-bg = c.surface;
          completion-fg = c.fg;
          completion-group-bg = c.bgAlt;
          completion-group-fg = c.fgMuted;
          completion-highlight-bg = c.accent;
          completion-highlight-fg = c.bg;

          # Define the color in index mode
          index-bg = c.surface;
          index-fg = c.fg;
          index-active-bg = c.accent;
          index-active-fg = c.bg;

          inputbar-bg = c.bg;
          inputbar-fg = c.fg;

          statusbar-bg = c.surface;
          statusbar-fg = c.fg;

          highlight-color = c.yellow;
          highlight-active-color = c.orange;

          default-bg = c.bg;
          default-fg = c.fg;
          render-loading = true;
          render-loading-bg = c.bg;
          render-loading-fg = c.fg;

          # Recolor book content's color
          recolor-lightcolor = c.bg;
          recolor-darkcolor = c.fg;
          recolor = true;
          # recolor-keephue             true      # keep original color

          # sandbox = "none";

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

          # Color Schemes (# exceção: esquemas legados de atalhos de recolor para leitura)
          map <A-F1> set 'recolor-lightcolor "#2c333d"' # exceção: esquema escuro
          map <A-F2> set 'recolor-darkcolor "#FFFFFF"' # exceção: esquema escuro
          map <A-F3> set 'recolor-lightcolor "#d8cfbf"' # exceção: esquema sepia
          map <A-F4> set 'recolor-darkcolor "#000000"' # exceção: esquema sepia
          map <A-F5> set 'recolor-lightcolor "#181E27"' # exceção: esquema noite
          map <A-F6> set 'recolor-darkcolor "#EFE7DD"' # exceção: esquema noite
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

    xdg =
      let
        application = "org.pwmt.zathura.desktop";
      in
      {
        mimeApps = {
          defaultApplications = lib.mkDefault {
            "application/pdf" = application;
            "application/oxps" = application;
            "application/epub+zip" = application;
            "application/x-fictionbook" = application;
            "image/vnd.djvu" = application;
            "image/vnd.djvu+multipage" = application;
            "application/postscript" = application;
            "application/eps" = application;
            "application/x-eps" = application;
            "image/eps" = application;
            "image/x-eps" = application;
            "application/x-cbr" = application;
            "application/x-cbz" = application;
            "application/x-cb7" = application;
            "application/x-cbt" = application;
          };

          associations.added = lib.mkDefault {
            "application/pdf" = application;
            "application/oxps" = application;
            "application/epub+zip" = application;
            "application/x-fictionbook" = application;
            "image/vnd.djvu" = application;
            "image/vnd.djvu+multipage" = application;
            "application/postscript" = application;
            "application/eps" = application;
            "application/x-eps" = application;
            "image/eps" = application;
            "image/x-eps" = application;
            "application/x-cbr" = application;
            "application/x-cbz" = application;
            "application/x-cb7" = application;
            "application/x-cbt" = application;
          };
        };
      };
  };
}
