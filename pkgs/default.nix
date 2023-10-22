# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }: {
  # example = pkgs.callPackage ./example { };
  # apple-fonts = pkgs.callPackage ./apple-fonts { };
  cyberre-grub-theme = pkgs.callPackage ./cyberre-grub-theme { };
  cloneit = pkgs.callPackage ./cloneit { };
  plymouth-themes = pkgs.callPackage ./plymouth-themes { };
  firefox-csshacks = pkgs.callPackage ./firefox-csshacks { };
  nvchad = pkgs.callPackage ./nvchad { };
  # tidal-dl = pkgs.callPackage ./tidal-dl { };
  breeze-hacked-cursorr = pkgs.callPackage ./breeze-hacked-cursor { };
  # mpv = pkgs.callPackage ./mpv { };
  icloud-photo-downloader = pkgs.callPackage ./icloud-photo-downloader { };
  thorium-browser = pkgs.callPackage ./thorium-browser { };
}
