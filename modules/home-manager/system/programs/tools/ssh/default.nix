{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.system.programs.tools.ssh;
in
{
  options = {
    system.programs.tools.ssh = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enable's ssh configs.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      matchBlocks = {
        "*" = {
          compression = true;
          forwardAgent = true;
          serverAliveCountMax = 2;
          serverAliveInterval = 300;
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
      extraOptionOverrides = { Include = "local.d/*"; };
      extraConfig =
        ''
          AddKeysToAgent yes
        ''
        + lib.optionalString pkgs.stdenv.isDarwin ''
          IgnoreUnknown UseKeychain
          UseKeychain yes
        '';
    };

    # home.packages = with pkgs; [ mosh ];
  };
}
