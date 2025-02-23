{ config, lib, ... }:
let
  inherit (lib) mkOption mkDefault mkIf;
  inherit (lib.types) listOf bool enum;
  cfg = config.system.time;
in
{
  options = {
    system.time = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Enable time services";
      };
      provider = mkOption {
        type = listOf (enum [ "geo" "chrony" ]);
        default = [ "chrony" ];
        description = "Time provider configuration";
      };
    };
  };
  config = mkIf cfg.enable {
    location = mkIf (cfg.provider == "geo") {
      provider = "geoclue2";
    };

    time = {
      timeZone = mkDefault "America/Sao_Paulo";
      hardwareClockInLocalTime = if (config.system.boot.isDualBoot == true) then true else false;
    };

    services = {
      chrony = mkIf (cfg.provider == "chrony") {
        # if time is wrong:
        # 1/ systemctl stop chronyd.service
        # 2/ "sudo chronyd -q 'pool pool.ntp.org iburst'"
        enable = true;

        # to correct big errors on startup
        initstepslew = {
          enabled = true;
          threshold = 100;
        };

        # we allow chrony to make big changes at
        # see https://chrony.tuxfamily.org/faq.html#_is_chronyd_allowed_to_step_the_system_clock
        extraConfig = ''
          makestep 1 -1
        '';
        servers = [
          "time.cloudflare.com"
          "time.google.com"
          "0.pool.ntp.org"
          "1.pool.ntp.org"
          "2.pool.ntp.org"
          "3.pool.ntp.org"
        ];
      };

      automatic-timezoned.enable = true;
      geoclue2 = mkIf (cfg.provider == "geo") {
        enable = true;
        # https://github.com/NixOS/nixpkgs/issues/321121
        geoProviderUrl = "https://beacondb.net/v1/geolocate";
        submissionNick = "geoclue";
        submissionUrl = "https://beacondb.net/v2/geosubmit";
      };
      localtimed.enable = mkIf (cfg.provider == "geo") true;
    };
  };
}
