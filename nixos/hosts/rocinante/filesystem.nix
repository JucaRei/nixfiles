{ lib, pkgs, ... }: {
  fileSystems =
    let
      btrfsOpts = [
        "rw"
        "noatime"
        "ssd"
        "compress-force=zstd:2"
        "space_cache=v2"
        "commit=120"
        "discard=async"
      ];
    in
    {
      "/boot/efi" = {
        device = lib.mkForce "/dev/disk/by-label/EFI";
        fsType = "vfat";
        options = [
          "defaults"
          "umask=0077"
          "noatime"
          "nodiratime"
          "nofail"
          "x-systemd.automount"
        ];
      };
      "/" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@" ];
      };
      "/home" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@home" ];
      };
      "/.snapshots" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@snapshots" ];
      };
      "/nix" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@nix" ];
      };
      "/var/log" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [ "subvol=@var_log" ];
      };

      "/swap" = {
        device = lib.mkForce "/dev/disk/by-label/NixOS";
        fsType = "btrfs";
        options = btrfsOpts ++ [
          "subvol=@swap"
          "nofail"
        ];
      };
    };

  # Garante a criação do swapfile no BTRFS antes do swap.target sem causar ciclos de dependência
  systemd.services.btrfs-swapfile-init = {
    description = "Create BTRFS swapfile on @swap if not present";
    unitConfig.DefaultDependencies = false;
    after = [ "local-fs.target" ];
    before = [ "swap.target" ];
    wantedBy = [ "swap.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = pkgs.writeShellScript "create-btrfs-swapfile" ''
        if [ ! -f /swap/swapfile ]; then
          ${pkgs.btrfs-progs}/bin/btrfs filesystem mkswapfile --size 6G /swap/swapfile
        fi
      '';
    };
  };

  swapDevices = [
    {
      device = "/swap/swapfile";
      priority = 10; # Fallback de emergência: usado APENAS se ZRAM (prioridade 100) encher
      options = [ "nofail" ]; # Evita travar o boot em emergency mode caso o swapfile ainda não esteja pronto
    }
  ];
}
