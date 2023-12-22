{ pkgs, config, ... }: {
  programs = {
    hyprland = {
      enable = true;
      enableNvidiaPatches = true;
    };
  };
}
