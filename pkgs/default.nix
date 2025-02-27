# Custom packages, that can be defined similarly to ones from nixpkgs
# You can build them using 'nix build .#example'

pkgs: {
  # Images
  juca-avatar = pkgs.callPackage ./desktop/avatar/juca-avatar { };

  # Browser
  thorium = pkgs.callPackage ./desktop/thorium { };

  # Desktop
  nautilus-annotations = pkgs.callPackage ./desktop/gnome/nautilus/nautilus-annotations { };

  # rtl8188gu = pkgs.callPackage ./system/kernel/rtl8188gu { };

  # Grub
  grub-catppuccin = pkgs.callPackage ./system/grub/grub-catppuccin { };
  cyberre = pkgs.callPackage ./system/grub/cyberre { };

  # Kernel
  # linuxPackages_xanmod_stable = pkgs.callPackage ./system/kernel/xanmod { };

  # Themes
  sddm-theme-abstractdark = pkgs.callPackage ./system/display-managers/sddm/themes/sddm-theme-abstractdark { };
  breeze-hacked-cursor = pkgs.callPackage ./desktop/themes/pointers/breeze-hacked-cursor { };

  # Display Managers

  # Plymouth
  plymouth-catppuccin = pkgs.callPackage ./system/plymouth/plymouth-catppuccin { };
  plymouth-themes = pkgs.callPackage ./system/plymouth/plymouth-themes { };

  # Tools
  heynote = pkgs.callPackage ./desktop/tools/heynote { };
  advmvcp = pkgs.callPackage ./tools/advmvcp { };
  cloneit = pkgs.callPackage ./tools/cloneit { };
  image-colorizer = pkgs.callPackage ./tools/image-colorizer { };
  vv = pkgs.callPackage ./tools/vv { };
  ladder = pkgs.callPackage ./tools/ladder { };
  nixos-tweaker = pkgs.callPackage ./tools/nixos-tweaker { };
  docker-compose-check = pkgs.callPackage ./tools/docker-compose-check { };
  nixpkgs-plus = pkgs.callPackage ./tools/nixfmt-plus { };
  createScript = pkgs.callPackage ./tools/createScript { };
  speedtest-custom = pkgs.callPackage ./tools/speedtest-custom { };

  # Browser front-end
  headscale-ui = pkgs.callPackage ./tools/headscale-ui { };
  vuetorrent-ui = pkgs.callPackage ./tools/vuetorrent-ui { };

  # Local fonts
  # - https://yildiz.dev/posts/packing-custom-fonts-for-nixos/
  abel = pkgs.callPackage ./fonts/abel { };
  apple-fonts = pkgs.callPackage ./fonts/apple-fonts { };
  bebasNeue = pkgs.callPackage ./fonts/bebasNeue { };
  bebas-neue-2014-font = pkgs.callPackage ./fonts/bebas-neue-2014-font { };
  bebas-neue-2018-font = pkgs.callPackage ./fonts/bebas-neue-2018-font { };
  bebas-neue-pro-font = pkgs.callPackage ./fonts/bebas-neue-pro-font { };
  bebas-neue-rounded-font = pkgs.callPackage ./fonts/bebas-neue-rounded-font { };
  bebas-neue-semi-rounded-font = pkgs.callPackage ./fonts/bebas-neue-semi-rounded-font { };
  boycott-font = pkgs.callPackage ./fonts/boycott-font { };
  commodore-64-pixelized-font = pkgs.callPackage ./fonts/commodore-64-pixelized-font { };
  digital-7-font = pkgs.callPackage ./fonts/digital-7-font { };
  dirty-ego-font = pkgs.callPackage ./fonts/dirty-ego-font { };
  fantezy-font = pkgs.callPackage ./fonts/fantezy-font { };
  feather = pkgs.callPackage ./fonts/feather { };
  fixedsys-core-font = pkgs.callPackage ./fonts/fixedsys-core-font { };
  fixedsys-excelsior-font = pkgs.callPackage ./fonts/fixedsys-excelsior-font { };
  impact-label-font = pkgs.callPackage ./fonts/impact-label-font { };
  mocha-mattari-font = pkgs.callPackage ./fonts/mocha-mattari-font { };
  monaco = pkgs.callPackage ./fonts/monaco { };
  noto-sans-arabic = pkgs.callPackage ./fonts/noto-sans-arabic { };
  phospor = pkgs.callPackage ./fonts/phospor { };
  poppins-font = pkgs.callPackage ./fonts/poppins-font { };
  font-dubai = pkgs.callPackage ./fonts/dubai { };
  pragmasevka = pkgs.callPackage ./fonts/pragmasevka { };
  pragmatapro = pkgs.callPackage ./fonts/pragmatapro { };
  twilio-sans-mono-nerd-font = pkgs.callPackage ./fonts/twilio-sans-mono-nerd-font { };
  spaceport-2006-font = pkgs.callPackage ./fonts/spaceport-2006-font { };
  zx-spectrum-7-font = pkgs.callPackage ./fonts/zx-spectrum-7-font { };

  # Scripts
  font-search = pkgs.callPackage ./fonts/font-search { };
}
