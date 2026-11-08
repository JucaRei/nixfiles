# Advanced host-specific configurations for anubis
{ pkgs, ... }:
{
  config = {
    home.keyboard = {
      layout = "us";
      variant = "intl";
      model = "apple";
    };

    desktop.wayland.noctalia.settings = {
      idle = {
        behavior_order = [
          "lock"
          "screen-off"
          "suspend"
        ];
        pre_action_fade_seconds = 0.0;
        behavior = {
          lock = {
            timeout = 300;
            action = "lock";
            enabled = true;
          };
          screen-off = {
            timeout = 450;
            action = "command";
            command = "${pkgs.brightnessctl}/bin/brightnessctl -s set 0%";
            resume_command = "${pkgs.brightnessctl}/bin/brightnessctl -r";
            enabled = true;
          };
          suspend = {
            timeout = 900;
            action = "suspend";
            enabled = true;
          };
        };
      };
      audio = {
        enable_overdrive = true;
        enable_sounds = false;
        sound_volume = 0.5;
        volume_change_sound = "";
        notification_sound = "";
      };
      location = {
        auto_locate = true;
        address = "São Paulo, Brazil";
        latitude = -23.6293;
        longitude = -46.6351;
      };
    };
  };
}
