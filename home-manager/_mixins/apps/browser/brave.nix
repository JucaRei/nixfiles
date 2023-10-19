{ pkgs, lib, params, ... }:
let
  ifDefault = lib.mkIf (builtins.elem params.browser [ "brave" ]);
in
{
  home.packages = with pkgs.unstable;[
    brave
  ];

  xdg = {
    mime.enable = ifDefault true;
    mimeApps = {
      enable = ifDefault true;
      defaultApplications = ifDefault (import ./default-browser.nix "brave");
    };
  };
}
