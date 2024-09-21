{ config, pkgs, lib, ... }:
let
  inherit (lib) mkIf mkEnableOption optionalString mkOption types;
  cfg = config.sys.hardware.backlight;
in
{
  options.sys.hardware.backlight = {
    enable = mkEnableOption "enable backlight support" // { default = true; };
    backlight-opt = mkOption {
      type = types.nullOr (types.enum [ "light" "brillo" ]);
      default = "brillo";
      description = "Default backlight manager.";
    };
  };

  config = mkIf cfg.enable {
    programs = mkIf (cfg.backlight-opt == "light") {
      light.enable = true;
    };
    environment.systemPackages = with pkgs; [
      ddcutil
    ];

    hardware = mkIf (cfg.backlight-opt == "brillo") {
      brillo.enable = true;
    };

    boot.extraModulePackages = [ config.boot.kernelPackages.ddcci-driver ];
    boot.kernelModules = [ "i2c-dev" "ddcci_backlight" ];

    #region Nvidia Specific fix from https://discourse.nixos.org/t/ddcci-kernel-driver/22186/4
    services.udev.extraRules = optionalString (cfg.graphics.manufacturer == "nvidia") ''
      SUBSYSTEM=="i2c-dev", ACTION=="add",\
        ATTR{name}=="NVIDIA i2c adapter*",\
        TAG+="ddcci",\
        TAG+="systemd",\
        ENV{SYSTEMD_WANTS}+="ddcci@$kernel.service"
    '';

    systemd.services."ddcci@" = mkIf (cfg.graphics.manufacturer == "nvidia") {
      scriptArgs = "%i";
      script = ''
        echo Trying to attach ddcci to $1
        i=0
        id=$(echo $1 | cut -d "-" -f 2)
        if ${pkgs.ddcutil}/bin/ddcutil getvcp 10 -b $id; then
          echo ddcci 0x37 > /sys/bus/i2c/devices/$1/new_device
        fi
      '';
      serviceConfig.Type = "oneshot";
    };
    #endregion
  };
}
