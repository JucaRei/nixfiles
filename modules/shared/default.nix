{ config, lib, platform, ... }: {
  config = {
    nixpkgs = {
      hostname = lib.mkDefault "${platform}";
      config = {
        allowUnfree = true;
        allowUnfreePredicate = _: true; # Workaround for https://github.com/nix-community/home-manager/issues/2942
        permittedInsecurePackages = [ "tightvnc-1.3.10" ];
        # allowInsecure = true
      };
    };
    nix = {
      settings = {
        experimental-features = [
          "flakes"
          "nix-command"
        ];
        system-features = [ ];
        keep-outputs = true;
        keep-derivations = true;
        keep-going = false;
        warn-dirty = false;
      };
    };
  };
}
