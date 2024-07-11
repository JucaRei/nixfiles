{ config, lib, pkgs, ... }:
{
  imports = [
    ../_mixins/apps/text-editor/vscode/vscode-remote
  ];
  config = {
    services = {
      vscode-server.enable = true;
      eza.enable = true;
      yt-dlp-custom.enable = true;
    };
  };
}
