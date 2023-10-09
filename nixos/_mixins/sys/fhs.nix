{ pkgs, ... }: {
  imports = [ ./fhs-fonts.nix ];
  environment = {
    systemPackages = with pkgs; [
      ### FHS
      # Create an FHS environment using the command `fhs`, enabling the execution of non-NixOS packages in NixOS!
      (
        let
          base = pkgs.appimageTools.defaultFhsEnvArgs;
        in
        pkgs.buildFHSUserEnv (base
          // {
          name = "fhs";
          targetPkgs = pkgs: (
            # pkgs.buildFHSUserEnv provides only a minimal FHS environment,
            # lacking many basic packages needed by most software.
            # Therefore, we need to add them manually.
            #
            # pkgs.appimageTools provides basic packages required by most software.
            (base.targetPkgs pkgs)
              ++ (with pkgs; [
              pkg-config
              ncurses
              # Feel free to add more packages here if needed.
            ])
          );
          profile = "export FHS=1";
          runScript = "bash";
          extraOutputsToInstall = [ "dev" ];
        })
      )

      # Activating FHS drops me into a shell that resembles a "normal" Linux environment.
      # $ fhs
      # Check what we have in /usr/bin.
      # (fhs) $ ls /usr/bin
      # Try running a non-NixOS binary downloaded from the Internet.
      # (fhs) $ ./bin/code
    ];
  };
}
