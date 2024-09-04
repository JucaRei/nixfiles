{ config, hostname, lib, isWorkstation, pkgs, isLima, ... }:
with lib;
let
  inherit (pkgs.stdenv) isDarwin isLinux;
  home-build = import ../../resources/scripts/nix/home-build.nix { inherit pkgs; };
  home-switch = import ../../resources/scripts/nix/home-switch.nix { inherit pkgs; };
  gen-ssh-key = import ../../resources/scripts/nix/gen-ssh-key.nix { inherit pkgs; };
  home-manager_change_summary = import ../../resources/scripts/nix/home-manager_change_summary.nix { inherit pkgs; };

  cfg = config.services.nonNixOs;
  isOld = if (hostname == "oldarch") then false else true;
  isGeneric = if (config.services.nonNixOs.enable) then true else false;
in
{
  imports = [
    ./_mixins/console
  ]
  ++ optional (isWorkstation) ./_mixins/desktop;

  options.services.nonNixOs = {
    enable = mkOption {
      default = false;
      type = types.bool;
    };
  };

  config = {
    home = {
      # A Modern Unix experience
      # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
      packages = with pkgs; [
        # Custom Scripts
        home-build
        home-switch
        gen-ssh-key
        home-manager_change_summary
        nix-whereis
        duf # Modern Unix `df`
        fd # Modern Unix `find`
        hr # Terminal horizontal rule
        netdiscover # Modern Unix `arp`
        optipng # Terminal PNG optimizer
        procs # Modern Unix `ps`
        speedtest-go # Terminal speedtest.net
        rsync # Traditional `rsync`
        wget2 # Terminal HTTP client
      ] ++ optionals isLinux [
        iw # Terminal WiFi info
        psmisc # a set of small utils like killall, fuser, pstree
        pciutils # Terminal PCI info
        usbutils # Terminal USB info
        writedisk # Modern Unix `dd`
        zsync # Terminal file sync; FTBFS on aarch64-darwin

        # compression
        lzop
        p7zip
        unrar
        zip
      ] ++ optionals isDarwin [
        m-cli # Terminal Swiss Army Knife for macOS
      ] ++ optionals isGeneric [
        nix-output-monitor
        nixpkgs-fmt
        nil

      ] ++ optionals (isGeneric && isOld) [
        nixgl.auto.nixGLDefault
      ];

      activation = mkIf isGeneric {
        linkDesktopApplications = {
          # Add Packages To System Menu by updating database
          after = [ "writeBoundary" "createXdgUserDirectories" ];
          before = [ ];
          # data = "sudo --preserve-env=PATH env /usr/bin/update-desktop-database";
          # data = "${pkgs.desktop-file-utils}/bin/update-desktop-database";
          data = "sudo /usr/bin/update-desktop-database";
          # data = ''
          #   rm -rf ${config.xdg.dataHome}/"applications/home-manager"
          #   mkdir -p ${config.xdg.dataHome}/"applications/home-manager"
          #   cp -Lr ${config.home.homeDirectory}/.nix-profile/share/applications/* ${config.xdg.dataHome}/"applications/home-manager/"
          # '';
        };
      };

      sessionVariables =
        let
          editor = "micro"; # change for whatever you want
        in
        {
          EDITOR = "${editor}";
          # MANPAGER = "sh -c 'col --no-backspaces --spaces | bat --language man'";
          PAGER = "${pkgs.moar}/bin/moar";
          SYSTEMD_EDITOR = "${editor}";
          VISUAL = "${editor}";
        };
    };

    targets.genericLinux.enable = isGeneric;

    programs = {
      command-not-found.enable = false;
      info.enable = true;
      jq = {
        enable = true;
        package = pkgs.jiq;
      };
    };

    xdg = {
      enable = isLinux;
      userDirs = {
        # Do not create XDG directories for LIMA; it is confusing
        enable = isLinux && !isLima;
        createDirectories = lib.mkDefault true;
        extraConfig = {
          XDG_SCREENSHOTS_DIR = "${config.home.homeDirectory}/Pictures/screenshots";
        };
      };
    };
  };
}
