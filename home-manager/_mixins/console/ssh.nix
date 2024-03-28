{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.ssh;
in
{
  options.services.ssh = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = {
    programs.ssh = {
      enable = true;
      compression = true;
      forwardAgent = true;
      serverAliveCountMax = 2;
      serverAliveInterval = 300;
      extraOptionOverrides = { Include = "local.d/*"; };
      extraConfig =
        ''
          AddKeysToAgent yes
        ''
        + lib.optionalString pkgs.stdenv.isDarwin ''
          IgnoreUnknown UseKeychain
          UseKeychain yes
        '';
      matchBlocks = {
        "github.com" = {
          identityFile = with config.home; "${homeDirectory}/.ssh/github";
        };
        "git.sr.ht" = {
          identityFile = with config.home; "${homeDirectory}/.ssh/sourcehut";
        };
        "gitlab.com" = {
          identityFile = with config.home; "${homeDirectory}/.ssh/gitlab";
        };
      };
    };

    home.packages = with pkgs; [ mosh ];
  };
}
