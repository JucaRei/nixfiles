{ pkgs, lib, ... }:
with lib.hm.gvariant; {
  home.packages = with pkgs; [ handbrake ];
}
