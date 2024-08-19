{ pkgs, ... }:
{
  imports = [
    ../fonts
  ];

  environment.systemPackages = with pkgs; [ ];
}
