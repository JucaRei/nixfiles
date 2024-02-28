{pkgs, ...}: {
  home.packages = with pkgs; [yarn nodejs vite];
  home.sessionPath = ["$HOME/.yarn/bin"];
}
