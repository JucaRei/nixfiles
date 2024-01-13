{ config, desktop, hostname, lib, pkgs, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;
in
{
  # Only include desktop components if one is supplied.
  # imports = [ ] ++ lib.optional (builtins.isString desktop) ./desktop.nix;
  imports = [ ] ++ lib.optionals (desktop != null) [
    # ../../_mixins/apps/browser/firefox.nix
    # ../../_mixins/apps/text-editor/vscode.nix
    # ../../_mixins/apps/tools/filesync.nix
  ] ++ lib.optionals (hostname == "rasp3") [
    ../../_mixins/console/fish.nix
  ];

  users = {
    mutableUsers = false;
    users.juca = {
      description = "Reinaldo P. Jr";
      extraGroups = [
        "seat"
        "seatd"
        "audio"
        "networkmanager"
        "users"
        "video"
        "wheel"
        "storage"
      ]
      ++ ifExists [
        "adbusers"
        "dialout"
        "render"
        "plugdev"
        "i2c"
        "systemd-journal"
        "corectrl"
        "lxd"
        "wireshark"
        "storage"
        "scanner"
        "libvirtd"
        "qemu-libvirtd"
        "kvm"
        "input"
        "docker"
        "podman"
      ];
      # mkpasswd -m sha-512
      hashedPassword = "$6$ctL12VUZteSntuRd$X4US2tZSUYilPGG.gIAWOanHayBW8dGHy6Z1r8kLSxN6QdTomEUuM7ENIGT1uBeXDhhZvUWRscXGWrPKos7yG.";
      homeMode = "0755";
      isNormalUser = true;
      # openssh.authorizedKeys.keys = [
      #   "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAywaYwPN4LVbPqkc+kUc7ZVazPBDy4LCAud5iGJdr7g9CwLYoudNjXt/98Oam5lK7ai6QPItK6ECj5+33x/iFpWb3Urr9SqMc/tH5dU1b9N/9yWRhE2WnfcvuI0ms6AXma8QGp1pj/DoLryPVQgXvQlglHaDIL1qdRWFqXUO2u30X5tWtDdOoR02UyAtYBttou4K0rG7LF9rRaoLYP9iCBLxkMJbCIznPD/pIYa6Fl8V8/OVsxYiFy7l5U0RZ7gkzJv8iNz+GG8vw2NX4oIJfAR4oIk3INUvYrKvI2NSMSw5sry+z818fD1hK+soYLQ4VZ4hHRHcf4WV4EeVa5ARxdw== Martin Wimpress"
      # ];
      packages = [ pkgs.home-manager ];
      # shell = pkgs.fish;
      shell = if hostname == "rasp3" then pkgs.fish else pkgs.bash;
    };
  };
}
