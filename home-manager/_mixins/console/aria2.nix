{ pkgs, lib, ... }:
with lib.hm.gvariant; {
  home = {
    packages = with pkgs; ([
      aria2
    ]);
  };
  programs.aria2 = {
    enable = true;
    settings = {
      listen-port = "6881-6999";
      dht-listen-port = "6881-6999";
    };
  };
}

