{ pkgs, ... }: {
  imports = [
    ./firefox
    ./chrome
  ];

  home = {
    # Add more fonts for any browser
    packages = with pkgs; [
      msttcorefonts
      (nerdfonts.override {
        fonts = [ "FiraCode" ];
      })
    ];
  };
}
