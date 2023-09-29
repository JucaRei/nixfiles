{ desktop, lib, pkgs, ... }:
{
  # Open source Dropbox client
  environment.systemPackages = with pkgs; [
    unstable.maestral
  ] ++ lib.optionals (desktop != null) [
    unstable.maestral-gui
  ];
}
