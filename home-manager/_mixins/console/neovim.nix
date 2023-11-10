{ pkgs, ... }: {
  home = {
    # packages = [ pkgs.neovim ];
    packages = [ pkgs.neovim-unwrapped ];
  };
  programs.neovim = {
    defaultEditor = false;
    coc.settings = { };
    viAlias = true;
    vimAlias = true;
    vimdiffAlias = true;
    extraPackages = with pkgs; [ ];
  };
}
