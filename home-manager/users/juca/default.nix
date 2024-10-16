{ config, hostname, isLima, isWorkstation, lib, pkgs, username, ... }:
let
  inherit (pkgs.stdenv) isLinux;
  inherit (lib) mkIf getExe;
  isStreamstation = hostname == "phasma" || hostname == "vader";
in
{
  home = {
    file = {
      # "${config.xdg.configHome}/autostart/deskmaster-xl.desktop" = lib.mkIf isStreamstation {
      #   text = ''
      #     [Desktop Entry]
      #     Name=Deckmaster XL
      #     Comment=Deckmaster XL
      #     Type=Application
      #     Exec=deckmaster -deck ${config.home.homeDirectory}/Studio/StreamDeck/Deckmaster-xl/main.deck
      #     Categories=
      #     Terminal=false
      #     NoDisplay=true
      #     StartupNotify=false
      #   '';
      # };
      ".face" = {
        source = "${getExe pkgs.juca-avatar} juca-avatar";
      };
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
      "/Development/.keep" = mkIf (!isLima) { text = ""; };
      "/games/.keep" = mkIf (!isLima) { text = ""; };
      "/virtualmachines/nixos-console/.keep" = mkIf (!isLima) { text = ""; };
      "/virtualmachines/nixos-gnome/.keep" = mkIf (!isLima) { text = ""; };
      "/virtualmachines/nixos-mate/.keep" = mkIf (!isLima) { text = ""; };
      "/virtualmachines/nixos-pantheon/.keep" = mkIf (!isLima) { text = ""; };
      "/workspace/scripts/.keep" = mkIf (!isLima) { text = ""; };
      "/.dotfiles/.keep".text = "";
      # ".ssh/allowed_signers".text = ''
      #   juca@wimpress.org ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAywaYwPN4LVbPqkc+kUc7ZVazPBDy4LCAud5iGJdr7g9CwLYoudNjXt/98Oam5lK7ai6QPItK6ECj5+33x/iFpWb3Urr9SqMc/tH5dU1b9N/9yWRhE2WnfcvuI0ms6AXma8QGp1pj/DoLryPVQgXvQlglHaDIL1qdRWFqXUO2u30X5tWtDdOoR02UyAtYBttou4K0rG7LF9rRaoLYP9iCBLxkMJbCIznPD/pIYa6Fl8V8/OVsxYiFy7l5U0RZ7gkzJv8iNz+GG8vw2NX4oIJfAR4oIk3INUvYrKvI2NSMSw5sry+z818fD1hK+soYLQ4VZ4hHRHcf4WV4EeVa5ARxdw== Martin Wimpress
      # '';
    };
    sessionVariables = {
      BZR_EMAIL = "Martin Wimpress <code@wimpress.io>";
      DEBFULLNAME = "Martin Wimpress";
      DEBEMAIL = "code@wimpress.io";
      DEBSIGN_KEYID = "8F04688C17006782143279DA61DF940515E06DA3";
    };
  };
  programs = {
    fish.interactiveShellInit = ''
      set -x GH_TOKEN (${pkgs.coreutils}/bin/cat ${config.sops.secrets.gh_token.path} 2>/dev/null)
      set -x GITHUB_TOKEN (${pkgs.coreutils}/bin/cat ${config.sops.secrets.gh_token.path} 2>/dev/null)
    '';
    fish.loginShellInit = ''
      ${pkgs.figurine}/bin/figurine -f "DOS Rebel.flf" $hostname
    '';
    git = {
      extraConfig = {
        gpg = {
          format = "ssh";
          ssh = {
            allowedSignersFile = "${config.home.homeDirectory}/.ssh/allowed_signers";
          };
        };
      };
      userEmail = "juca@wimpress.org";
      userName = "Martin Wimpress";
      signing = {
        key = "${config.home.homeDirectory}/.ssh/id_rsa";
        signByDefault = true;
      };
    };
  };

  systemd.user.tmpfiles.rules = mkIf isLinux [
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
    # "d ${config.home.homeDirectory}/Media/Music/records 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/games 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/nixos-desktop 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/virtualmachines/nixos-console 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/family 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/backup 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/phones 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/screenshots 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/wallpapers 0755 ${username} users - -"
    "d ${config.home.homeDirectory}/Media/Pictures/resources 0755 ${username} users - -"
    # "d ${config.home.homeDirectory}/.dotfiles 0755 ${username} users - -"
  ];
}
