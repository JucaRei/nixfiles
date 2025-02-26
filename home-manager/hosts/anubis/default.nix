{ config, pkgs, ... }: {
  config = {
    # features.nonNixOs = {
    #   enable = true;
    # };
    console.yt-dlp-custom = {
      enable = true;
    };

    home = {
      packages = with pkgs; [
        (nerdfonts.override {
          fonts = [
            "FiraCode"
            "NerdFontsSymbolsOnly"
          ];
        })
      ];
    };
  };
}
