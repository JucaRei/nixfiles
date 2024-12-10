{ pkgs, config, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.editors.sublime;
in
{
  options = {
    desktop.apps.editors.sublime = {
      enable = mkEnableOption "Enables sublime.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        sublime4
        # sublime-merge
      ];
      file = {
        ".config/sublime-text/Packages/User/Preferences.sublime-settings" = {

          source =
            pkgs.writeText "sublime-settings.json"
              "	{\n		\"always_show_minimap_viewport\": true,\n		\"minimap_width\": \"12\",\n		\"auto_complete\": true,\n		\"bold_folder_labels\": true,\n		\"convert_tabspaces_on_save\": false,\n		\"create_window_at_startup\": false,\n		\"enable_hover_diff_popup\": true,\n		\"trim_automatic_white_space\": true,\n		\"ensure_newline_at_eof_on_save\": true,\n		\"rulers\":  [ \"45\", \"90\" ],\n		\"spell_check\": false,\n		\"lsp_format_on_save\": true,\n		\"folder_exclude_patterns\":\n		[\n			\".svn\",\n			\".git\",\n			\".hg\",\n			\"CVS\",\n			\"node_modules\",\n			\"bower_components\",\n			\"result\",\n			\"result-dev\",\n		],\n		\"font_face\": \"FiraCode Nerd Font Retina\",\n		\"font_size\": \"14\",\n		\"highlight_line\": true,\n		\"highlight_gutter\": true,\n		\"highlight_modified_tabs\": true,\n		\"hot_exit\": false,\n		\"ignored_packages\":\n		[\n			\"Vintage\",\n			\"InactivePanes\",\n		],\n		\"skip_current_file\": true,\n		\"sort_on_load_save\": false,\n		\"translate_tabs_to_spaces\": true,\n		\"trim_trailing_white_space_on_save\": true,\n		\"update_check\": false,\n	}\n";
        };

        ".config/sublime-text/Packages/User/Default (Linux).sublime-keymap" = {
          source =
            pkgs.writeText "sublime-keymap.json"
              "	[\n		{\n			\"keys\": [\"ctrl+j\"], \"command\": \"toggle_terminus_panel\"\n		}\n	]\n";
        };

        ".config/sublime-text/Packages/User/Package Control.sublime-settings" = {
          source =
            pkgs.writeText "sublime-settings.json"
              "	{\n		\"bootstrapped\": true,\n		\"in_process_packages\":\n		[\n		],\n		\"installed_packages\":\n		[\n			\"Base16 Eighties Dark Color Scheme\",\n			\"BracketHighlighter\",\n			\"Dockerfile Syntax Highlighting\",\n			\"FileIcons\",\n			\"gruvbox\",\n			\"Agila Theme\",\n			\"Nix\",\n			\"Package Control\",\n			\"SublimeLinter\",\n			\"Terminus\",\n		],\n	}\n";
        };
      };
    };
  };
}
