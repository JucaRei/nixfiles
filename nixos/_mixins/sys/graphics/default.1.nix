{ lib, config, username, ... }:
let
  inherit (lib) optional;
in
{
  imports = [
    ./amd
    ./intel
    ./nvidia
  ];

  options = {
    # features.graphics
  };

  config = {
    users.users.${username}.extraGroups = optional config.hardware.opengl.enable "video";
  };
}
