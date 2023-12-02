# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

# { pkgs ? (import ../nixpkgs.nix) { } }: {
{ pkgs ? (import ../default.nix) { } }: {
  # example = pkgs.callPackage ./example { };
  # apple-fonts = pkgs.callPackage ./apple-fonts { };
  cyberre-grub-theme = pkgs.callPackage ./cyberre-grub-theme { };
  cloneit = pkgs.callPackage ./cloneit { };
  # deezer = pkgs.callPackage ./deezer { };
  plymouth-themes = pkgs.callPackage ./plymouth-themes { };
  firefox-csshacks = pkgs.callPackage ./firefox-csshacks { };
  nvchad = pkgs.callPackage ./nvchad { };
  # tidal-dl = pkgs.callPackage ./tidal-dl { };
  fantezy-font = pkgs.callPackage ./fonts/fantezy-font { };
  # breeze-hacked-cursorr = pkgs.callPackage ./breeze-hacked-cursor { };
  advmvcp = pkgs.callPackage ./advmvcp { };
  icloud-photo-downloader = pkgs.callPackage ./icloud-photo-downloader { };
  thorium-browser = pkgs.callPackage ./thorium-browser { };
  polybar-pulseaudio-control = pkgs.callPackage ./polybar-pulseaudio-control { };
  # nixos-change-summary = pkgs.callPackage ./nixos-change-summary { };
  phospor = pkgs.callPackage ./fonts/phospor.nix { };
  material-symbols = pkgs.callPackage ./fonts/material-symbols.nix { };
}
