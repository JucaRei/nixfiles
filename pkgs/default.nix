# Custom packages, that can be defined similarly to ones from nixpkgs
# Build them using 'nix build .#example' or (legacy) 'nix-build -A example'

{ pkgs ? (import ../nixpkgs.nix) { } }: {

  #############
  ### Tools ###
  #############
  gitkraken = pkgs.callPackage ./tools/gitkraken { };
  qrcodegencpp = pkgs.callPackage ./tools/qrcodegencpp { };
  obs-studio = pkgs.callPackage ./tools/obs-studio { };
  obs-studio-plugins = pkgs.callPackage ./tools/obs-studio/plugins { };
  libdatachannel = pkgs.callPackage ./tools/libdatachannel { };
  smartmon-script = pkgs.callPackage ./tools/smartmon-script { };

  ####################
  ### Applications ###
  ####################
  halloy = pkgs.callPackage ./applications/messaging/halloy { };
  lazy-desktop = pkgs.callPackage ./applications/scripts/lazy-desktop { };
  deezer = pkgs.callPackage ./applications/music/deezer { };
  spotify-dl = pkgs.callPackage ./applications/music/spotify-dl { };

  ################
  ### Browsers ###
  ################
  thorium = pkgs.callPackage ./applications/browser/thorium { }; 
  firefox-csshacks = pkgs.callPackage ./applications/browser/firefox/firefox-csshacks { }; 
  firefox-gnome-theme = pkgs.callPackage ./applications/browser/firefox/firefox-gnome-theme { }; 

  ##############
  ### Gaming ###
  ##############
  dsdrv-cemuhook = pkgs.callPackage ./applications/gaming/dsdrv-cemuhook { };
  dualsensectl = pkgs.callPackage ./applications/gaming/dualsensectl { };
  evdevhook = pkgs.callPackage ./applications/gaming/evdevhook { };
  evdevhook2 = pkgs.callPackage ./applications/gaming/evdevhook2 { };
  trigger-control = pkgs.callPackage ./applications/gaming/trigger-control { };

  ########################
  ### Virtual-Machines ###
  ########################
  lima-bin = pkgs.callPackage ./virtual/lima-bin { };
  distrobox = pkgs.callPackage ./virtual/distrobox { };

  ################
  ### Terminal ###
  ################
  st-snazzy = pkgs.callPackage ./applications/terminal/st { };

  #############
  ### Video ###
  #############
  mpv-anime4k = pkgs.callPackage ./applications/video/mpv/extensions/mpv-anime4k { };
  mpv-dynamic-crop = pkgs.callPackage ./applications/video/mpv/extensions/mpv-dynamic-crop { };
  mpv-modernx = pkgs.callPackage ./applications/video/mpv/extensions/mpv-modernx { };
  mpv-sub-select = pkgs.callPackage ./applications/video/mpv/extensions/mpv-sub-select { };
  mpv-subsearch = pkgs.callPackage ./applications/video/mpv/extensions/mpv-subsearch { };
  mpv-thumbfast-osc = pkgs.callPackage ./applications/video/mpv/extensions/mpv-thumbfast-osc { };
  mpv-subserv = pkgs.callPackage ./applications/video/mpv/extensions/subserv { };

  ###################
  ### Grub Themes ###
  ###################
  grub-catppuccin = pkgs.callPackage ./system/grub/themes/catppuccin { };
  grub-cyberre = pkgs.callPackage ./system/grub/themes/cyberre { };

  #############
  ### Fonts ###
  #############
  apple-fonts = pkgs.callPackage ./fonts/apple-fonts { };
  cairo = pkgs.callPackage ./fonts/cairo { };
  century-gothic = pkgs.callPackage ./fonts/century-gothic { };
  dubai = pkgs.callPackage ./fonts/dubai { };
  fantezy-font = pkgs.callPackage ./fonts/fantezy-font { };
  iosevka-q = pkgs.callPackage ./fonts/iosevka-q { };
  material-symbols = pkgs.callPackage ./fonts/material-symbols { };
  nf-iosevka = pkgs.callPackage ./fonts/nf-iosevka { };
  nf-victormono = pkgs.callPackage ./fonts/nf-victormono { };
  noto-sans-arabic = pkgs.callPackage ./fonts/noto-sans-arabic { };
  phospor = pkgs.callPackage ./fonts/phospor { };
  pragmasevka = pkgs.callPackage ./fonts/pragmasevka { };
  pragmatapro = pkgs.callPackage ./fonts/pragmatapro { };
  sarasa-gothic = pkgs.callPackage ./fonts/sarasa-gothic { };
  twilio-sans-mono-nerd-font = pkgs.callPackage ./fonts/twilio-sans-mono-nerd-font { };

  ###################
  ### Grub Themes ###
  ###################
  catppuccin = pkgs.callPackage ./system/grub/themes/catppuccin { };
  cyberre = pkgs.callPackage ./system/grub/themes/cyberre { };

  ##############
  ### Themes ###
  ##############
  steam = pkgs.callPackage ./system/themes/steam/adwaita-for-steam { };
  ## Gtk ##
  gruvbox-dark-gtk = pkgs.callPackage ./system/themes/gtk/gruvbox-dark { };
  ## Icons ##
  candy-icons = pkgs.callPackage ./system/themes/icons/candy-icons { };
  colloid = pkgs.callPackage ./system/themes/icons/colloid { };
  elementary = pkgs.callPackage ./system/themes/icons/elementary { };
  fluent = pkgs.callPackage ./system/themes/icons/fluent { };
  reversal = pkgs.callPackage ./system/themes/icons/reversal { };
  rose-pine = pkgs.callPackage ./system/themes/icons/rose-pine { };
  whitesur = pkgs.callPackage ./system/themes/icons/whitesur { };
  ## Cursors ##
  breeze-hacked-cursor = pkgs.callPackage ./system/themes/pointers/breeze-hacked-cursor { };


  ###################
  ### Sddm Themes ###
  ###################
  astronaut-sddm = pkgs.libsForQt5.callPackage ./system/themes/sddm/astronaut-sddm { };
  simple-sddm = pkgs.callPackage ./system/themes/sddm/simple-sddm { };


  ################
  ### Plymouth ###
  ################
  plymouth-catppuccin = pkgs.callPackage ./system/plymouth/plymouth-catppuccin { };
  plymouth-themes = pkgs.callPackage ./system/plymouth/plymouth-themes { };

  ##################
  ### Misc Tools ###
  ##################
  cyberchef = pkgs.callPackage ./tools/misc/cyberchef { };
  # displaylink = pkgs.callPackage ./tools/misc/displaylink { };
  headscale-ui = pkgs.callPackage ./tools/misc/headscale-ui { };
  ladder = pkgs.callPackage ./tools/misc/ladder { };
  uxplay = pkgs.callPackage ./tools/misc/uxplay { };

  ###############
  ### Wayland ###
  ###############
  idlehack = pkgs.callPackage ./system/wayland/idlehack { };
  waybar = pkgs.callPackage ./system/wayland/waybar { };

  ##############
  ### System ###
  ##############
  xanmod-custom = pkgs.callPackage ./system/kernel/xanmod { };
  bt-overskride = pkgs.callPackage ./system/bluetooth/overskride { };
  nautilus-annotations = pkgs.callPackage ./system/gnome/file-manager/nautilus-ext/nautilus-annotations { };
  wallpaper-engine-plasma-plugin = pkgs.callPackage ./system/plasma/wallpaper-engine-plasma-plugin { };

  #################
  ### Cli tools ###
  #################
  livebudscli = pkgs.callPackage ./cli/livebudscli { };
  advmvcp = pkgs.callPackage ./cli/advmvcp { };
  cloneit = pkgs.callPackage ./cli/cloneit { };
  chatgpt-cli = pkgs.callPackage ./cli/chatgpt-cli { };
  harlequin-db = pkgs.callPackage ./cli/harlequin { };
  icloud-photo-downloader = pkgs.callPackage ./cli/icloud-photo-downloader { };
  image-colorizer = pkgs.callPackage ./cli/image-colorizer { };
  lutgen = pkgs.callPackage ./cli/lutgen { };
  nvchad = pkgs.callPackage ./cli/nvchad { };
  vv = pkgs.callPackage ./cli/vv { };
  youtube-transcribe = pkgs.callPackage ./cli/youtube-transcribe { };
  youtube-tui = pkgs.callPackage ./cli/youtube-tui { };

  ###############
  ### Scripts ###
  ###############
  change-audio = pkgs.callPackage ./scripts/change-audio { };
  change-backlight = pkgs.callPackage ./scripts/change-backlight { };
  dkcompose = pkgs.callPackage ./scripts/dkcompose { };
  git-clone-all = pkgs.callPackage ./scripts/git-clone-all { };
  git-refresh = pkgs.callPackage ./scripts/git-refresh { };
  git-stats = pkgs.callPackage ./scripts/git-stats { };
  list-extensions = pkgs.callPackage ./scripts/list-extensions { };
  list-iommu = pkgs.callPackage ./scripts/list-iommu { };
  nix-cleanup = pkgs.callPackage ./scripts/nix-cleanup { };
  nix-whereis = pkgs.callPackage ./scripts/nix-whereis { };
  nixos-change-summary = pkgs.callPackage ./scripts/nixos-change-summary { };
  oom-test = pkgs.callPackage ./scripts/oom-test { };
  paper = pkgs.callPackage ./scripts/paper { };
  repl = pkgs.callPackage ./scripts/repl { };

  ################
  ### AI Tools ###
  ################
  stable-diffusion = pkgs.callPackage ./tools/ai/stable-diffusion { };
}

# nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
# nom-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'