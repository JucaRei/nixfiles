{ pkgs, ... }: {
  home.packages = with pkgs.unstable;[
    brave
  ];
}
