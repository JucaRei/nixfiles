{ pkgs, ... }: {
  home = {
    packages = with pkgs.unstable; [
      mailspring
    ];
  };
}
