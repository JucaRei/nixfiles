{ pkgs, lib, inputs, ... }: {
  home = { packages = with pkgs.unstable; [ mailspring ]; };
}
