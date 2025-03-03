{ pkgs, ... }:
{
  imports = [
    ./backend
    ./display-manager
    ./environment
  ];

  environment = {
    etc = {
      # Allow mounting FUSE filesystems as a user.
      # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
      "fuse.conf".text = "user_allow_other";
    };

    systemPackages = with pkgs;  [
      # gsmartcontrol
      catppuccin-cursors.mochaBlue
      (catppuccin-gtk.override {
        accents = [ "blue" ];
        size = "standard";
        variant = "mocha";
      })
      (catppuccin-papirus-folders.override {
        flavor = "mocha";
        accent = "blue";
      })
    ];

    sessionVariables = {
      "TMPDIR" = "/tmp";
    };
  };

  # Fix xdg-portals opening URLs: https://github.com/NixOS/nixpkgs/issues/189851
  systemd.user.extraConfig = ''
    DefaultEnvironment="PATH=/run/wrappers/bin:/etc/profiles/per-user/%u/bin:/nix/var/nix/profiles/default/bin:/run/current-system/sw/bin"
  '';
}
