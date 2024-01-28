{ config, stateVersion, nixpkgs, ... }: {
  imports = [ ../_mixins/console/fish.nix ];
  targets.genericLinux.enable = true;

  inherit stateVersion;

  home.file.".config/nix/nix.conf".text = ''
    experimental-features = nix-command flakes
  '';

  home.file.".nix".text = ''
    system.stateVersion = "${stateVersion}";
  '';

  systemd.user.tmpfiles.rules =
    [ "L+  %h/.nix-defexpr/nixos  -  -  -  -  ${nixpkgs}" ];
}
