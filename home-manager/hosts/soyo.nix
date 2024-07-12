{ config, lib, pkgs, ... }:
{
  imports = [
    ../_mixins/apps/text-editor/vscode/vscode.nix
  ];
  config = {
    services = {
      vscode-server.enable = lib.mkForce true;
      eza.enable = true;
      yt-dlp-custom.enable = true;
    };
  };
}
