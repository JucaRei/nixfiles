_: {
  programs = {
    command-not-found.enable = false;
    fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual block
        set -U fish_color_autosuggestion brblack
        set -U fish_color_cancel -r
        set -U fish_color_command green
        set -U fish_color_comment brblack
        set -U fish_color_cwd brgreen
        set -U fish_color_cwd_root brred
        set -U fish_color_end brmagenta
        set -U fish_color_error red
        set -U fish_color_escape brcyan
        set -U fish_color_history_current --bold
        set -U fish_color_host normal
        set -U fish_color_match --background=brblue
        set -U fish_color_normal normal
        set -U fish_color_operator cyan
        set -U fish_color_param blue
        set -U fish_color_quote yellow
        set -U fish_color_redirection magenta
        set -U fish_color_search_match bryellow '--background=brblack'
        set -U fish_color_selection white --bold '--background=brblack'
        set -U fish_color_status red
        set -U fish_color_user brwhite
        set -U fish_color_valid_path --underline
        set -U fish_pager_color_completion normal
        set -U fish_pager_color_description yellow
        set -U fish_pager_color_prefix white --bold --underline
        set -U fish_pager_color_progress brwhite '--background=cyan'
      '';
      shellAbbrs = {
        # nix-gc = "sudo nix-collect-garbage --delete-older-than 3d && nix-collect-garbage --delete-older-than 3d";
        # rebuild-all = "sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles && home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles";
        # rebuild-home = "home-manager switch -b backup --flake $HOME/.dotfiles/nixfiles";
        # rebuild-host = "sudo nixos-rebuild switch --flake $HOME/.dotfiles/nixfiles";
        # rebuild-lock = "pushd $HOME/.dotfiles/nixfiles && nix flake update && popd";
        # rebuild-iso-console = "sudo true && pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-console.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-console/nixos.iso && popd";
        # rebuild-iso-desktop = "sudo true && pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-desktop.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-desktop/nixos.iso && popd";
        # rebuild-iso-gpd-edp = "sudo true && pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-gpd-edp.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-gpd-edp.iso && popd";
        # rebuild-iso-gpd-dsi = "sudo true && pushd $HOME/.dotfiles/nixfiles && nix build .#nixosConfigurations.iso-gpd-dsi.config.system.build.isoImage && set ISO (head -n1 result/nix-support/hydra-build-products | cut -d'/' -f6) && sudo cp result/iso/$ISO ~/Quickemu/nixos-gpd-dsi.iso && popd";
      };
      shellAliases = {
        # nano = "micro";
      };
    };
  };
}
