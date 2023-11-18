{ pkgs, lib, params, ... }:
# let
# ifDefault = lib.mkIf (params.browser == "microsoft-edge");
# in
{
  home.packages = with pkgs.unstable; [
    microsoft-edge
  ];
  # xdg = {
  # mime.enable = ifDefault true;
  # mimeApps = {
  # enable = ifDefault true;
  # defaultApplications = ifDefault (import ./default-browser.nix "microsoft-edge");
  # };
  # };
}
