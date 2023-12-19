{ pkgs, config, ... }: {
  home = {
    packages = with pkgs; [
      sublime4
      # sublime-merge
    ];
    file = {
      ".config/sublime-text/Packages/User/Preferences.sublime-settings" = {
      source = pkgs.writeText "sublime-settings.json" ''
				{
					"always_show_minimap_viewport": true,
					"minimap_width": "12",
					"auto_complete": true,
					"bold_folder_labels": true,
					"convert_tabspaces_on_save": false,
					"create_window_at_startup": false,
					"enable_hover_diff_popup": true,
					"trim_automatic_white_space": true,
					"ensure_newline_at_eof_on_save": true,
					"rulers":  [ "45", "90" ],
					"spell_check": false,
					"lsp_format_on_save": true,
					"folder_exclude_patterns":
					[
						".svn",
						".git",
						".hg",
						"CVS",
						"node_modules",
						"bower_components",
						"result",
						"result-dev",
					],
					"font_face": "FiraCode Nerd Font Retina",
					"font_size": "14",
					"highlight_line": true,
					"highlight_gutter": true,
					"highlight_modified_tabs": true,
					"hot_exit": false,
					"ignored_packages":
					[
						"Vintage",
						"InactivePanes",
					],
					"skip_current_file": true,
					"sort_on_load_save": false,
					"translate_tabs_to_spaces": true,
					"trim_trailing_white_space_on_save": true,
					"update_check": false,
				}
			'';
      };
      ".config/sublime-text/Packages/User/Default (Linux).sublime-keymap" = {
      source = pkgs.writeText "sublime-keymap.json" ''
				[
					{
						"keys": ["ctrl+j"], "command": "toggle_terminus_panel"
					}
				]
			'';
      };
      ".config/sublime-text/Packages/User/Package Control.sublime-settings" = {
      source = pkgs.writeText "sublime-settings.json" ''
				{
					"bootstrapped": true,
					"in_process_packages":
					[
					],
					"installed_packages":
					[
						"Base16 Eighties Dark Color Scheme",
						"BracketHighlighter",
						"Dockerfile Syntax Highlighting",
						"FileIcons",
						"gruvbox",
						"Agila Theme",
						"Nix",
						"Package Control",
						"SublimeLinter",
						"Terminus",
					],
				}
			'';
      };
    };
  };
}
