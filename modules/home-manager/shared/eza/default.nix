# { inputs, platform, ... }: {
{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.modules.eza;
in
{
  options.modules.eza = {
    enable = mkOption {
      default = true;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs.eza = {
      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;
      extraOptions = [
        "--group-directories-first"
        "--header"
      ];
      git = true;
      icons = true;
    };
    home = mkIf cfg.enable {
      # packages = with inputs; [
      #   fh.packages.${platform}.default
      #   eza.packages.${platform}.default
      # ];
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
