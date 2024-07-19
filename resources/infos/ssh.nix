{ config, pkgs, ... }:
{

  programs.ssh = {

    enable = true;
    compression = true;
    # controlMaster = "auto"; # "yes", "no", "ask", "auto", "autoask"
    # controlPath = "~/.ssh/master-%r@%n:%p"; # default "~/.ssh/master-%r@%n:%p"
    hashKnownHosts = false;

    serverAliveCountMax = 3;
    serverAliveInterval = 10;

    extraConfig = "AddKeysToAgent yes";

    matchBlocks = {

      "github.com" = {
        user = "giorgiga";
        identityFile = "~/.ssh/github_ed25519";
        identitiesOnly = true;
      };

      "gitlab.com" = {
        user = "giorgiga";
        identityFile = "~/.ssh/gitlab_ed25519";
        identitiesOnly = true;
      };

      "127.*.*.* 192.168.*.* 10.*.*.* 172.16.*.* 172.17.*.* 172.18.*.* 172.19.*.* 172.2?.*.* 172.30.*.* 172.31.*.*" = {
        extraOptions = {
          Stricthostkeychecking = "no";
          Userknownhostsfile = "/dev/null";
          LogLevel = "quiet";
        };
      };

      "*.lan" = {
        extraOptions = {
          Stricthostkeychecking = "no";
          Userknownhostsfile = "/dev/null";
          LogLevel = "quiet";
        };
      };

    };

  };

  # TODO ~/.ssh/ might not have mode 700
  # see https://www.reddit.com/r/NixOS/comments/128t70l/file_permissions_in_homemanager/

  programs.rbw.settings.pinentry = pkgs.pinentry-qt;

  home.file = {

    # see https://gitlab.com/giorgiga/concoctions/-/blob/main/sh-scripts/ssh-add
    ".ssh/ssh-add-default-keys".text = ''
      id_ed25519
      github_ed25519
      gitlab_ed25519
      codesigning_ed25519
    '';

    # TODO would it better to use a on-the-fly package?
    #
    # (pkgs.writeShellScriptBin "my-hello" ''
    #   echo "Hello, ${config.home.username}!"
    # '')
    ".local/bin/ssh-keys-from-bitwarden" = {
      executable = true;
      text = ''
        #!/bin/sh

        BITWARDEN_ACCOUNT="giorgio.gallo@bitnic.it"
        BITWARDEN_SSH_KEYS_FOLDER="ssh-keys"
        TARGET_DIRECTORY="~/.ssh"

        # first run config

        rbwemail="$(rbw config show | jq -r .email)"
        test "$rbwemail" != "null" || rbw config set email "$BITWARDEN_ACCOUNT"
        unset rbwemail
        rbw login
        rbw register

        # write private keys and generate public ones
        files="$(rbw list --fields folder,name | grep "^$BITWARDEN_SSH_KEYS_FOLDER\s" | cut -f2)"
        for file in $files ; do

            bwout="$(rbw get --folder "$BITWARDEN_SSH_KEYS_FOLDER" "$file" --raw | jq -r '.data.password, .notes')"
            passphrase="$(echo "$bwout" | head -n 1)"
            key="$(echo "$bwout" | tail -n +2)" # use sed instead?

            private_key_file="''${TARGET_DIRECTORY//\~/$HOME}/$file"
            public_key_file="$private_key_file.pub"

            echo "Writing $private_key_file, $public_key_file"

            test -L "$private_key_file" && rm "$private_key_file"
            test -L "$public_key_file"  && rm "$public_key_file"

            touch "$private_key_file" "$public_key_file"
            chmod 600 "$private_key_file" "$public_key_file"

            printf -- "$key\n" > "$private_key_file"
            ssh-keygen -y -f "$private_key_file" -P "$passphrase" > "$public_key_file"

        done

        echo "Done."
      '';
    };

  };

}
