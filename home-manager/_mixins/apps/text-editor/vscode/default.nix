{ pkgs, lib, config, ... }@args:
with lib;
let
  cfg = config.custom.apps.vscode;
  nixgl = import ../../../../../lib/nixGL.nix { inherit config pkgs; };
  isGeneric = if (config.targets.genericLinux.enable) then true else false;

  settings-directory =
    if pkgs.stdenv.hostPlatform.isDarwin
    then "$HOME/Library/Application Support/Code/User"
    else "$HOME/.config/Code/User";
  defaultExtensions = { "remote.SSH.defaultExtensions" = map (x: x.vscodeExtUniqueId) extensions; };
  userSettings = (builtins.fromJSON (builtins.readFile ./settings.json)) // defaultExtensions;
  keybindings = builtins.fromJSON (builtins.readFile ./keybindings.json);
  extensions = import ./extensions.nix { inherit pkgs; };
in
{
  options.custom.apps.vscode = {
    enable = mkEnableOption "Whether enable vscode.";
  };
  config = mkIf cfg.enable {
    programs.vscode = {
      enable = true;
      package = if (isGeneric) then (nixgl pkgs.unstable.vscode) else pkgs.unstable.vscode;
      inherit userSettings extensions keybindings;
      mutableExtensionsDir = true;
      enableUpdateCheck = false;
      enableExtensionUpdateCheck = false;
      # userSettings = import ./settings.nix args;
    };

    home.activation = {
      beforeCheckLinkTargets = {
        after = [ ];
        before = [ "checkLinkTargets" ];
        data = ''
          if [ -f "${settings-directory}/settings.json" ]; then
            rm "${settings-directory}/settings.json"
          fi
          if [ -f "${settings-directory}/keybindings.json" ]; then
            rm "${settings-directory}/keybindings.json"
          fi
        '';
      };

      afterWriteBoundary = {
        after = [ "writeBoundary" ];
        before = [ ];
        data = ''
          cat ${(pkgs.formats.json {}).generate "settings.json" userSettings} > "${settings-directory}/settings.json"
          cat ${(pkgs.formats.json {}).generate "keybindings.json" keybindings} > "${settings-directory}/keybindings.json"
        '';
      };
    };

    ### Wayland
    # xdg = {
    #   desktopEntries = {
    #     codium = {
    #       name = "VSCodium";
    #       type = "Application";
    #       categories = [ "Utility" "TextEditor" "Development" "IDE" ];
    #       comment = "Code Editing. Redefined.";
    #       exec = ''sh -c "LD_LIBRARY_PATH=\\$NIX_LD_LIBRARY_PATH codium --enable-features=UseOzonePlatform --ozone-platform=wayland --enable-features=WaylandWindowDecorations"'';
    #       genericName = "Text Editor";
    #       icon = "vscodium";
    #       mimeType = [ "x-scheme-handler/vscode" ];
    #       noDisplay = false;
    #       startupNotify = true;
    #       terminal = false;
    #     };
    #   };
    # };
  };
}
