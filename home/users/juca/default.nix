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
      # '';
      # "Quickemu/nixos-console.conf".text = ''
      #   #!/run/current-system/sw/bin/quickemu --vm
      #   guest_os="linux"
      #   disk_img="nixos-console/disk.qcow2"
      #   disk_size="20G"
      #   iso="nixos-console/nixos.iso"
      # '';
      # "Quickemu/nixos-desktop.conf".text = ''
      #   #!/run/current-system/sw/bin/quickemu --vm
      #   guest_os="linux"
      #   disk_img="nixos-desktop/disk.qcow2"
      #   disk_size="20G"
      #   iso="nixos-desktop/nixos.iso"
      # '';

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
    packages = with pkgs;
      lib.mkDefault [
      ];
    extraOutputsToInstall = [ "info" "man" "share" "icons" "doc" ];
  };
  # programs = {
  # git = {
  #   userEmail = "reinaldo.develop@gmail.com";
  #   userName = "Reinaldo P JR ";
  #   signing = {
  #     key = "15E06DA3";
  #     signByDefault = true;
  #   };
  # };


  systemd.user.tmpfiles.rules = lib.mkIf isLinux [
    # "d ${config.home.homeDirectory}/Scripts 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Studio/OBS/config/obs-studio/ 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/Virtualmachines/windows 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/Virtualmachines/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/Virtualmachines/mac 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/lab/docker/{data,resources,composes} 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Documents/lab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Documents/workspace/{github,bitbucket,gitlab} 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Documents/workspace/bitbucket 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Documents/workspace/gitlab 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Documents/scripts 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Downloads 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Downloads/Music 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Downloads/Torrents 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Downloads/Files 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/Animes/{movies,series,OVA's} 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Videos/Animes/series 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Videos/Animes/OVAs 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/{Movies,Series,Youtube} 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Videos/Movies 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Videos/Youtube 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Videos/Youtube/Tutorials 0755 ${username} users - -"
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
    "d ${config.home.homeDirectory}/Pictures/Family 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/Backup 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/Phones 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/Screenshots 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/Wallpapers 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/Resources 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/Volatile/Vorta 0755 ${username} users - -"
    # "L+ /home/${username}/.config/obs-studio/ - - - - ${config.home.homeDirectory}/Studio/OBS/config/obs-studio/"
  ];
}
