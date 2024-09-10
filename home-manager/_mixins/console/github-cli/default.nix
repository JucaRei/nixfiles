{ pkgs, config, lib, ... }:
let
  inherit (lib) mkOption mkIf types;
  cfg = config.custom.console.github-cli;
in
{
  options.custom.console.github-cli = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs = {
      gh = {
        enable = true;
        extensions = with pkgs; [ gh-markdown-preview ];
        settings = {
          editor = "micro";
          git_protocol = "ssh";
          prompt = "enabled";
        };
      };
    };
  };
}
