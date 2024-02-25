{ pkgs, ... }: {
  config = {
    home.packages = with pkgs; [ (nixgl-legacy vlc) ];
    nix = {
      nix = { substituters = [ "https://juca-nixfiles.cachix.org" ]; };
      trusted-public-keys = [
        "juca-nixfiles.cachix.org-1:HN1wk6GxLI1ZPr3bN2RNa+a4jXwLGUPJG6zXKqDZ/Kc="
      ];
    };
  };
}
