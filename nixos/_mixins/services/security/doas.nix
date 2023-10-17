{ username, pkgs, config, ... }: {
  security = {
    sudo.enable = false; # Disable sudo

    doas = {
      enable = true;
      # extraConfig = ''
      # permit nopass :wheel
      # '';
      extraRules = [{
        users = [ "${username}" ];
        # noPass = true;
        keepEnv = true;
        persist = true;
      }];
      #wheelNeedsPassword = false;
    };
  };
  environment.systemPackages = [
    (pkgs.writeScriptBin "sudo" ''exec doas "$@"'')
  ];
}
