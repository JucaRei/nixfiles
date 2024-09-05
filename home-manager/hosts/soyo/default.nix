{ config, lib, pkgs, ... }:
{
  imports = [
    ../../_mixins/apps/text-editor/vscode/code-remote
  ];
  config = {
    services = {
      # vscode-server = {
      #enable = lib.mkForce true;
      #enableFHS = lib.mkForce true;
      #nodejsPackage = pkgs.nodejs-18_x;
      # extraRuntimeDependencies = pkgs: with pkgs; [
      #   nixpkgs-fmt # formatter
      #   nix-output-monitor # better output from builds
      #   nil # lsp server
      #   nix-direnv # A shell extension that manages your environment for nix
      #   git # versioning
      #   wget
      #   curl
      # ];
      # };
      code-server.enable = lib.mkForce true;
      eza.enable = false;
      lsd.enable = true;
      yt-dlp-custom.enable = true;
    };

    # home.file.widevine-lib = {
    #   source = "${pkgs.unfree.widevine-cdm}/share/google/chrome/WidevineCdm/_platform_specific/linux_x64/libwidevinecdm.so";
    #   target = ".kodi/cdm/libwidevinecdm.so";
    # };
    # home.file.widevine-manifest = {
    #   source = "${pkgs.unfree.widevine-cdm}/share/google/chrome/WidevineCdm/manifest.json";
    #   target = ".kodi/cdm/manifest.json";
    # };
  };
}
