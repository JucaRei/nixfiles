{ pkgs, ... }: {
  programs.adb.enable = true;
  services.udev.packages = with pkgs; [
    android-udev-rules
    adbfs-rootless
    android-file-transfer
  ];
  nixpkgs.config.android_sdk.accept_license = true;
}
