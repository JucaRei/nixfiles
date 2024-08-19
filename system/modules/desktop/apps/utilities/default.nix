{
  lib,
  pkgs,
  username,
  ...
}:
let
  installFor = [ "juca" ];
in
lib.mkIf (builtins.elem username installFor) {
  environment.systemPackages = with pkgs; [
    gnome.dconf-editor
    pika-backup
    squirreldisk
    usbimager
  ];

  programs = {
    dconf.profiles.user.databases = [
      {
        settings = with lib.gvariant; {
          "ca/desrt/dconf-editor" = {
            show-warning = false;
          };
        };
      }
    ];
  };
}
