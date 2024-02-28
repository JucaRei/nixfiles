{
  pkgs,
  params,
  lib,
  ...
}: {
  environment.systemPackages = with pkgs.unstable; [microsoft-edge];
}
