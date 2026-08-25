{ pkgs, ... }:
let
  build-host = import ./build-host.nix { inherit pkgs; };
  build-iso = import ./build-iso.nix { inherit pkgs; };
  switch-boot = import ./switch-boot.nix { inherit pkgs; };
  switch-host = import ./switch-host.nix { inherit pkgs; };
in
{
  environment = {
    systemPackages = with pkgs; [
      build-host
      build-iso
      switch-boot
      switch-host
    ];
  };
}
