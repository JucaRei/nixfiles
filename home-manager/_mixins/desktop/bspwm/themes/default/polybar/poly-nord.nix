{ pkgs, ... }: {
  imports = [ ./scripts.nix ];
  services = {
    polybar = {
      enable = true;
      package = pkgs.polybarFull;
      script = "";
      config = ./poly-themes/config-nord.ini;
    };
  };
}
