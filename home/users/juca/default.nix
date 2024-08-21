{ config, lib, hostname, pkgs, username, isWorkstation, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  cfg = config.modules.wallpapers;
  walls = pkgs.fetchgit {
    url = "https://github.com/D3Ext/aesthetic-wallpapers";
    rev = "060c580dcc11afea2f77f9073bd8710920e176d8";
    sha256 = "5MnW630EwjKOeOCIAJdSFW0fcSSY4xmfuW/w7WyIovI=";
  };
in
{
  home = {
    file = {
      # ".ssh/config".text = ''
      #   Host github.com
      #     HostName github.com
      #     User git
      # '';
      "Quickemu/nixos-console.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-console/disk.qcow2"
        disk_size="20G"
        iso="nixos-console/nixos.iso"
      '';
      "Quickemu/nixos-desktop.conf".text = ''
        #!/run/current-system/sw/bin/quickemu --vm
        guest_os="linux"
        disk_img="nixos-desktop/disk.qcow2"
        disk_size="20G"
        iso="nixos-desktop/nixos.iso"
      '';
      # List home-manager packages
      ".local/home-manager-packages.txt" = {
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
    packages = with pkgs;[
      cloneit
      neofetch
    ];
    extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
  };


  systemd.user.tmpfiles.rules = lib.mkIf isLinux [
    # "d ${config.home.homeDirectory}/Scripts 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Studio/OBS/config/obs-studio/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/github 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/bitbucket 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/gitlab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/windows 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/mac 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/docker/composes 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/OVAs 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/youtube 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/playlists 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/albums 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/singles 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/artits 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/downloads 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/records 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Games 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Quickemu/nixos-desktop 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Quickemu/nixos-console 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Syncthing 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/family 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/backup 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/phones 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/screenshots 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/wallpapers 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/resources 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Volatile/Vorta 0755 ${username} users - -"
    # "L+ /home/${username}/.config/obs-studio/ - - - - ${config.home.homeDirectory}/Studio/OBS/config/obs-studio/"
  ];
}
