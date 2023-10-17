{ pkgs, ... }: {
  imports = [
    ../_mixins/apps/text-editor/vscodium.nix
  ];

  home.packages = with pkgs; [
    thorium
  ];
}
