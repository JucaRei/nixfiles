{
  pkgs,
  config,
  ...
}: {
  home = {
    packages = pkgs.fastfetch;
    file = {
      "${config.xdg.configHome}/fastfetch/config.jsonc".text =
        builtins.readFile ../config/fastfetch/fastfetch.jsonc;
    };
    shellAliases = {neofetch = "${pkgs.fastfetch}";};
  };
}
