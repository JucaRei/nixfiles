{ lib, pkgs, username, ... }:
{
  imports = lib.optional (builtins.pathExists (./. + "/${username}")).${username};

  home = {
    packages = with pkgs; [
      speedtest-go
    ];
  };
}
