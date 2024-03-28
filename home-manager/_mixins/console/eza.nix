# { inputs, platform, ... }: {
{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.eza;
in
{
  options.services.eza = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    home = {
      # packages = with inputs; [
      #   fh.packages.${platform}.default
      #   eza.packages.${platform}.default
      # ];
      packages = with pkgs.unstable; [ eza ];
      shellAliases = {
        ls = "eza --icons -l -T -h -L=1";
        lt = "eza --icons -l --time-style long-iso -a -h";
        lf = "eza --icons -l --time-style long-iso -a -h -f";
        # ls = "eza --icons -Slhga";
        l = "eza --icons -l --time-style long-iso -a -h";
        la = "eza --icons -l --time-style long-iso -a";
        ll = "eza --icons -l";
        lla = "eza --icons -la";
        tree = "eza --icons --tree -l";
      };
    };
  };
}
