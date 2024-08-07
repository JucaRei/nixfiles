{ config, desktop, lib, pkgs, username, hostname, isWorkstation, ... }:
let
  ifExists = groups: builtins.filter (group: builtins.hasAttr group config.users.groups) groups;

  variables = import ../hosts/${hostname}/variables.nix { inherit config username; }; # vars for better check

in
{
  imports = [
    ./root
  ] ++ lib.optional (builtins.pathExists (./. + "/${username}")) ./${username};

  environment.localBinInPath = true;

  users = {
    mutableUsers = true;
    # groups.${username} = {
    #   members = [ "${username}" ];
    # };
    # extraUsers.${username} = {
    #   name = "${username}";
    #   group = "${username}";
    # };
    users.${username} = {
      extraGroups = [
        "audio"
        "input"
        "networkmanager"
        "users"
        "video"
        "wheel"
      ]
      # "adbusers" "dialout" "render" "plugdev" "i2c" "systemd-journal" "corectrl" "wireshark" "storage" "scanner" "libvirtd" "qemu-libvirtd" "kvm" "input" "docker" "podman"
      ++ ifExists [
        "adm"
        "docker"
        "lxd"
        "podman"
        "rtkit"
        # "qemu-libvirtd"
        "kvm"
      ];
      homeMode = "0755";
      isNormalUser = true;
      openssh.authorizedKeys.keys = [
        "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEAywaYwPN4LVbPqkc+kUc7ZVazPBDy4LCAud5iGJdr7g9CwLYoudNjXt/98Oam5lK7ai6QPItK6ECj5+33x/iFpWb3Urr9SqMc/tH5dU1b9N/9yWRhE2WnfcvuI0ms6AXma8QGp1pj/DoLryPVQgXvQlglHaDIL1qdRWFqXUO2u30X5tWtDdOoR02UyAtYBttou4K0rG7LF9rRaoLYP9iCBLxkMJbCIznPD/pIYa6Fl8V8/OVsxYiFy7l5U0RZ7gkzJv8iNz+GG8vw2NX4oIJfAR4oIk3INUvYrKvI2NSMSw5sry+z818fD1hK+soYLQ4VZ4hHRHcf4WV4EeVa5ARxdw== Martin Wimpress"
      ];
      packages = [ pkgs.home-manager ];
      shell = pkgs.fish;
    };
  };

  ### Fish as default for any nixos user
  programs = {
    fish = {
      enable = isWorkstation;
      interactiveShellInit = ''
        set fish_cursor_default block blink
        set fish_cursor_insert line blink
        set fish_cursor_replace_one underscore blink
        set fish_cursor_visual block
        set -U fish_color_autosuggestion brblack
        set -U fish_color_cancel -r
        set -U fish_color_command green
        set -U fish_color_comment brblack
        set -U fish_color_cwd brgreen
        set -U fish_color_cwd_root brred
        set -U fish_color_end brmagenta
        set -U fish_color_error red
        set -U fish_color_escape brcyan
        set -U fish_color_history_current --bold
        set -U fish_color_host normal
        set -U fish_color_match --background=brblue
        set -U fish_color_normal normal
        set -U fish_color_operator cyan
        set -U fish_color_param blue
        set -U fish_color_quote yellow
        set -U fish_color_redirection magenta
        set -U fish_color_search_match bryellow '--background=brblack'
        set -U fish_color_selection white --bold '--background=brblack'
        set -U fish_color_status red
        set -U fish_color_user brwhite
        set -U fish_color_valid_path --underline
        set -U fish_pager_color_completion normal
        set -U fish_pager_color_description yellow
        set -U fish_pager_color_prefix white --bold --underline
        set -U fish_pager_color_progress brwhite '--background=cyan'
      '';
      shellAliases = {
        nano = "${variables.defaultEditor}";
      };
    };
  };
}
