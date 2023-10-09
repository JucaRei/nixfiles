{ lib
, pkgs
, hostname
, ...
}: {
  virtualisation = {
    # oci-containers.backend = "docker";
    docker = {
      enable = true;
      # enableOnBoot = lib.mkDefault true;
      # enableNvidia = true;
      rootless = {
        enable = true;
        setSocketVariable = true;
        # package = pkgs.docker;
      };
      # autoPrune = {
      #   enable = true;
      #   dates = "monthly";
      # };
      # extraOptions = "-H 0.0.0.0:2376 --tlsverify --tlscacert /run/keys/docker/ca.pem --tlscert /run/keys/docker/server-cert.pem --tlskey /run/keys/docker/server-key.pem";

      # https://docs.docker.com/build/buildkit/
      #daemon.settings = { "features" = { "buildkit" = true; }; };
      storageDriver = "overlay2";
      logDriver = "json-file";
    };
  };
  environment.systemPackages = with pkgs; [
    docker-machine
    docker-compose
    lazydocker
  ];
}
