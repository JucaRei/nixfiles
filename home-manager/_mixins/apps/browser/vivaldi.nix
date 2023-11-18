{ pkgs, lib, params, ... }:
# let
# ifDefault = lib.mkIf (builtins.elem params.browser == "vivaldi");
# in
{

  # Module installing vivaldi as default browser
  home = {
    packages = with pkgs.unstable; [
      vivaldi
      vivaldi-ffmpeg-codecs
    ];
    sessionVariables = {
      DEFAULT_BROWSER = "${pkgs.vivaldi}/bin/vivaldi";
    };
  };

  # xdg = {
  # mime.enable = ifDefault true;
  # mimeApps = {
  # enable = ifDefault true;
  # defaultApplications = ifDefault (import ./default-browser.nix "opera");
  # };
  # };
}
