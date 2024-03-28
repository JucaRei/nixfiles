{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.services.github-cli;
in
{
  options.services.github-cli = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
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
