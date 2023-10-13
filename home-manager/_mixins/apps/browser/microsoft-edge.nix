{ pkgs, ... }: {
  home.packages = with pkgs.unstable; [
    microsoft-edge
  ];
}
