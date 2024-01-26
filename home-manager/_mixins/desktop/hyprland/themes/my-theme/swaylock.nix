{ pkgs, lib, ... }:
let ui = import ./wlogout/ui.nix { };
in {
  # programs.swaylock = {
  #   enable = true;
  #   # package = pkgs.unstable.swaylock-effects;
  #   package = pkgs.swaylock;
  #   settings = with ui; {
  #     clock = true;
  #     font = "${font}";
  #     screenshots = true;
  #     daemonize = true;
  #     disable-caps-lock-text = true;
  #     ignore-empty-password = true;
  #     indicator = true;
  #     indicator-radius = 100;
  #     indicator-thickness = 6;
  #     effect-blur = "7x5";
  #     effect-vignette = "0.5:0.5";
  #     ring-color = "${border-color}";
  #     text-color = "${foreground-color}";
  #     text-ver-color = "${foreground-color}";
  #     text-wrong-color = "${colors.red}";
  #     line-color = "00000000";
  #     inside-color = "${colors.background}";
  #     inside-ver-color = "${colors.background}";
  #     inside-wrong-color = "${colors.background}";
  #     separator-color = "00000000";
  #   };
  # };

  # services.swayidle = {
  #   enable = true;
  #   events = [
  #     {
  #       event = "before-sleep";
  #       command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
  #     }
  #     {
  #       event = "lock";
  #       command = "${pkgs.swaylock-effects}/bin/swaylock -fF";
  #     }
  #   ];
  #   timeouts = [
  #     {
  #       timeout = 30;
  #       command = "swaylock";
  #     }
  #     {
  #       timeout = 600;
  #       command = "systemctl suspend";
  #     }
  #   ];
  # };

  services.swayidle =
    let
      lockCommand = "${pkgs.lockman}/bin/lockman.sh &";
    in
    {
      enable = true;
      systemdTarget = "hyprland-session.target";
      timeouts =
        let
          dpmsCommand = "${pkgs.hyprland}/bin/hyprctl dispatch dpms";
        in
        [
          {
            timeout = 300;
            command = lockCommand;
          }
          {
            timeout = 600;
            command = "${dpmsCommand} off";
            resumeCommand = "${dpmsCommand} on";
          }
        ];
      events = [
        {
          event = "before-sleep";
          command = lockCommand;
        }
      ];
    };

  systemd.user.services.swayidle.Install.WantedBy =
    lib.mkForce [ "hyprland-session.target" ];
  # lib.mkForce [ "graphical-session.target" ];
}
