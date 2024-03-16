{ lib, pkgs, inputs, ... }: {
  imports = [
    # ../../_mixins/hardware/bluetooth
    ../../_mixins/hardware/sound/pipewire.nix
    ../../_mixins/apps/text-editor/vscode.nix
    ../../_mixins/virtualization/podman.nix
    ../../_mixins/virtualization/lxd.nix
  ];

  boot = {
    kernelPackages = lib.mkOverride 0 pkgs.linuxPackages_latest;
    # kernelPackages = lib.mkOverride 0 inputs.chaotic.packages.${pkgs.system}.linuxPackages_cachyos;
    supportedFilesystems = [ "bcachefs" "zfs" "btrfs" ];
    # kernelParams = [ "nomodeset" ];
  };

  environment.systemPackages = with pkgs; [
    unstable.bcachefs-tools
    keyutils
  ];
  # nixpkgs.platform = lib.mkDefault "x86_64-linux";

  # Makes `availableOn` fail for zfs, see <nixos/modules/profiles/base.nix>.
  # This is a workaround since we cannot remove the `"zfs"` string from `supportedFilesystems`.
  # The proper fix would be to make `supportedFilesystems` an attrset with true/false which we
  # could then `lib.mkForce false`
  # - https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/installer/cd-dvd/installation-cd-minimal-new-kernel-no-zfs.nix
  nixpkgs.overlays = [
    (_final: super: {
      zfs = super.zfs.overrideAttrs (_: {
        meta.platforms = [ ];
      });
    })
  ];

  zramSwap = {
    algorithm = "lz4";
    memoryPercent = 75;
    enable = true;
  };

  # nix.settings = {
  #   extra-substituters = [ "https://nyx.chaotic.cx/" ];
  #   extra-trusted-public-keys = [ "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8=" ];
  # };
}

# nom build .#nixosConfigurations.iso-gnome.config.system.build.isoImage --option 'extra-substituters' 'https://nyx.chaotic.cx/' --option extra-trusted-public-keys "chaotic-nyx.cachix.org-1:HfnXSw4pj95iI/n17rIDy40agHj12WfF+Gqk6SonIT8="
