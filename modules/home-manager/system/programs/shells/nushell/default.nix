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

        # --- Integração com FZF (Ctrl-R: histórico, Ctrl-T: arquivos, Alt-C: diretórios) ---
        $env.config = ($env.config? | default {} | upsert keybindings (
          ($env.config?.keybindings? | default [])
          | append [
            {
              name: fzf_history
              modifier: control
              keycode: char_r
              mode: [emacs, vi_normal, vi_insert]
              event: {
                send: executehostcommand
                cmd: "commandline edit --insert (history | get command | reverse | uniq | str join (char nl) | ${pkgs.fzf}/bin/fzf --reverse --height 45% --border=rounded | str trim)"
              }
            }
            {
              name: fzf_file
              modifier: control
              keycode: char_t
              mode: [emacs, vi_normal, vi_insert]
              event: {
                send: executehostcommand
                cmd: "commandline edit --insert (${pkgs.fd}/bin/fd --type f --hidden --exclude .git --exclude .cache | ${pkgs.fzf}/bin/fzf --reverse --height 45% --border=rounded --preview '${pkgs.bat}/bin/bat --style=numbers,changes --color=always --line-range :300 {}' | str trim)"
              }
            }
            {
              name: fzf_cd
              modifier: alt
              keycode: char_c
              mode: [emacs, vi_normal, vi_insert]
              event: {
                send: executehostcommand
                cmd: "let dir = (${pkgs.fd}/bin/fd --type d --hidden --exclude .git --exclude .cache | ${pkgs.fzf}/bin/fzf --reverse --height 45% --border=rounded --preview '${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons {}' | str trim); if ($dir | is-not-empty) { cd $dir }"
              }
            }
          ]
        ))

        # fcd: comando interativo para navegar entre diretórios
        def fcd [] {
          let dir = (${pkgs.fd}/bin/fd --type d --hidden --exclude .git --exclude .cache | ${pkgs.fzf}/bin/fzf --reverse --height 45% --border=rounded --preview '${pkgs.eza}/bin/eza --tree --level=2 --color=always --icons {}' | str trim)
          if ($dir | is-not-empty) {
            cd $dir
          }
        }
      '';
    };
  };
}
