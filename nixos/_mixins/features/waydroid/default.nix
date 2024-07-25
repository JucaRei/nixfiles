{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.services.waydroid;

  waydroid-ui = pkgs.writeShellScriptBin "waydroid-ui" ''
    export WAYLAND_DISPLAY=wayland-0
    ${pkgs.weston}/bin/weston -Swayland-1 --width=600 --height=1000 --shell="kiosk-shell.so" &
    WESTON_PID=$!

    export WAYLAND_DISPLAY=wayland-1
    ${pkgs.waydroid} /bin/waydroid show-full-ui &

    wait $WESTON_PID
    waydroid session stop
  '';
in
{
  options.services.waydroid = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [
      waydroid
      waydroid-ui
    ];

    virtualisation.waydroid = {
      enable = true;
    };
  };
}
