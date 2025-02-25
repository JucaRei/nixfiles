{ config, lib, username, ... }:
let
  inherit (lib) mkIf mkOption optional;
  inherit (lib.types) bool;
  hasNvidiaGPU = lib.elem "nvidia" config.services.xserver.videoDrivers;
  cfg = config.system.services.virtualisation.incus;
in
# lib.mkIf (lib.elem "${username}" installFor)

{
  options.system.services.virtualisation.incus = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Whether enable incus";
    };
  };

  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/Incus
    # - See also: nixos/_mixins/features/network/default.nix
    hardware.nvidia-container-toolkit.enable = hasNvidiaGPU;
    virtualisation = {
      incus = {
        enable = true;
        socketActivation = true;
        ui.enable = true;
      };
    };

    users.users.${username}.extraGroups = optional config.virtualisation.incus.enable "incus-admin";
  };
}
