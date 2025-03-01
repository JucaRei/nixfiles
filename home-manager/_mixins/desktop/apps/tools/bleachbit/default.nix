{ pkgs, username, lib, config, ... }:
let
  inherit (lib) mkIf mkEnableOption;
  cfg = config.desktop.apps.tools.bleachbit;
in
{
  options = {
    desktop.apps.tools.bleachbit = {
      enable = mkEnableOption "Enable's bleachbit.";
    };
  };
  config = mkIf cfg.enable {
    home = {
      packages = pkgs.bleachbit;
      file = {
        ".config/bleachbit/bleachbit.ini" = {
          text = ''
            [bleachbit]
            auto_hide = True
            check_beta = False
            check_online_updates = True
            dark_mode = True
            debug = False
            delete_confirmation = True
            exit_done = False
            remember_geometry = True
            shred = False
            units_iec = False
            window_fullscreen = False
            window_maximized = False
            first_start = False
            version = 4.4.0
            window_x = 2571
            window_y = 46
            window_width = 1898
            window_height = 979
            hashsalt = 8ac0ed982296aa89aadc11f85d8b0522e07d4ce4ca80ecc43c2cef458fe7016c6f7359f5c28fac0e1322f0b03759e904767984685f55458d89f8d0fbd8a1fddc

            [hashpath]

            [list/shred_drives]
            0 = /home/${username}/.cache
            1 = /tmp

            [preserve_languages]
            en = True

            [tree]
            journald = True
            journald.clean = True
            system.desktop_entry = True
            system = True
            system.cache = True
            system.clipboard = True
            system.recent_documents = True
            system.rotated_logs = True
            system.tmp = True
            system.trash = True
            vim = True
            vim.history = True
            x11 = True
            x11.debug_logs = True
            zoom = True
            zoom.cache = True
            zoom.logs = True
            zoom.recordings = True
            firefox.backup = True
            firefox.passwords = False
            chromium.cache = True
            chromium = True
            chromium.form_history = True
            chromium.history = True
            chromium.vacuum = True
            discord = True
            discord.cache = True
            discord.history = True
            discord.vacuum = True
            easytag = True
            easytag.history = True
            easytag.logs = True
            firefox = True
            firefox.cache = True
            firefox.crash_reports = True
            firefox.vacuum = True
            system.free_disk_space = True
            deepscan.ds_store = False
            deepscan.tmp = False
            deepscan.thumbs_db = False
            deepscan.vim_swap_root = False
            deepscan.vim_swap_user = False
          '';
        };
      };
    };
  };
}
