{ config, pkgs, ... }:
{

  home.packages = [ pkgs.tealdeer ];

  home.file.".config/tealdeer/config.toml".text =
    ''
      [display]

      compact = true

      [style]

      description      = { foreground = "white" }
      example_text     = { foreground = "black", bold = true }
      command_name     = { foreground = "blue",  bold = true }
      example_code     = { foreground = "cyan" }
      example_variable = { foreground = "cyan" }

      [updates]

      auto_update = true
      auto_update_interval_hours = 336 # 2 weeks
    '';

}
