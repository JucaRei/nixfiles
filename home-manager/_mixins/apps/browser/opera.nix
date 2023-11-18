{ pkgs, lib, params, ... }:
# let
# ifDefault = lib.mkIf (params.browser == "opera");
# in
{
  home.packages = with pkgs.unstable; [
    opera
  ];
  # xdg = {
  # mime.enable = ifDefault true;
  # mimeApps = {
  # enable = ifDefault true;
  # defaultApplications = ifDefault (import ./default-browser.nix "opera");
  # };
  # };
}
