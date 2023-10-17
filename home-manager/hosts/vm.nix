{ pkgs, ... }: {
  imports = [
    ../_mixins/apps/text-editor/vscode.nix
  ];

  home.packages = with pkgs; [
    thorium
  ];
}
