{ pkgs, ... }: {
  home = {
    packages = pkgs.unstable.mailspring;
  };
}
