{pkgs,...}:
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
in  {
  programs.zathura = {
    enable = true;
    options = {
      # Enable dark mode by default
      recolor = true;
      # Ability to paste selection
      selection-clipboard = "clipboard";
      # Ability to follow hyperlinks
      sandbox = "none";

      # Appearance
      completion-bg = "#091833";
      # completion-fg = "#0ABDC6";
      completion-fg = "#FBFF00";
      # completion-fg = "#FBFF00";
      # completion-group-bg = "";
      # completion-group-fg = "";
      completion-highlight-bg = "#711C91";
      completion-highlight-fg = "#0ABDC6";
      default-fg = "#0ABDC6";
      # default-fg = "#FBFF00";
      default-bg = "#000B1E";
      font = "FiraCode Nerd Font 9";
      inputbar-bg = "#000B1E";
      inputbar-fg = "#0ABDC6";
      notification-bg = "#091833";
      notification-fg = "#EA00D9";
      notification-error-bg = "#091833";
      notification-error-fg = "#FF0000";
      notification-warning-bg = "#091833";
      notification-warning-fg = "#F57800";
      statusbar-bg = "#091833";
      statusbar-fg = "#0ABDC6";

      highlight-color = "#EA00D9";
      highlight-fg = "#711C91";
      highlight-active-color = "#00FF00";
      highlight-transparency = "0.6";
      # recolor-darkcolor = "#0ABDC6";
      recolor-darkcolor = "#FBFF00";
      recolor-lightcolor = "#000B1E";
      index-bg = "#091833";
      index-fg = "#0ABDC6";
      index-active-bg = "#711c91";
      # index-active-fg = "#0ABDC6";
      index-active-fg = "#FBFF00";

      window-title-basename = true;
      smooth-scroll = true;
      statusbar-home-tilde = true;
    };
     extraConfig = ''
      # Zathura configuration file
      # See man `man zathurarc'

      # Open document in fit-width mode by default
      # set adjust-open "best-fit"
      set windowsize

      # One page per row by default
      set pages-per-row 1

      # stop at page boundries
      set scroll-page-aware "true"
      set scroll-full-overlap 0.01
      set scroll-step 100

      # zoom settings
      set zoom-min 10
      set guioptions ""

      # zathurarc-dark

      set font "DaddyTimeMono Nerd Font 15"
      set default-fg 			"#96CDFB"
      set default-bg 			"#1A1823"

      set completion-bg		"#1A1823"
      set completion-fg		"#96cdfb"
      set completion-highlight-bg	"#302D41"
      set completion-highlight-fg	"#96cdfb"
      set completion-group-bg		"#1a1823"
      set completion-group-fg		"#89DCEB"

      set statusbar-fg		"#C9CBFF"
      set statusbar-bg		"#1A1823"
      set statusbar-h-padding		10
      set statusbar-v-padding		10

      set notification-bg		"#1A1823"
      set notification-fg		"#D9E0EE"
      set notification-error-bg	"#d9e0ee"
      set notification-error-fg	"#D9E0EE"
      set notification-warning-bg	"#FAE3B0"
      set notification-warning-fg	"#D9E0EE"
      set selection-notification	"true"

      set inputbar-fg			"#C9CBFF"
      set inputbar-bg 		"#1A1823"

      set recolor			"true"
      set recolor-lightcolor		"#D9E0EE"
      set recolor-darkcolor		"#1A1823"

      set index-fg			"#96cdfb"
      set index-bg			"#1A1823"
      set index-active-fg		"#96cdfb"
      set index-active-bg		"#1A1823"

      set render-loading-bg		"#1A1823"
      set render-loading-fg		"#96cdfb"

      set highlight-color		"#96cdfb"
      set highlight-active-color	"#DDB6F2"

      set render-loading "false"
      set scroll-step 50

      set selection-clipboard clipboard
    '';
  };
  xdg = {
    mimeApps = {
      defaultApplications = {
        "application/pdf" = [ "org.pwmt.zathura.desktop" ];
      };
    };
  };
}
