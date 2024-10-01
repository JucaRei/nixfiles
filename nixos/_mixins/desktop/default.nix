{ desktop, lib, pkgs, hostname, username, isInstall, config, isServer, isLaptop, isISO, ... }:
let
  inherit (lib) mkDefault optionalAttrs optionals mkIf;
  #   xorg = (elem "xorg" config.sys.hardware.graphics.desktopProtocols);
  #   wayland = (elem "wayland" config.sys.hardware.graphics.desktopProtocols);
  #   desktopMode = xorg || wayland;

  notVM = if (hostname == "minimech" || hostname == "scrubber" || hostname == "vm" || builtins.substring 0 5 hostname == "lima-" || hostname == "rasp3") then false else true;

  isNitro = if (hostname == "nitro") then true else false;

in
{
  # config = mkIf desktopMode {
  imports = [ ../features ]
    ++ lib.optional (builtins.pathExists (./. + "/${desktop}.nix"))
    ./${desktop}.nix;

  config = {
    features.audio.manager = mkDefault "pipewire";

    environment = {
      etc = {
        # Allow mounting FUSE filesystems as a user.
        # https://discourse.nixos.org/t/fusermount-systemd-service-in-home-manager/5157
        "fuse.conf".text = ''
          user_allow_other
        '';
      } // optionalAttrs (isNitro) {
        "aspell.conf".text = ''
          master en_US
          add-extra-dicts en-computers.rws
          add-extra-dicts pt_BR.rws
        '';
      };

      systemPackages = with pkgs; (optionals (isNitro) [
        aspellDicts.en
        aspellDicts.en-computers
        aspellDicts.pt_BR
        hunspellDicts.en_US
        hunspellDicts.pt_BR
      ]);
    };


    services = {
      usbmuxd.enable = true;
      # Disable xterm
      xserver = {
        excludePackages = with pkgs; [ xterm ];
        displayManager = {
          sessionCommands = ''
            ${pkgs.numlockx}/bin/numlockx on
          '';
        };
      };
      samba = {
        enable = true;
        #package = pkgs.unstable.samba4Full; # samba4Full broken
        # securityType = "user";
        # openFirewall = true;
        extraConfig = ''
          # My old nas dlink-325 uses v1
          client min protocol = NT1
        '';
        ### --------------------------------------------------------- ###
        #   shares = {
        #     home = {
        #       path = "/home/${username}";
        #       browseable = "yes";
        #       writeable = "yes";
        #       "acl allow execute always" = true;
        #       "read only" = "no";
        #       "valid users" = "${username}";
        #       "create mask" = "0644";
        #       "directory mask" = "0755";
        #       "force user" = "${username}";
        #       "force group" = "users";
        #     };
        #     #### ----------------------------------------------------- ####
        #     media = {
        #       path = "/run/media/${username}";
        #       browseable = "yes";
        #       writeable = "yes";
        #       "acl allow execute always" = true;
        #       "read only" = "no";
        #       "valid users" = "${username}";
        #       "create mask" = "0644";
        #       "directory mask" = "0755";
        #       "force user" = "${username}";
        #       "force group" = "users";
        #     };
        #   };
      };
      gvfs = {
        package = pkgs.unstable.gvfs;
        enable = true;
      };

      logind = {
        extraConfig = ''
          # Set the maximum size of runtime directories to 100%
          RuntimeDirectorySize=100%
        '';
      };

      flatpak = mkIf (isInstall && isServer == false) {
        enable = true;
      };

      printing = mkIf (isISO) {
        enable = true;
        drivers = with pkgs; [ gutenprint hplip ];
      };
      system-config-printer.enable = isISO;
    };


    hardware = {
      brillo = {
        # smooth backlight control
        enable = optionals (isLaptop) true;
      };

      sane = lib.mkIf (isISO) {
        enable = true;
        extraBackends = with pkgs; [ hplipWithPlugin sane-airscan ];
      };
    };

    systemd = {
      services = {
        configure-flathub-repo = mkIf (isInstall && isISO) {
          wantedBy = [ "multi-user.target" ];
          path = [ pkgs.flatpak ];
          script = ''
            flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
          '';
        };

        configure-appcenter-repo = mkIf (isInstall && desktop == "pantheon") {
          wantedBy = [ "multi-user.target" ];
          path = [ pkgs.flatpak ];
          script = ''
            flatpak remote-add --if-not-exists appcenter https://flatpak.elementary.io/repo.flatpakrepo
          '';
        };
      };
    };

    xdg.portal = mkDefault {
      config = {
        common = {
          default = [
            "gtk"
          ];
        };
      };
      enable = true;
      xdgOpenUsePortal = true;
    };

    fonts =
      let
        lotsOfFonts = true;
      in
      {
        # Enable a basic set of fonts providing several font styles and families and reasonable coverage of Unicode.
        enableDefaultPackages = false;
        fontDir.enable = true;
        packages =
          lib.attrValues
            {
              # inherit (inputs.self.packages.${pkgs.system}) sarasa-gothic iosevka-q;
              # inherit (pkgs) material-design-icons noto-fonts-emoji symbola;
              # nerdfonts = pkgs.nerdfonts.override { fonts = [ "NerdFontsSymbolsOnly" ]; };
            } ++
          (with pkgs; [
            # (nerdfonts.override { fonts = [ "FiraCode" "NerdFontsSymbolsOnly" ]; })
            fira
            liberation_ttf
            source-serif
            inter
            roboto
            work-sans
          ] ++ lib.optionals (isISO) [
            ubuntu_font_family
          ] ++ lib.optionals (lotsOfFonts) [
            # Japanese
            # ipafont # display jap symbols like シートベルツ in polybar
            # kochi-substitute

            # Code/monospace and nsymbol fonts
            fira-code
            # fira-code-symbols
            # mplus-outline-fonts.osdnRelease
            # dejavu_fonts
            # iosevka-bin
            iosevka
          ]);

        fontconfig = {
          antialias = true;
          # cache32Bit = true;
          defaultFonts = {
            serif = [ "Source Serif" ];
            # serif = [
            # "SF Pro"
            # "Sarasa Gothic J"
            # "Sarasa Gothic K"
            # "Sarasa Gothic SC"
            # "Sarasa Gothic TC"
            # "Sarasa Gothic HC"
            # "Sarasa Gothic CL"
            # "Symbola"
            # ];
            sansSerif = [ "Inter" "Work Sans" "Fira Sans" ];
            # sansSerif = [
            #   "SF Pro"
            #   "Sarasa Gothic J"
            #   "Sarasa Gothic K"
            #   "Sarasa Gothic SC"
            #   "Sarasa Gothic TC"
            #   "Sarasa Gothic HC"
            #   "Sarasa Gothic CL"
            #   "Symbola"
            # ];
            # monospace = ["FiraCode Nerd Font Mono" "SauceCodePro Nerd Font Mono"];
            # monospace = [
            #   "SF Pro Rounded"
            #   "Sarasa Mono J"
            #   "Sarasa Mono K"
            #   "Sarasa Mono SC"
            #   "Sarasa Mono TC"
            #   "Sarasa Mono HC"
            #   "Sarasa Mono CL"
            #   "Symbola"
            # ];
            # emoji = [
            #   "Noto Color Emoji"
            #   "Material Design Icons"
            #   "Symbola"
            # ];
            monospace = [ "FiraCode Nerd Font Mono" "Symbols Nerd Font Mono" ];
            emoji = [ "Noto Color Emoji" "Twitter Color Emoji" ];
          };
          enable = true;
          hinting = {
            autohint = false;
            enable = true;
            style = "slight";
          };
          subpixel = {
            rgba = "rgb";
            lcdfilter = "light";
          };
        };

        # # Lucida -> iosevka as no free Lucida font available and it's used widely
        fontconfig.localConf = lib.mkIf lotsOfFonts ''
          <?xml version="1.0"?>
          <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
          <fontconfig>
            <match target="pattern">
              <test name="family" qual="any"><string>Lucida</string></test>
              <edit name="family" mode="assign">
                <string>iosevka</string>
              </edit>
            </match>
          </fontconfig>
        '';
      };
  };
}
