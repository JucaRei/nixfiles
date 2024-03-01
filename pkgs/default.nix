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
  
  #############
  ### Video ###
  #############
  
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
  adwaita-for-steam = pkgs.callPackage ./system/themes/steam/adwaita-for-steam { };

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

  ###############
  ### Wayland ###
  ###############
  idlehack = pkgs.callPackage ./system/wayland/idlehack { };

  #################
  ### Cli tools ###
  #################
  livebudscli = pkgs.callPackage ./cli/livebudscli { };
  cloneit = pkgs.callPackage ./cli/cloneit { };
  icloud-photo-downloader = pkgs.callPackage ./cli/icloud-photo-downloader { };
}

# nix-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'
# nom-build -E 'with import <nixpkgs> {}; callPackage ./default.nix {}'