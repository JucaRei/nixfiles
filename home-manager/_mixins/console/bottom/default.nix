{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.custom.console.bottom;
in
{
  options.custom.console.bottom = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    programs.bottom = {
      enable = true;
      settings = {
        colors = {
          high_battery_color = "green";
          medium_battery_color = "yellow";
          low_battery_color = "red";
        };
        disk_filter = {
          is_list_ignored = true;
          list = [ "/dev/loop" ];
          regex = true;
          case_sensitive = false;
          whole_word = false;
        };
        flags = {
          dot_marker = false;
          enable_gpu_memory = true;
          group_processes = true;
          hide_table_gap = true;
          mem_as_value = true;
          tree = true;
        };
      };
    };
  };
}
