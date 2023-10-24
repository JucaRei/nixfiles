{ pkgs, ... }: {
  imports = [
    ./scripts.nix
  ];
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybarFull;
      script = "";
      settings = builtins.readFile ./poly-themes/config-nord.ini;
    };
  };
}
