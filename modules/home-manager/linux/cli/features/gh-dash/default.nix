{ pkgs, config, lib, ... }:
with lib;
let
  cfg = config.modules.gh-dash;
in
{
  options.modules.gh-dash = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    programs = {
      gh = {
        enable = true;
        extensions = with pkgs; [
          gh-dash
          gh-markdown-preview
        ];
        settings = {
          editor = "micro";
          git_protocol = "ssh";
          prompt = "enabled";
        };
      };
    };
    home.file."${config.xdg.configHome}/gh-dash/config.yml".text = builtins.readFile ../../../../../../resources/configs/github-dash/gh-dash-catppuccin-mocha-blue.yml;
  };
}
