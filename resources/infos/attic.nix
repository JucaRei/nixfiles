{ config, pkgs, lib, inputs, ... }:
let
  # tokens https://docs.attic.rs/reference/atticadm-cli.html#atticadm-make-token
  getAdminToken = pkgs.writeShellScriptBin "attic-admin-token" ''
    atticd-atticadm make-token --sub "thicc-server" \
     --validity "1day" \
     --push "*" \
     --pull "*" \
     --delete "*" \
     --configure-cache-retention "*" \
     --create-cache "*" \
     --configure-cache "*" \
     --destroy-cache "*"
  '';

  atticAdminLogin = pkgs.writeShellScriptBin "attic-admin-login" ''
    TOKEN=$(${getAdminToken}/bin/attic-admin-token)
    attic login local https://cache.jrnet.win --set-default $token
  '';

in
{
  age.secrets.attic-creds.file = "${inputs.secrets}/secrets/attic-creds.age";
  age.secrets.attic-admin-token.file =
    "${inputs.secrets}/secrets/attic-admin-token.age";
  services.atticd = {
    enable = true;

    credentialsFile = config.age.secrets.attic-creds.path;

    # https://github.com/zhaofengli/attic/blob/main/server/src/config-template.toml
    settings = {
      listen = "[::]:8080";
      api-endpoint = "https://cache.jrnet.win";
      database.url = "postgres://atticd?host=/run/postgresql&user=atticd";

      storage = {
        type = "s3";
        bucket = "cache";
        region = "us-east-1";
        endpoint = "http://fatnas:7000";
      };

      # Data chunking
      #
      # Warning: If you change any of the values here, it will be
      # difficult to reuse existing chunks for newly-uploaded NARs
      # since the cutpoints will be different. As a result, the
      # deduplication ratio will suffer for a while after the change.
      chunking = {
        # The minimum NAR size to trigger chunking
        #
        # If 0, chunking is disabled entirely for newly-uploaded NARs.
        # If 1, all NARs are chunked.
        nar-size-threshold = 64 * 1024; # 64 KiB

        # The preferred minimum size of a chunk, in bytes
        min-size = 16 * 1024; # 16 KiB

        # The preferred average size of a chunk, in bytes
        avg-size = 64 * 1024; # 64 KiB

        # The preferred maximum size of a chunk, in bytes
        max-size = 256 * 1024; # 256 KiB
      };
    };
  };
  # https://github.com/xddxdd/nixos-config/blob/master/nixos/optional-apps/attic.nix
  services.postgresql = {
    ensureDatabases = [ "atticd" ];
    ensureUsers = [{
      name = "atticd";
      ensureDBOwnership = true;
      # ensurePermissions = { "DATABASE \"atticd\"" = "ALL PRIVILEGES"; };
    }];
  };

  systemd.services.atticd = {
    after = [ "postgresql.service" ];
    requires = [ "postgresql.service" ];
  };

  # stolen from https://github.com/heywoodlh/nixos-configs/blob/master/nixos/roles/nixos/cache.nix
  # and https://github.com/xddxdd/nixos-config/blob/master/nixos/optional-cron-jobs/rebuild-nixos-config.nix
  systemd.timers."nix-cache-build" = {
    wantedBy = [ "timers.target" ];
    timerConfig = {
      OnCalendar = "daily";
      Unit = "nix-cache-build.service";
    };
  };
  # TODO: figure out auto login need to have the attic module somehow expose atticadmWrapper

  # sudo systemctl start nix-cache-build.service
  systemd.services."nix-cache-build" = {
    path = with pkgs; [ git nixos-rebuild attic-client ];
    environment = {
      HOME = "/run/nix-cache-build";
      XDG_CONFIG_HOME = "/run/nix-cache-build/config";
    };
    script =
      let
        hosts = [ "framework" "nixos-john" "thicc-server" "graphicalIso" ];
        buildAndPush = host: ''
          echo "BUILDING ${host}"
          nixos-rebuild build --flake /tmp/nixos-configs#${host}
          attic push main ./result/
        '';
        buildSteps = lib.concatMapStringsSep "\n" buildAndPush hosts;
      in
      ''
        set -eu
        rm -rf /tmp/nixos-configs
        # if weird error make sure has no new lines (echo -n)
        attic login --set-default local https://cache.jrnet.win "$(cat ${config.age.secrets.attic-admin-token.path})"
        attic cache info main

        git clone https://github.com/JRMurr/NixOsConfig /tmp/nixos-configs
      '' + buildSteps + ''
        rm -rf /tmp/nixos-configs
      '';
    serviceConfig = {
      Type = "oneshot";
      # TODO: can probably remove this and enviorment settings
      RuntimeDirectory = "nix-cache-build";
      WorkingDirectory = "/run/nix-cache-build";
      RuntimeDirectoryPreserve = true;
      # User = "root";
    };
  };

  environment.systemPackages = [ atticAdminLogin ];
}
