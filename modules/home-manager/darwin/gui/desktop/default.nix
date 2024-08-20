{ pkgs, lib, isWorkstation, ... }:
{
  imports = [
    ./aqua
    ../apps
  ];

  environment.systemPackages = with pkgs; [ ];
}
