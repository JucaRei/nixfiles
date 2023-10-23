{ pkgs, ... }: {
  imports = [
    # ../_mixins/apps/music/rhythmbox.nix
    ../_mixins/apps/text-editor/vscode.nix
    # ../_mixins/apps/browser/opera.nix
  ];
  home = {
    packages = with pkgs; [ thorium ];
    # shellAliases = {
    # sudo = "doas";
    # };
  };
}
