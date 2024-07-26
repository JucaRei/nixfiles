{ config, pkgs, ... }:
{

  systemd.user.services.ssh-agent = {
    Unit = {
      Description = "SSH key agent";
      #After = [ "systemd-user-sessions.service user-runtime-dir@%i.service dbus.service" ];
      #Requires = [ "user-runtime-dir@%i.service" ];
    };
    Service = {
      Type = "simple";
      Environment = "SSH_AUTH_SOCK=%t/ssh-agent.socket";
      ExecStart = "/usr/bin/ssh-agent -D -a $SSH_AUTH_SOCK -t 4h";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  home.file = {
    ".config/environment.d/ssh_auth_socket.conf" = {
      text = ''
        SSH_AUTH_SOCK="''${XDG_RUNTIME_DIR}/ssh-agent.socket"
      '';
    };
  };

}
