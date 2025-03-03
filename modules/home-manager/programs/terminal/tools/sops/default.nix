{ config, lib, ... }:
let
  inherit (lib) mkOption mkIf mdDoc;
  inherit (lib.types) bool;
  cfg = config.programs.terminal.tools.sops;
in
{
  options = {
    programs.terminal.tools.sops = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable's sops configuration for secure your keys.";
      };
    };
  };
  config = mkIf cfg.enable {
    sops = {
      age = {
        # automatically import host SSH key as age keys
        # sshKeyPaths = [ "/home/${username}/.ssh/machines/personal/nitro" ];
        # this will use an agey key that is expected to already be in the filesystem
        keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        generateKey = false;
        # generate a new key if the key specified above does not exist
        # generateKey = true;
      };
      defaultSopsFile = ../secrets/secrets.yaml;
      # validateSopsFiles = false;
      # sops-nix options: https://dl.thalheim.io/

      # secrets will be output to /run/secrets
      # e.g. /run/secrets/password
      # secrets required for user creation are handled in respective ./users/<username>.nix files
      # because they will be output to /run/secrets-for-users and only when the user is assigned to a host
      secrets = {
        # password = { };
        # asciinema.path = "${config.home.homeDirectory}/.config/asciinema/config";
        # atuin_key.path = "${config.home.homeDirectory}/.local/share/atuin/key";
        # gh_token = { };
        # gpg_private = { };
        # gpg_public = { };
        # gpg_ownertrust = { };
        # hueadm.path = "${config.home.homeDirectory}/.hueadm.json";
        # obs_secrets = { };
        # ssh_config.path = "${config.home.homeDirectory}/.ssh/config";
        ssh_key.path = "${config.home.homeDirectory}/.ssh/machines/personal/nitro";
        ssh_key_pub.path = "${config.home.homeDirectory}/.ssh/machines/personal/nitro.pub";
        # ssh_semaphore_key.path = "${config.home.homeDirectory}/.ssh/id_rsa_semaphore";
        # ssh_semaphore_pub.path = "${config.home.homeDirectory}/.ssh/id_rsa_semaphore.pub";
        # transifex.path = "${config.home.homeDirectory}/.transifexrc";
      };
    };
  };
}
