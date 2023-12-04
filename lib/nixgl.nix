{ config, inputs, lib, pkgs, nixgl, username, specialArgs, ... }:

let

  nixGLMesaWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "exec ${lib.getExe pkgs.nixgl.nixGLIntel} $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';

  nixGLVulkanWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "exec ${
         lib.getExe pkgs.nixgl.nixVulkanIntel
       } $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';

  nixGLVulkanMesaWrap = pkg:
    pkgs.runCommand "${pkg.name}-nixgl-wrapper" { } ''
      mkdir $out
      ln -s ${pkg}/* $out
      rm $out/bin
      mkdir $out/bin
      for bin in ${pkg}/bin/*; do
       wrapped_bin=$out/bin/$(basename $bin)
       echo "${lib.getExe pkgs.nixgl.nixGLIntel} ${
         lib.getExe pkgs.nixgl.nixVulkanIntel
       } $bin \$@" > $wrapped_bin
       chmod +x $wrapped_bin
      done
    '';

in 
{
  nixGLMesaWrap = nixGLMesaWrap;
  fonts.fontconfig.enable = true;
  targets.genericLinux.enable = true;
  home = {
    packages =
      [
        # (import nixgl { inherit pkgs; }).nixGLIntel # OpenGL for GUI apps
        # (import nixgl { inherit pkgs; }).nixVulkanIntel # OpenGL for GUI apps
        # pkgs.nixGLVulkanMesaWrap
        # nixGLVulkanWrap
        # nixGLMesaWrap
        # (import nixgl { inherit pkgs.auto; }).nixGLDefault # OpenGL for GUI apps
        #.nixVulkanIntel
        pkgs.hello
        # pkgs.sudo
      ];

    #file.".bash_aliases".text = ''
    #  alias alacritty="nixGLIntel ${pkgs.alacritty}/bin/alacritty"
    #'';                                                # Aliases for package using openGL (nixGL). home.shellAliases does not work

    activation =
      {
        # Rebuild Script
        linkDesktopApplications = {
          # Add Packages To System Menu
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          data = "sudo --preserve-env=PATH  /usr/bin/update-desktop-database"; # Updates Database
          # data = "doas --preserve-env=PATH /usr/bin/update-desktop-database"; # Updates Database
          # data = [ "${config.home.homeDirectory}/.nix-profile/share/applications"];     
          # data = "/usr/bin/update-desktop-database";
        };
      };
  };

  xdg =
    let
      inherit (pkgs.stdenv) isDarwin;
    in
    {
      # Add Nix Packages to XDG_DATA_DIRS
      enable = true;
      mime = {
        enable = true;
      };
      systemDirs.data =
        if isDarwin then
          [ "/Users/${username}/.nix-profile/share/applications" ]
        else
          [ "/home/${username}/.nix-profile/share/applications" ];
    };

  # nixGLMesaWrap = nixGLMesaWrap;
  # nixGLVulkanWrap = nixGLVulkanWrap;
  # nixGLVulkanMesaWrap = nixGLVulkanMesaWrap;

}
