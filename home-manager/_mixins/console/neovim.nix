{ pkgs, ... }: {
  home = {
    packages = pkgs.neovim;
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
