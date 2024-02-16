{
  config,
  lib,
  pkgs,
  nixpkgs,
  ...
}:
with lib; let
  cfg = config.modules.nonNixOs;

  cu = "${pkgs.coreutils}/bin";
  cfg-sym = config.home.symlinks;

  toSymlinkCmd = destination: target: ''
    $DRY_RUN_CMD ${cu}/mkdir -p $(${cu}/dirname ${destination})
    $DRY_RUN_CMD ${cu}/ln -sf $VERBOSE_ARG \
      ${target} ${destination}
  '';
in {
  options.modules.nonNixOs = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = with pkgs; [
        # nix
        # niv
        # nix
        nix-index
        nix-index-update
        nixpkgs-fmt
        # rnix-lsp
        nil
        # base-packages
        fzf
        # tmux
      ];
      file.".config/nix/nix.conf".text = ''
        experimental-features = nix-command flakes
      '';

      activation = {
        # TODO Convert to config.lib.file.mkOutOfStoreSymlink ./path/to/file/to/link;
        # https://github.com/nix-community/home-manager/issues/257#issuecomment-831300021
        symlinks =
          hm.dag.entryAfter ["writeBoundary"]
          (concatStringsSep "\n" (mapAttrsToList toSymlinkCmd cfg-sym));
        # Rebuild Script
        linkDesktopApplications = {
          # Add Packages To System Menu
          after = ["writeBoundary" "createXdgUserDirectories"];
          before = [];
          # data = "sudo --preserve-env=PATH env /usr/bin/update-desktop-database"; # Updates Database
          # data = ''sudo -E env "PATH=$PATH" update-desktop-database'';
          # data = ''"$(which sudo)" -s -E env "PATH=$PATH/bin/" update-desktop-database'';
          data = "sudo --preserve-env=PATH env update-desktop-database"; # Updates Database
          # data = "doas --preserve-env=PATH /usr/bin/update-desktop-database"; # Updates Database
          # data = [ "${config.home.homeDirectory}/.nix-profile/share/applications"];
          # data = "/usr/bin/update-desktop-database";
        };
      };
    };
    systemd.user.tmpfiles.rules = ["L+  %h/.nix-defexpr/nixos  -  -  -  -  ${nixpkgs}"];
    targets.genericLinux.enable = true;
  };
}
