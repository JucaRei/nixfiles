{ pkgs, lib, params, ... }:
# let
# ifDefault = lib.mkIf (builtins.elem params.browser [ "chrome" "google-chrome" ]);
# in
{
  home.packages = with pkgs.unstable; [ google-chrome ];
  # xdg = {
  # mime.enable = ifDefault true;
  # mimeApps = {
  # enable = ifDefault true;
  # defaultApplications = ifDefault (import ./default-browser.nix "chromium");
  # };
  # };
}
