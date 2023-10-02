_: {
  imports = [
    # ../_mixins/music/rhythmbox.nix
    # ../_mixins/browser/opera.nix
  ];
  home.shellAliases = {
    sudo = "doas";
  };
}
