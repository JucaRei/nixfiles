{
  config,
  lib,
  pkgs,
  inputs ? null,
  ...
}:
let
  inherit (lib) mkOption mkIf;
  inherit (lib.types) bool;
  cfg = config.system.programs.tools.ssh;

  # Versão estável anterior (Nixpkgs 24.05) com suporte nativo completo a DSA (ssh-dss),
  # KEX DH-group1/14-sha1 e cifras legadas para dispositivos antigos como D-Link ShareCenter.
  legacyPkgs =
    if inputs ? nixpkgs-oldstable && inputs.nixpkgs-oldstable ? legacyPackages then
      inputs.nixpkgs-oldstable.legacyPackages.${pkgs.stdenv.hostPlatform.system}
    else
      pkgs;

  legacySsh = legacyPkgs.openssh;

  sshLegacy = pkgs.writeShellScriptBin "ssh-legacy" ''
    exec ${legacySsh}/bin/ssh \
      -oHostKeyAlgorithms=+ssh-dss \
      -oKexAlgorithms=+diffie-hellman-group1-sha1,diffie-hellman-group14-sha1 \
      -oPubkeyAcceptedKeyTypes=+ssh-dss \
      -oCiphers=+aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc \
      -oMACs=+hmac-sha1,hmac-sha1-96 \
      "$@"
  '';

  scpLegacy = pkgs.writeShellScriptBin "scp-legacy" ''
    exec ${legacySsh}/bin/scp \
      -oHostKeyAlgorithms=+ssh-dss \
      -oKexAlgorithms=+diffie-hellman-group1-sha1,diffie-hellman-group14-sha1 \
      -oPubkeyAcceptedKeyTypes=+ssh-dss \
      -oCiphers=+aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc \
      -oMACs=+hmac-sha1,hmac-sha1-96 \
      "$@"
  '';

  sshSharecenter = pkgs.writeShellScriptBin "ssh-sharecenter" ''
    exec ${sshLegacy}/bin/ssh-legacy root@sharecenter.home.lan "$@"
  '';
in
{
  options = {
    system.programs.tools.ssh = {
      enable = mkOption {
        default = false;
        type = bool;
        description = "Enable's ssh configs.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.packages = [
      sshLegacy
      scpLegacy
      sshSharecenter
    ];

    home.shellAliases = {
      sharecenter = "ssh-sharecenter";
    };

    programs.ssh = {
      enable = true;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          Compression = true;
          ForwardAgent = true;
          ServerAliveCountMax = 2;
          ServerAliveInterval = 300;
        };
        "127.*.*.* 192.168.*.* 10.*.*.* 172.16.*.* 172.17.*.* 172.18.*.* 172.19.*.* 172.2?.*.* 172.30.*.* 172.31.*.*" =
          {
            StrictHostKeyChecking = "no";
            UserKnownHostsFile = "/dev/null";
          };

        "*.lan" = {
          StrictHostKeyChecking = "no";
          UserKnownHostsFile = "/dev/null";
        };

        "sharecenter.home.lan 10.10.10.10" = {
          User = "root";
          HostKeyAlgorithms = "+ssh-dss";
          KexAlgorithms = "+diffie-hellman-group1-sha1,diffie-hellman-group14-sha1";
          PubkeyAcceptedKeyTypes = "+ssh-dss";
          Ciphers = "+aes128-cbc,3des-cbc,aes192-cbc,aes256-cbc";
          MACs = "+hmac-sha1,hmac-sha1-96";
        };
      };

      extraOptionOverrides = {
        Include = "local.d/*";
      };
      extraConfig = ''
        AddKeysToAgent yes
      ''
      + lib.optionalString pkgs.stdenv.isDarwin ''
        IgnoreUnknown UseKeychain
        UseKeychain yes
      '';
    };

    # home.packages = with pkgs; [ mosh ];
  };
}
