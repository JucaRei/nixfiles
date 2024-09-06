{ config, lib, hostname, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
in
{
  imports = [ ];
  home = {
    file = {
      # ".ssh/config".text = ''
      #   Host github.com
      #     HostName github.com
      #     User git
      #''
      "virtualmachines/nixos-console.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-console/disk.qcow2"
        disk_size="20G"
        iso="nixos-console/nixos.iso"
      '';
      "virtualmachines/nixos-desktop.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-desktop/disk.qcow2"
        disk_size="20G"
        iso="nixos-desktop/nixos.iso"
      '';
      # List home-manager packages
      ".config/home-manager/home-manager_local-packages.txt" = {
        text =
          let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
          "${formatted}";
      };
    };
    # A Modern Unix experience
    # https://jvns.ca/blog/2022/04/12/a-list-of-new-ish--command-line-tools/
    packages = with pkgs; lib.mkDefault [ ];
    extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
  };
  programs = {
    home-manager = lib.mkDefault {
      enable = true;
    };
  };

  services = {
    home-manager = {
      autoUpgrade = {
        enable = false;
      };
    };
  };

  xdg = {
    enable = true;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    userDirs = {
      enable = pkgs.stdenv.isLinux;
      createDirectories = true;

      download = "${config.home.homeDirectory}/Downloads";
      desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";

      publicShare = "${config.home.homeDirectory}/.local/share/public";
      templates = "${config.home.homeDirectory}/.local/share/templates";

      music = "${config.home.homeDirectory}/Media/Music";
      pictures = "${config.home.homeDirectory}/Media/Pictures";
      videos = "${config.home.homeDirectory}/Media/Videos";

      extraConfig = {
        XDG_SCREENSHOTS_DIR = lib.mkForce "${config.xdg.userDirs.pictures}/screenshots";
        XDG_WALLPAPERS_DIR = lib.mkForce "${config.xdg.userDirs.pictures}/wallpapers";
        XDG_MAIL_DIR = "${config.home.homeDirectory}/Mail";
      };
    };
  };

  systemd.user.tmpfiles.rules = lib.mkIf isLinux [
    "d ${config.home.homeDirectory}/workspace 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/windows 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/mac 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/docker 0750 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/lab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/scripts 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Videos/Animes/movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Videos/Animes/series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Videos/Animes/OVAs 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Videos/Series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Videos/Movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Videos/Youtube 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Music/playlists 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Music/albums 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Music/singles 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Music/artits 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Music/downloads 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Music/records 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/games 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/nixos-desktop 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/nixos-console 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/family 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/backup 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/phones 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/screenshots 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/wallpapers 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/resources 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
  ];

}
