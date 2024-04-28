_: {
  programs = {
    zathura = {
      enable = true;
      # options = {
      #   font = "JetBrains Mono 9";
      #   # Enable dark mode by default
      #   # recolor = true;
      #   # Ability to paste selection
      #   selection-clipboard = "clipboard";
      #   # Ability to follow hyperlinks
      #   sandbox = "none";
      #   completion-bg = "#3B4252";
      #   completion-fg = "#ECEFF4";
      #   completion-group-bg = "#3B4252";
      #   completion-group-fg = "#88C0D0";
      #   completion-highlight-bg = "#4C566A";
      #   completion-highlight-fg = "#ECEFF4";
      #   default-bg = "#2E3440";
      #   default-fg = "#ECEFF4";
      #   highlight-active-color = "#5E81AC";
      #   highlight-color = "#88C0D0";
      #   index-active-bg = "#4C566A";
      #   index-active-fg = "#ECEFF4";
      #   index-bg = "#2E3440";
      #   index-fg = "#ECEFF4";
      #   inputbar-bg = "#3B4252";
      #   inputbar-fg = "#ECEFF4";
      #   notification-bg = "#2E3440";
      #   notification-error-bg = "#2E3440";
      #   notification-error-fg = "#BF616A";
      #   notification-fg = "#ECEFF4";
      #   notification-warning-bg = "#2E3440";
      #   notification-warning-fg = "#EBCB8B";
      #   recolor = true;
      #   recolor-darkcolor = "#D8DEE9";
      #   recolor-lightcolor = "#2E3440";
      #   render-loading-bg = "#2E3440";
      #   render-loading-fg = "#ECEFF4";
      #   selection-notification = true;
      #   statusbar-bg = "#3B4252";
      #   statusbar-fg = "#ECEFF4";
      #   statusbar-h-padding = 10;
      #   statusbar-v-padding = 10;
      # };
      options = {
        ###############
        ### Dracula ###
        ###############

        # window-title-basename = "true";
        # selection-clipboard = "clipboard";

        # Dracula color theme for Zathura
        # Swaps Foreground for Background to get a light version if the user prefers

        #
        # Dracula color theme
        #

        # notification-error-bg = "#ff5555"; # Red
        # notification-error-fg = "#f8f8f2"; # Foreground
        # notification-warning-bg = "#ffb86c"; # Orange
        # notification-warning-fg = "#44475a"; # Selection
        # notification-bg = "#282a36"; # Background
        # notification-fg = "#f8f8f2"; # Foreground

        # completion-bg = "#282a36"; # Background
        # completion-fg = "#6272a4"; # Comment
        # completion-group-bg = "#282a36"; # Background
        # completion-group-fg = "#6272a4"; # Comment
        # completion-highlight-bg = "#44475a"; # Selection
        # completion-highlight-fg = "#f8f8f2"; # Foreground

        # index-bg = "#282a36"; # Background
        # index-fg = "#f8f8f2"; # Foreground
        # index-active-bg = "#44475a"; # Current Line
        # index-active-fg = "#f8f8f2"; # Foreground

        # inputbar-bg = "#282a36"; # Background
        # inputbar-fg = "#f8f8f2"; # Foreground
        # statusbar-bg = "#282a36"; # Background
        # statusbar-fg = "#f8f8f2"; # Foreground

        # highlight-color = "#ffb86c"; # Orange
        # highlight-active-color = "#ff79c6"; # Pink

        # default-bg = "#282a36"; # Background
        # default-fg = "#f8f8f2"; # Foreground

        # render-loading = true;
        # render-loading-fg = "#282a36"; # Background
        # render-loading-bg = "#f8f8f2"; # Foreground

        #
        # Recolor mode settings
        #

        # recolor-lightcolor = "#282a36"; # Background
        # recolor-darkcolor = "#f8f8f2"; # Foreground

        #
        # Startup options
        #
        # adjust-open = "width";
        # recolor = true;

        #################
        ### Catpuccin ###
        #################
        selection-clipboard = "clipboard";
        adjust-open = "width"; # best-fit
        pages-per-row = 1;
        scroll-page-aware = true;
        scroll-full-overlap = "0.01";
        scroll-step = 50;
        zoom-min = 10;
        guioptions = "";
        # "render-loading" = "false";
        unmap = "f";
        "map f" = "toggle_fullscreen";
        "map [fullscreen] f" = "toggle_fullscreen";

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

        highlight-color = "#fabd2f"; # bright:yellow
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

        continuous-hist-save = true;
      };
    };
  };
}
