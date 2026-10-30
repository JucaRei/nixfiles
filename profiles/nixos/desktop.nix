{
  lib,
  pkgs,
  ...
}:
let
  inherit (lib) mkDefault;
in
{
  config = {
    time.timeZone = mkDefault "America/Sao_Paulo";

    hardware = {
      audio = {
        enable = mkDefault true;
        manager = mkDefault "pipewire";
      };

      graphics.cards = {
        enable = mkDefault true;
        acceleration = mkDefault true;
      };

      enableRedistributableFirmware = mkDefault true;
    };

    programs = {
      fish.enable = mkDefault true;
      nix-ld = {
        enable = mkDefault true;
        libraries = mkDefault (
          with pkgs;
          [
            stdenv.cc.cc.lib
            zlib
            openssl
            curl
            glib
            util-linux
            icu
          ]
        );
      };
    };

    boot = {
      supportedFilesystems = mkDefault [
        "btrfs"
        "vfat"
        "ext4"
      ];
    };

    services = {
      timesyncd = {
        enable = mkDefault true;
        servers = mkDefault [
          "a.st1.ntp.br"
          "b.st1.ntp.br"
          "c.st1.ntp.br"
          "pool.ntp.org"
        ];
      };

      earlyoom = {
        enable = mkDefault true;
        freeMemThreshold = mkDefault 5;
        freeSwapThreshold = mkDefault 10;
      };

      irqbalance.enable = mkDefault true;
      acpid.enable = mkDefault true;
    };

    console.useXkbConfig = mkDefault true;
  };
}
