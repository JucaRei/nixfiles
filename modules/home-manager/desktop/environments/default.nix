{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib) mkIf optionals;
  isNixOS = osConfig != null;
in
{
  imports = [
    ./bspwm
    ./xfce4
    ./hyprland
    ../display-servers
  ];

  config = {

    home = {
      packages =
        optionals (!isNixOS) [
          (
            if (builtins ? currentTime && pkgs ? nixgl && pkgs.nixgl ? auto) then
              pkgs.nixgl.auto.nixGLDefault
            else
              (pkgs.writeShellScriptBin "nixGL" ''exec "$@"'')
          )
        ]
        ++ (with pkgs; [
          font-search # show existent fonts
          nerd-fonts.symbols-only
          nerd-fonts.jetbrains-mono
          inter
        ]);

      activation = {
        linkDestopApplications = mkIf (!isNixOS) (
          lib.hm.dag.entryAfter
            [
              "writeBoundary"
              "createXdgUserDirectories"
            ]
            ''
              mkdir -p "$HOME/.local/share/applications"
              ${pkgs.desktop-file-utils}/bin/update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
            ''
        );

        "user-dirs" = lib.hm.dag.entryBefore [ "writeBoundary" ] ''
          rm -f $VERBOSE_ARG "$HOME/.config/user-dirs.dirs.old"
        '';
      };

      sessionPath = [
        "$HOME/.local/bin"
      ];
    };

    xdg = {
      mimeApps.enable = true;
      mime.enable = true;
      systemDirs = {
        data = [ "${config.home.homeDirectory}/.nix-profile/share/applications" ];
        config = [ "/etc/xdg" ];
      };
    };

    fonts.fontconfig.enable = true;
    targets.genericLinux.enable = mkIf (!isNixOS) true;
  };
}
