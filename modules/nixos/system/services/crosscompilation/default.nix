{ config, lib, pkgs, ... }:
let
  inherit (lib) mkOption types mkIf mkEnableOption optionalAttrs optional optionals;
  inherit (lib.types) bool listOf str;
  cfg = config.system.services.crosscompilation;
  system = config.system;

  isArm = system == "armv7l";
  isArm64 = system == "aarch64";
  isRiscv64 = system == "riscv64";

  arm = {
    interpreter = "${pkgs.qemu-user-arm}/bin/qemu-arm";
    magicOrExtension = ''\x7fELF\x01\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\x28\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
  };
  aarch64 = {
    interpreter = "${pkgs.qemu-user-arm64}/bin/qemu-aarch64";
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xb7\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
  };
  riscv64 = {
    interpreter = "${pkgs.qemu-riscv64}/bin/qemu-riscv64";
    magicOrExtension = ''\x7fELF\x02\x01\x01\x00\x00\x00\x00\x00\x00\x00\x00\x00\x02\x00\xf3\x00'';
    mask = ''\xff\xff\xff\xff\xff\xff\xff\x00\xff\xff\xff\xff\xff\xff\x00\xff\xfe\xff\xff\xff'';
  };
in
{
  options = {
    system.services.crosscompilation = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enables cross compilation of nix builds";
      };
      platform = mkOption {
        type = listOf str;
        default = [ ];
        description = "Platforms to cross compile when building";
      };
      qemu-user = {
        arm = mkEnableOption "enable 32bit arm emulation";
        aarch64 = mkEnableOption "enable 64bit arm emulation";
        riscv64 = mkEnableOption "enable 64bit riscv emulation";
      };
      nix.supportedPlatforms = mkOption {
        type = listOf str;
        description = "extra platforms that nix will run binaries for";
        default = [ ];
      };
    };
  };

  config = mkIf cfg.enable {
    boot = {
      binfmt = {
        emulatedSystems = [ cfg.platform ];
        registrations = optionalAttrs isArm { inherit arm; } //
          optionalAttrs isArm64 { inherit aarch64; } //
          optionalAttrs isRiscv64 { inherit riscv64; };
      };
    };

    nix =
      let
        supportedPlatforms = (optionals isArm [ "armv6l-linux" "armv7l-linux" ])
          ++ (optional isArm64 "aarch64-linux");
      in
      {
        extraOptions = ''
          extra-platforms = ${toString config.nix.supportedPlatforms} i686-linux
        '';

        sandboxPaths = [ "/run/binfmt" ] ++ (optional isArm "${pkgs.qemu-user-arm}") ++ (optional isArm64 "${pkgs.qemu-user-arm64}");
      };
  };
}
