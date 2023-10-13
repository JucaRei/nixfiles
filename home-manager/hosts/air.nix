_: {
  imports = [
    # ../_mixins/apps/music/rhythmbox.nix
    ../_mixins/apps/browser/opera.nix
  ];
  home.shellAliases = {
    sudo = "doas";
  };
}
