{ pkgs, ... }: {
  home = {
    packages = with pkgs; [
      speedtest-custom
    ];
  };
}
