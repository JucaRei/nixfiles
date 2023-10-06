{ username, ... }: {
  security = {
    sudo.enable = false; # Disable sudo

    doas = {
      enable = true;
      extraConfig = ''
        permit nopass :wheel
      '';
      extraRules = [{
        users = [ username ];
        noPass = true;
        keepEnv = true;
      }];
      #wheelNeedsPassword = false;
    };
  };
  environment.shellAliases = { sudo = "doas"; };
}
