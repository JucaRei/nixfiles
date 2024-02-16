{pkgs, ...}: {
  home.packages = with pkgs; [
    (nixgl-legacy vlc)
  ];
}
