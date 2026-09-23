{
  config,
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkIf getExe;
  cfg = config.system.programs.shells;
  isNu = cfg.default == "nu" || cfg.default == "nushell";
in
{
  config = mkIf (cfg.enable && isNu) {
    programs.nushell = {
      enable = true;
      settings = {
        show_banner = false;
        table = {
          mode = "rounded";
          index_mode = "always";
          show_empty = true;
        };
        completions = {
          case_sensitive = false;
          quick = true;
          partial = true;
          algorithm = "fuzzy";
        };
        history = {
          max_size = 100000;
          sync_on_enter = true;
          file_format = "plaintext";
        };
        cursor_shape_emacs = "line";
        cursor_shape_vi_insert = "line";
        cursor_shape_vi_normal = "block";
      };
      extraConfig = ''
        if ($nu.is-interactive) {
          ^${getExe pkgs.nitch}
        }
      '';
    };
  };
}
