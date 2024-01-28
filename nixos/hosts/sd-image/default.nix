# save as sd-image.nix somewhere
{ ... }: {
  imports = [ <nixpkgs/nixos/modules/installer/sd-card/sd-image-aarch64.nix> ];
  # put your own configuration here, for example ssh keys:
  users.users.root.openssh.authorizedKeys.keys =
    [ "ssh-ed25519 AAAAC3NzaC1lZDI1.... username@tld" ];
}
