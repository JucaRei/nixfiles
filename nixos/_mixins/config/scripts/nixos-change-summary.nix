{ pkgs, ... }:
let
  nixos-change-summary = pkgs.writeShellScriptBin "nixos-change-summary" ''
    BUILDS=$(${pkgs.coreutils-full}/bin/ls -d1v /nix/var/nix/profiles/system-*-link | tail -n 2)
    ${pkgs.nvd}/bin/nvd diff ''${BUILDS}
  '';
in
{ environment.systemPackages = with pkgs; [ nixos-change-summary ]; }
