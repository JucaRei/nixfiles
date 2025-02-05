{ lib, namespace, ... }:
with lib.${namespace};
{
  excalibur = {
    suites = {
      common = enabled;
      development = enabled;
    };

    desktop.yabai = enabled;
  };

  environment.systemPath = [ "/opt/homebrew/bin" ];

  system.stateVersion = 4;
}
