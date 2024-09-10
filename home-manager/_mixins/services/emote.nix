{ pkgs, lib, config, ... }:
with lib;
let
  cfg = config.custom.services.emote;
in
{
  options.custom.services.emote = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    # https://github.com/tom-james-watson/emote
    home.packages = with pkgs.unstable; [ emote ];

    systemd.user.services = {
      emote = {
        Unit = { Description = "Emote"; };
        Service = {
          ExecStart = "${pkgs.unstable.emote}/bin/emote";
          Restart = "on-failure";
        };
        Install = { WantedBy = [ "default.target" ]; };
      };
    };
  };
}
