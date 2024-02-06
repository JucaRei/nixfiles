# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

# { pkgs ? (import ../nixpkgs.nix) { } }: {
{ pkgs ? (import ../default.nix) { } }: {
  # Music
  # deezer = pkgs.callPackage ./music/deezer { };
  # tidal-dl = pkgs.callPackage ./music/tidal-dl { };
  # spotdl = pkgs.callPackage ./music/spotify-dl { };

  sddm-astronaut-theme =
    pkgs.libsForQt5.callPackage ./sddm-theme/sddm-astronaut-theme.nix { };

  # Browsers
  thorium-browser = pkgs.callPackage ./browsers/thorium-browser { };

  cyberre-grub-theme = pkgs.callPackage ./grub/themes/cyberre-grub-theme { };
  plymouth-themes = pkgs.callPackage ./plymouth/plymouth-themes { };
  catppuccin-plymouth = pkgs.callPackage ./plymouth/catppuccin-plymouth { };
  firefox-csshacks = pkgs.callPackage ./browsers/firefox/firefox-csshacks { };
  # nvchad = pkgs.callPackage ./nvchad { };
  fantezy-font = pkgs.callPackage ./fonts/fantezy-font { };
  # breeze-hacked-cursorr = pkgs.callPackage ./themes/mouse/breeze-hacked-cursor { };
  # polybar-pulseaudio-control = pkgs.callPackage ./polybar-pulseaudio-control { }; # now its on unstable channel

  # Scripts
  nix-inspect = pkgs.callPackage ./scripts/nix-inspect { };
  nix-cleanup = pkgs.callPackage ./scripts/nix-cleanup { };
  nix-whereis = pkgs.callPackage ./scripts/nix-whereis { };
  # nixos-change-summary = pkgs.callPackage ./scripts/nixos-change-summary { };
  repl-nix = pkgs.callPackage ./scripts/repl { };

  # Utils
  vv = pkgs.callPackage ./utils/vv { };
  advmvcp = pkgs.callPackage ./utils/advmvcp { };
  icloud-photo-downloader =
    pkgs.callPackage ./utils/icloud-photo-downloader { };
  youtube_tui = pkgs.callPackage ./utils/youtube-tui { };
  lutgenn = pkgs.callPackage ./utils/lutgen { };
  cloneit = pkgs.callPackage ./utils/cloneit { };
  distrobox = pkgs.callPackage ./utils/distrobox { };

  # mpv plugins
  mpv-anime4k = pkgs.callPackage ./mpv-ext/mpv-anime4k { };
  mpv-dynamic-crop = pkgs.callPackage ./mpv-ext/mpv-dynamic-crop { };
  mpv-modernx = pkgs.callPackage ./mpv-ext/mpv-modernx { };
  mpv-nextfile = pkgs.callPackage ./mpv-ext/mpv-nextfile { };
  mpv-sub-select = pkgs.callPackage ./mpv-ext/mpv-sub-select { };
  mpv-subsearch = pkgs.callPackage ./mpv-ext/mpv-subsearch { };
  mpv-thumbfast-osc = pkgs.callPackage ./mpv-ext/mpv-thumbfast-osc { };

  # Font
  # phospor = pkgs.callPackage ./fonts/phospor.nix { };
  material-symbols = pkgs.callPackage ./fonts/material-symbols.nix { };
  font-cairo = pkgs.callPackage ./fonts/cairo { };
  font-dubai = pkgs.callPackage ./fonts/dubai { };
  font-noto-sans-arabic = pkgs.callPackage ./fonts/noto-sans-arabic { };
  # apple-fonts = pkgs.callPackage ./apple-fonts { };

  # GTK
  # phocus-gtk = pkgs.callPackage ./themes/gtk/phocus { };
  gruv = pkgs.callPackage ./themes/gtk/gruvbox-dark.nix { };
  nautilus-annotations = pkgs.callPackage ./nautilus-annotations { };

  # mouse
  breeze-hacked-cursor =
    pkgs.callPackage ./themes/mouse/breeze-hacked-cursor { };

  # Icons
  colloid = pkgs.callPackage ./themes/icons/colloid.nix { };
  elementary = pkgs.callPackage ./themes/icons/elementary.nix { };
  fluent = pkgs.callPackage ./themes/icons/fluent.nix { };
  reversal = pkgs.callPackage ./themes/icons/reversal.nix { };
  whitesur = pkgs.callPackage ./themes/icons/whitesur.nix { };

  # custom locking script
  # lockman-wayland = pkgs.callPackage ./misc/lockman { };
}
