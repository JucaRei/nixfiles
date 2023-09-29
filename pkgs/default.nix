# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }: {
  # example = pkgs.callPackage ./example { };
  cyberre-grub-theme = pkgs.callPackage ./cyberre-grub-theme { };
  firefox-csshacks = pkgs.callPackage ./firefox-csshacks { };
  nvchaad = pkgs.callPackage ./nvchad { };
  tidal-dl = pkgs.callPackage ./tidal-dl { };
  breeze-hacked-cursorr = pkgs.callPackage ./breeze-hacked-cursor { };
}
