# { lib, pkgs, hostname, storageDriver ? null, username, ... }:

# assert lib.asserts.assertOneOf "storageDriver" storageDriver [
#   null
#   "aufs"
#   "btrfs"
#   "devicemapper"
#   "overlay"
#   "overlay2"
#   "zfs"
# ];

{ lib, pkgs, hostname, username, ... }:
let
  dk-machine = pkgs.previous.docker-machine;
in

{
  virtualisation = {
    # oci-containers.backend = "docker";
    docker = {
      enable = true;
      # enableOnBoot = lib.mkDefault true;
      # enableNvidia = true;
      # extraOptions = "--default-runtime=nvidia";
      # rootless = {
      #   enable = false; # true;
      #   setSocketVariable = true;
      #   package = pkgs.docker;
      # };
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

  users.users.${username}.extraGroups = [ "docker" ];

  # https://rootlesscontaine.rs/getting-started/common/cgroup2/#enabling-cpu-cpuset-and-io-delegation
  # For minikube
  # Writes to /etc/systemd/system/user@.service.d/overrides.conf
  # systemd.services."user@".serviceConfig = {
  #   Delegate = "cpu cpuset io memory pids";
  # };

  environment.systemPackages = with pkgs; [
    docker-compose
    lazydocker
  ]
  ++ dk-machine
  ;
}
