{ lib, pkgs, config, isWorkstation, ... }:
let
  inherit (lib) mkIf mkOption types;
  cfg = config.custom.services.samba;
in
{
  options = {
    custom.services.samba = {
      enable = mkOption {
        default = isWorkstation;
        type = types.bool;
        description = "Enables samba configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services = {
      samba = {
        package = pkgs.samba4Full;
        # ^^ `samba4Full` is compiled with avahi, ldap, AD etc support (compared to the default package, `samba`
        # Required for samba to register mDNS records for auto discovery
        # See https://github.com/NixOS/nixpkgs/blob/592047fc9e4f7b74a4dc85d1b9f5243dfe4899e3/pkgs/top-level/all-packages.nix#L27268
        enable = true;
        openFirewall = true;
        # shares.testshare = {
        #   path = "/path/to/share";
        #   writable = "true";
        #   comment = "Hello World!";
        # };
        # extraConfig = ''
        #   server smb encrypt = required
        #   # ^^ Note: Breaks `smbclient -L <ip/host> -U%` by default, might require the client to set `client min protocol`?
        #   server min protocol = SMB3_00
        # '';
        settings = {
          global = {
            ####################################
            ### My old nas dlink-325 uses v1 ###
            ####################################

            workgroup = "${config.networking.hostName}";
            # "dns proxy" = "no";
            "name resolve order" = "lmhosts wins bcast host";
            # "wins support" = "yes";
            # "passdb backend" = "tdbsam";

            # "server role" = "standalone";
            # "server string" = "Samba server (version: %v, protocol: %R)";

            # Set the minimum SMB protocol version on the client end
            # Allow accessing old SMB protocols (SMB1++ = COREPLUS)
            # "client min protocol" = "NT1";
            "client min protocol" = "COREPLUS";

            # "server min protocol" = "NT1";
            "server min protocol" = "COREPLUS";
            "netbios name" = "${config.networking.hostName}";

            # Set maximum IPC protocol to SMB3 NT1 for the client
            "client ipc max protocol" = "SMB3";

            # Set minimum IPC protocol to COREPLUS for the client
            "client ipc min protocol" = "COREPLUS";

            # Set maximum SMB protocol to SMB3 for the client
            "client max protocol" = "SMB3";

            # Set maximum SMB protocol to SMB3 for the server
            "server max protocol" = "SMB3";

            # Set AIO (Asynchronous I/O) read size to 0
            # 0 means that Samba should attempt to automatically determine the optimal read size based on the characteristics of the underlying filesystem.
            "aio read size" = 0;

            # Set AIO write size to 0
            "aio write size" = 0;

            # Enable VFS (Virtual File System) objects including ACL (Access Control List) xattr, Catia, and Streams xattr
            "vfs objects" = "acl_xattr catia streams_xattr";

            "hosts allow" = "127.0.0. 10. 172.16.0.0/255.240.0.0 192.168. 169.254. fd00::/8 fe80::/10 localhost";
            "hosts deny" = "allow";

            # "deadtime" = "30";
            # "guest account" = "nobody";
            # "inherit permissions" = "yes";
            # "map to guest" = "bad user";
            # "pam password change" = "yes";
            # "use sendfile" = "yes";

            # this tells Samba to use a separate log file for each machine that connects
            "log file" = "/var/log/samba/log.%m";

            # Put a capping on the size of the log files (in Kb).
            "max log size" = 500;

            ### level 1=WARN, 2=NOTICE, 3=INFO, 4 and up = DEBUG
            ### Ensure that users get to see auth and protocol negotiation info
            "log level" = "1 auth:3 smb:3 smb2:3";

            ### Store additional metadata or attributes associated with files or directories on the file system.
            # "ea support" = "yes";

            ### Serving files to Mac clients while maintaining compatibility with macOS-specific features and behaviors
            # "fruit:metadata" = "stream";
            # "fruit:model" = "Macmini";
            # "fruit:veto_appledouble" = "no";
            # "fruit:posix_rename" = "yes";
            # "fruit:zero_file_id" = "yes";
            # "fruit:wipe_intentionally_left_blank_rfork" = "yes";
            # "fruit:delete_empty_adfiles" = "yes";

            ### printing = cups
            # "printcap name" = "cups";
            # "load printers" = "yes";
            # "cups options" = "raw";
            # "disable spoolss" = "yes";
          };
        };
      };
      avahi = {
        # Allow samba to automatically register mDNS records (without the need for an `extraServiceFile`
        publish.enable = true;
        publish.userServices = true;
        openFirewall = true;
      };
      samba-wsdd = {
        # Enables autodiscovery on windows since SMB1 (and thus netbios) support was discontinued
        enable = true;
        openFirewall = true;
      };
    };
  };
}
