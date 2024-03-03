{ pkgs, ... }: {
  imports = [ ../_mixins/non-nixos ];
  config = {
    home.packages = with pkgs; [ ];
    option.nonNixOs.enable = true;
    nix.settings = {
      extra-substituters = [ "https://juca-nixfiles.cachix.org" ];
      extra-trusted-public-keys = [
        "juca-nixfiles.cachix.org-1:HN1wk6GxLI1ZPr3bN2RNa+a4jXwLGUPJG6zXKqDZ/Kc="
      ];
    };
  };
}
