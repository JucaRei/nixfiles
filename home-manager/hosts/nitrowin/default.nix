{ pkgs, ... }: {
  features = {
    nonNixOs.enable = true;
  };
  home = {
    packages = with pkgs; [
      speedtest-custom
    ];
  };
}
