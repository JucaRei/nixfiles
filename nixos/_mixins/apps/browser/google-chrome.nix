{
  pkgs,
  params,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs.unstable; [google-chrome];
}
