{ config, pkgs, lib, ... }:
let
  rofi-nm = pkgs.fetchurl {
    url =
      "https://raw.githubusercontent.com/P3rf/rofi-network-manager/1daa69406c9b6539a4744eafb0d5bb8afdc80e9b/rofi-network-manager.sh";
    hash = "sha256:1nlnjmk5b743j5826z2nzfvjwk0fmbf7gk38darby93kdr3nv5zx";
  };
  package = pkgs.writeShellScriptBin "rofi-nm" ''
    ${config.home.homeDirectory}/.config/rofi-nm/rofi-nm.sh
  '';
in {
  options = {
    programs.rofi-nm.package = lib.mkOption { type = lib.types.package; };
  };
  config = {
    programs.rofi-nm.package = package;

    home.packages = [ package ];

    xdg.configFile = {
      ".config/rofi/scripts/rofi-nm.sh" = {
        source = pkgs.runCommandLocal "rofi-nm" { } ''
          cp --no-preserve=mode,ownership ${rofi-nm} rofi-nm.sh
          substituteInPlace rofi-nm.sh \
            --replace "#!/bin/bash" "#!${pkgs.stdenv.shell}" \
            --replace "grep" "${pkgs.gnugrep}/bin/grep"
          mv rofi-nm.sh $out
        '';
        executable = true;
      };
    };
  };
}
