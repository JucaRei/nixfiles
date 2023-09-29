{ pkgs, ... }: {
  home.packages = with pkgs.unstable; [
    opera
  ];
}
