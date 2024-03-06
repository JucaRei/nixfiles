_: {
  programs = {
    gitui = {
      enable = true;
      theme = ''
        (
          selected_tab: Reset,
          command_fg: Black,
          selection_bg: Blue,
          selection_fg: White,
          cmdbar_bg: Yellow,
          cmdbar_extra_lines_bg: Yellow,
          disabled_fg: DarkGray,
          diff_line_add: Green,
          diff_line_delete: Red,
          diff_file_added: LightGreen,
          diff_file_removed: LightRed,
          diff_file_moved: LightMagenta,
          diff_file_modified: Yellow,
          commit_hash: Magenta,
          commit_time: LightCyan,
          commit_author: Green,
          danger_fg: Red,
          push_gauge_bg: Blue,
          push_gauge_fg: Reset,
          tag_fg: LightMagenta,
          branch_fg: LightYellow,
        )
      '';
    };
  };
}
