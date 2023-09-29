{ config, inputs, pkgs, nixgl, username, ... }:

{
  home = {
    packages =
      [
        (import nixgl { inherit pkgs; }).nixGLIntel # OpenGL for GUI apps
        #.nixVulkanIntel
        pkgs.hello
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
          data = "sudo /usr/bin/update-desktop-database"; # Updates Database
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
      systemDirs.data =
        if isDarwin then
          [ "/Users/${username}" ]
        else
          [ "/home/${username}" ];
    };
}
