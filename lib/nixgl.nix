{ config, inputs, lib, pkgs, nixgl, username, specialArgs, ... }:

# let

# nixGLMesaWrap = pkg:
#   pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
#     mkdir $out
#     ln -s ${pkg}/* $out
#     rm $out/bin
#     mkdir $out/bin
#     for bin in ${pkg}/bin/*; do
#      wrapped_bin=$out/bin/$(basename $bin)
#      echo "exec ${lib.getExe pkgs.nixgl.nixGLIntel} $bin \$@" > $wrapped_bin
#      chmod +x $wrapped_bin
#     done
#   '';

# nixGLVulkanWrap = pkg:
#   pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
#     mkdir $out
#     ln -s ${pkg}/* $out
#     rm $out/bin
#     mkdir $out/bin
#     for bin in ${pkg}/bin/*; do
#      wrapped_bin=$out/bin/$(basename $bin)
#      echo "exec ${
#        lib.getExe pkgs.nixgl.nixVulkanIntel
#      } $bin \$@" > $wrapped_bin
#      chmod +x $wrapped_bin
#     done
#   '';

# nixGLVulkanMesaWrap = pkg:
#   pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
#     mkdir $out
#     ln -s ${pkg}/* $out
#     rm $out/bin
#     mkdir $out/bin
#     for bin in ${pkg}/bin/*; do
#      wrapped_bin=$out/bin/$(basename $bin)
#      echo "${lib.getExe pkgs.nixgl.nixGLIntel} ${
#        lib.getExe pkgs.nixgl.nixVulkanIntel
#      } $bin \$@" > $wrapped_bin
#      chmod +x $wrapped_bin
#     done
#   '';

# in

with lib;
let
  cu = "${pkgs.coreutils}/bin";
  cfg = config.home.symlinks;

  toSymlinkCmd = destination: target: ''
    $DRY_RUN_CMD ${cu}/mkdir -p $(${cu}/dirname ${destination})
    $DRY_RUN_CMD ${cu}/ln -sf $VERBOSE_ARG \
      ${target} ${destination}
  '';
in {
  options = {
    home.symlinks = mkOption {
      type = types.attrsOf (types.str);
      description = "A list of symlinks to create.";
      default = { };
    };
  };

  config = {
    # nixGLMesaWrap = nixGLMesaWrap;
    fonts.fontconfig.enable = true;
    targets.genericLinux.enable = true;
    home = {
      packages = [
        # (import nixgl { inherit pkgs; }).nixGLIntel # OpenGL for GUI apps
        # (import nixgl { inherit pkgs; }).nixVulkanIntel # OpenGL for GUI apps
        # pkgs.nixGLVulkanMesaWrap
        # nixGLVulkanWrap
        # nixGLMesaWrap
        # (import nixgl { inherit pkgs; }).auto.nixGLDefault # OpenGL for GUI apps
        #.nixVulkanIntel
        pkgs.hello
        pkgs.comma
        pkgs.hostname
        config.nix.package
        pkgs.nixgl.auto.nixGLDefault
        # pkgs.sudo
      ];

      #file.".bash_aliases".text = ''
      #  alias alacritty="nixGLIntel ${pkgs.alacritty}/bin/alacritty"
      #'';                                                # Aliases for package using openGL (nixGL). home.shellAliases does not work

      activation = {
        # TODO Convert to config.lib.file.mkOutOfStoreSymlink ./path/to/file/to/link;
        # https://github.com/nix-community/home-manager/issues/257#issuecomment-831300021
        symlinks = hm.dag.entryAfter [ "writeBoundary" ]
          (concatStringsSep "\n" (mapAttrsToList toSymlinkCmd cfg));
        # Rebuild Script
        linkDesktopApplications = {
          # Add Packages To System Menu
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          # data = "sudo --preserve-env=PATH env /usr/bin/update-desktop-database"; # Updates Database
          # data = ''sudo -E env "PATH=$PATH" update-desktop-database'';
          # data = ''"$(which sudo)" -s -E env "PATH=$PATH/bin/" update-desktop-database'';
          data =
            "sudo --preserve-env=PATH env update-desktop-database"; # Updates Database
          # data = "doas --preserve-env=PATH /usr/bin/update-desktop-database"; # Updates Database
          # data = [ "${config.home.homeDirectory}/.nix-profile/share/applications"];
          # data = "/usr/bin/update-desktop-database";
        };
      };
    };

    xdg = let inherit (pkgs.stdenv) isDarwin;
    in {
      # Add Nix Packages to XDG_DATA_DIRS
      enable = true;
      mime = { enable = true; };
      systemDirs.data = if isDarwin then
        [ "/Users/${username}/.nix-profile/share/applications" ]
      else
        [ "/home/${username}/.nix-profile/share/applications" ];
    };

    # nixGLMesaWrap = nixGLMesaWrap;
    # nixGLVulkanWrap = nixGLVulkanWrap;
    # nixGLVulkanMesaWrap = nixGLVulkanMesaWrap;
  };
}
