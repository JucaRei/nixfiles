{ lib, pkgs, config, ... }:
with lib.hm.gvariant;
let
  font-search = pkgs.writeShellScriptBin "font-search" ''
    fc-list \
        | grep -ioE ": [^:]*$1[^:]+:" \
        | sed -E 's/(^: |:)//g' \
        | tr , \\n \
        | sort \
        | uniq
  '';
in
{
  imports = [
    ../_mixins/non-nixos
    ../_mixins/console/yt-dlp.nix
    ../_mixins/console/bash.nix
    ../_mixins/apps/text-editor/vscode/vscode-unwrapped.nix
    ../_mixins/apps/browser/chrome/ungoogled-chromium.nix
    ../_mixins/apps/browser/firefox/firefox.nix
  ];

  config = {
    services = {
      nonNixOs.enable = true;
      yt-dlp-custom.enable = true;
      vscode-server.enable = true;
      bash.enable = true;
    };

    home = {
      keyboard = lib.mkForce {
        layout = "br,us";
        model = "pc105";
        options = [ "grp:shifts_toggle" ];
        variant = "abnt2,intl";
      };
      packages = with pkgs;[
        nix-whereis
        font-search
        stacer
        cachix
      ];
      file = {
        ".face" = {
          # source = ./face.jpg;
          source = "${pkgs.juca-avatar}/share/faces/juca.jpg";
        };
      };
    };
    programs.ungoogled.enable = true;
  };
}

# sudo --preserve-env=PATH env application
