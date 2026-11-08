# lib/disk/btrfs.nix — gerador parametrizado de particionamento Disko e fileSystems Btrfs
{
  device ? "/dev/sda",
  tableType ? "gpt", # "gpt" ou "msdos"
  diskLabel ? "main",
  btrfsLabel ? "NixOS",
  swapLabel ? "swap",
  efiLabel ? "EFI",
  swapSize ? "6G",
  swapPriority ? 10,
  swapOptions ? [ "nofail" ],
  compression ? "zstd:2",
  luks ? null,
  subvolumes ? {
    "@" = "/";
    "@home" = "/home";
    "@snapshots" = "/.snapshots";
    "@nix" = "/nix";
    "@var_log" = "/var/log";
  },
  extraBtrfsOpts ? [ ],
  btrfsMountOpts ? [
    "noatime"
    "nodiratime"
    "ssd"
    "compress-force=${compression}"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ]
  ++ extraBtrfsOpts,
  fsBtrfsOpts ? [
    "rw"
    "noatime"
    "ssd"
    "compress-force=${compression}"
    "space_cache=v2"
    "commit=120"
    "discard=async"
  ]
  ++ extraBtrfsOpts,
  swapDevicesEnable ? (tableType != "msdos"),
}:
{ config, lib, ... }:
let
  subvolConfig = lib.mapAttrs (_name: mountpoint: {
    inherit mountpoint;
    mountOptions = btrfsMountOpts;
  }) subvolumes;

  btrfsContent = {
    type = "btrfs";
    extraArgs = [
      "-L"
      btrfsLabel
      "-f"
    ];
    subvolumes = subvolConfig;
  };

  rootContent =
    if luks != null then
      {
        type = "luks";
        name = if builtins.isString luks then luks else (luks.name or "crypted");
        extraOpenArgs = luks.extraOpenArgs or [ ];
        settings = luks.settings or { allowDiscards = true; };
        content = btrfsContent;
      }
    else
      btrfsContent;

  gptContent = {
    type = "gpt";
    partitions = {
      boot = {
        name = "BIOS-BOOT";
        size = "2M";
        type = "EF02";
      };
      ESP = {
        name = "ESP";
        label = efiLabel;
        size = "512M";
        type = "EF00";
        content = {
          type = "filesystem";
          format = "vfat";
          mountpoint = "/boot/efi";
          mountOptions = [
            "defaults"
            "umask=0077"
            "noatime"
            "nodiratime"
          ];
        };
      };
      swap = {
        name = "swap";
        size = swapSize;
        content = {
          type = "swap";
          extraArgs = [
            "-L"
            swapLabel
          ];
          priority = swapPriority;
        };
      };
      root = {
        name = btrfsLabel;
        size = "100%";
        content = rootContent;
      };
    };
  };

  msdosContent = {
    type = "table";
    format = "msdos";
    partitions = [
      {
        name = "swap";
        part-type = "primary";
        fs-type = "linux-swap";
        start = "1M";
        end = swapSize;
        content = {
          type = "swap";
          extraArgs = [
            "-L"
            swapLabel
          ];
          priority = swapPriority;
        };
      }
      {
        name = btrfsLabel;
        part-type = "primary";
        fs-type = "btrfs";
        start = swapSize;
        end = "100%";
        bootable = true;
        content = rootContent;
      }
    ];
  };

  subvolFs = lib.mapAttrs' (subvol: mountpoint: {
    name = mountpoint;
    value = {
      # Justification: Override disko generated disk path with predictable filesystem label
      device = lib.mkForce "/dev/disk/by-label/${btrfsLabel}";
      fsType = "btrfs";
      options = fsBtrfsOpts ++ [ "subvol=${subvol}" ];
    };
  }) subvolumes;

  efiFs = {
    "/boot/efi" = {
      # Justification: Override disko generated EFI partition path with predictable filesystem label
      device = lib.mkForce "/dev/disk/by-label/${efiLabel}";
      fsType = "vfat";
      options = [
        "defaults"
        "umask=0077"
        "noatime"
        "nodiratime"
      ];
    };
  };
in
{
  disko.devices = {
    disk = {
      ${diskLabel} = {
        type = "disk";
        inherit device;
        content = if tableType == "msdos" then msdosContent else gptContent;
      };
    };
  };

  fileSystems =
    subvolFs
    // (lib.optionalAttrs (
      tableType != "msdos" && (config.system.boot.bootType or "") != "legacy"
    ) efiFs);

  swapDevices =
    lib.mkIf (swapSize != null && swapSize != "" && swapSize != "0" && swapDevicesEnable)
      [
        {
          device = "/dev/disk/by-label/${swapLabel}";
          priority = swapPriority;
          options = swapOptions;
        }
      ];
}
