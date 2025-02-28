{ pkgs, lib, config, ... }:
let
  inherit (lib) mkOption mkIf types getExe';
  cfg = config.programs.terminal.console.bottom;
in
{
  options.programs.terminal.console.bottom = {
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
    home = {
      shellAliases = {
        top = "${getExe' config.programs.bottom.package "btm"} --basic --tree --hide_table_gap --dot_marker --theme=gruvbox -c -g --enable_gpu --memory_legend=top-right --enable_cache_memory";
      };
    };
  };
}
