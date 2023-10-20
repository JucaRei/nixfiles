{ pkgs, ... }: {
  imports = [
    ../_mixins/apps/text-editor/vscodium.nix
    ../_mixins/apps/browser/brave.nix
    ../_mixins/apps/terminal/alacritty.nix
  ];

  home.packages = with pkgs; [
    # thorium
  ];
}
