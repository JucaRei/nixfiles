{ config, lib, pkgs, ... }:
{
  imports = [
    # ../_mixins/apps/text-editor/vscode/vscode.nix
    # "${fetchTarball "https://github.com/msteen/nixos-vscode-server/tarball/master"}/modules/vscode-server/home.nix"
  ];
  config = {
    services = {
      vscode-server = {
        enable = lib.mkForce true;
        enableFHS = lib.mkForce true;
        nodejsPackage = pkgs.nodejs-18_x;
        # extraRuntimeDependencies = pkgs: with pkgs; [
        #   nixpkgs-fmt # formatter
        #   nix-output-monitor # better output from builds
        #   nil # lsp server
        #   nix-direnv # A shell extension that manages your environment for nix
        #   git # versioning
        #   wget
        #   curl
        # ];
      };
      eza.enable = true;
      yt-dlp-custom.enable = true;
    };
  };
}
