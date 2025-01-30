{ config, isLima, isWorkstation, lib, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf;
in
{
  home = {
    file = {
      "virtualmachines/nixos-console.conf" = mkIf (!isLima) {
        text = ''
          #!/run/current-system/sw/bin/quickemu --vm
          guest_os="linux"
          disk_img="nixos-console/disk.qcow2"
          disk_size="25G"
          iso="nixos-console/nixos.iso"
        '';
      };
      "virtualmachines/nixos-gnome.conf" = mkIf (!isLima) {
        text = ''
          #!/run/current-system/sw/bin/quickemu --vm
          guest_os="linux"
          disk_img="nixos-gnome/disk.qcow2"
          disk_size="25G"
          iso="nixos-gnome/nixos.iso"
          width="1920"
          height="1080"
        '';
      };
      "virtualmachines/nixos-mate.conf" = mkIf (!isLima) {
        text = ''
          #!/run/current-system/sw/bin/quickemu --vm
          guest_os="linux"
          disk_img="nixos-mate/disk.qcow2"
          disk_size="25G"
          iso="nixos-mate/nixos.iso"
          width="1920"
          height="1080"
        '';
      };
      "virtualmachines/nixos-pantheon.conf" = mkIf (!isLima) {
        text = ''
          #!/run/current-system/sw/bin/quickemu --vm
          guest_os="linux"
          disk_img="nixos-pantheon/disk.qcow2"
          disk_size="25G"
          iso="nixos-pantheon/nixos.iso"
          width="1920"
          height="1080"
        '';
      };
      "/games/.keep" = mkIf (!isLima) { text = ""; };
      "/virtualmachines/nixos-console/.keep" = mkIf (!isLima) { text = ""; };
      "/virtualmachines/nixos-gnome/.keep" = mkIf (!isLima) { text = ""; };
      "/virtualmachines/nixos-mate/.keep" = mkIf (!isLima) { text = ""; };
      "/virtualmachines/nixos-pantheon/.keep" = mkIf (!isLima) { text = ""; };
      "/workspace/.keep" = mkIf (!isLima) { text = ""; };
      "/.dotfiles/.keep".text = "";
      # ".ssh/allowed_signers".text = ''
      #   juca@wimpress.org ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAywaYwPN4LVbPqkc+kUc7ZVazPBDy4LCAud5iGJdr7g9CwLYoudNjXt/98Oam5lK7ai6QPItK6ECj5+33x/iFpWb3Urr9SqMc/tH5dU1b9N/9yWRhE2WnfcvuI0ms6AXma8QGp1pj/DoLryPVQgXvQlglHaDIL1qdRWFqXUO2u30X5tWtDdOoR02UyAtYBttou4K0rG7LF9rRaoLYP9iCBLxkMJbCIznPD/pIYa6Fl8V8/OVsxYiFy7l5U0RZ7gkzJv8iNz+GG8vw2NX4oIJfAR4oIk3INUvYrKvI2NSMSw5sry+z818fD1hK+soYLQ4VZ4hHRHcf4WV4EeVa5ARxdw== Martin Wimpress
      # '';

      # List home-manager packages
      ".config/home-manager/installed-packages.txt" = {
        text =
          let
            packages = builtins.map (p: "${p.name}") config.home.packages;
            sortedUnique = builtins.sort builtins.lessThan (lib.unique packages);
            formatted = builtins.concatStringsSep "\n" sortedUnique;
          in
          "${formatted}";
      };
    };
    sessionVariables = { };
  };
  programs = {
    # fish.interactiveShellInit = ''
    #   set -x GH_TOKEN (${pkgs.coreutils}/bin/cat ${config.sops.secrets.gh_token.path} 2>/dev/null)
    #   set -x GITHUB_TOKEN (${pkgs.coreutils}/bin/cat ${config.sops.secrets.gh_token.path} 2>/dev/null)
    # '';
    fish.loginShellInit = ''
      ${pkgs.figurine}/bin/figurine -f "DOS Rebel.flf" $hostname
    '';
    # git = {
    #   extraConfig = {
    #     gpg = {
    #       format = "ssh";
    #       ssh = {
    #         allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
    #       };
    #     };
    #   };
    #   userEmail = "reinaldo800@gmail.com";
    #   userName = "Reinaldo P Jr";
    #   signing = {
    #     key = "${config.home.homeDirectory}/.ssh/id_rsa";
    #     signByDefault = true;
    #   };
    # };
  };

  systemd.user.tmpfiles.rules = mkIf isLinux [
    "d ${config.home.homeDirectory}/workspace 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/windows 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/linux 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/mac 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/docker 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/workspace/lab 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/animes/movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/animes/series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/animes/OVAs 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/series 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/movies 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Videos/youtube 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/playlists 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/albums 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/singles 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/artists 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/downloads 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Music/records 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/games 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/nixos-desktop 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/nixos-console 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/family 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/backup 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/phones 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/screenshots 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/wallpapers 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Pictures/resources 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"

    "d ${config.home.homeDirectory}/.config/home-manager 0755 ${username} users - -"
    # "L+ ${config.xdg.dataHome}/applications - - - - /run/current-system/sw/bin/" # symlink executable's to normal linux path
    # "L+ ${config.home.homeDirectory}/.local/bin - - - - $HOME/.nix-profile/bin" # symlink executable's to normal linux path

  ];

  xdg = {
    enable = isLinux;
    cacheHome = "${config.home.homeDirectory}/.cache";
    configHome = "${config.home.homeDirectory}/.config";
    dataHome = "${config.home.homeDirectory}/.local/share";
    stateHome = "${config.home.homeDirectory}/.local/state";

    userDirs = {
      enable = isLinux && !isLima;
      createDirectories = isWorkstation;
      download = "${config.home.homeDirectory}/Downloads";
      # desktop = "${config.home.homeDirectory}/Desktop";
      documents = "${config.home.homeDirectory}/Documents";
      publicShare = "${config.home.homeDirectory}/.local/share/public";
      templates = "${config.home.homeDirectory}/.local/share/templates";
      music = "${config.home.homeDirectory}/Music";
      pictures = "${config.home.homeDirectory}/Pictures";
      videos = "${config.home.homeDirectory}/Videos";

      extraConfig = {
        XDG_SCREENSHOTS_DIR = "${config.xdg.userDirs.pictures}/screenshots";
        XDG_WALLPAPERS_DIR = "${config.xdg.userDirs.pictures}/wallpapers";
        XDG_GAMES_DIR = "${config.home.homeDirectory}/games";
        XDG_MISC_DIR = "${config.home.homeDirectory}/misc";
        XDG_WORKSPACE_DIR = "${config.home.homeDirectory}/workspace";
        XDG_RECORD_DIR = "${config.xdg.userDirs.videos}/Record";
      };
    };
  };
}
