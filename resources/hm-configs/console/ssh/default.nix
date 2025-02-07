{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.console.ssh;
in
{
  options.console.ssh = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
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
          user = "Reinaldo";
          identityFile = with config.home; "${homeDirectory}/.ssh/github";
          # identityFile = "~/.ssh/github_ed25519";
          # identitiesOnly = true;
        };
        "git.sr.ht" = {
          identityFile = with config.home; "${homeDirectory}/.ssh/sourcehut";
        };
        "gitlab.com" = {
          user = "Reinaldo";
          identityFile = with config.home; "${homeDirectory}/.ssh/gitlab";
        };
        "127.*.*.* 192.168.*.* 10.*.*.* 172.16.*.* 172.17.*.* 172.18.*.* 172.19.*.* 172.2?.*.* 172.30.*.* 172.31.*.*" = {
          extraOptions = {
            Stricthostkeychecking = "no";
            Userknownhostsfile = "/dev/null";
            LogLevel = "quiet";
          };
        };

        "*.lan" = {
          extraOptions = {
            Stricthostkeychecking = "no";
            Userknownhostsfile = "/dev/null";
            LogLevel = "quiet";
          };
        };
      };
    };

    home.packages = with pkgs; [ mosh ];
  };
}
