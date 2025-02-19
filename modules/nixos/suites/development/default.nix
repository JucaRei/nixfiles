{ options, config, lib, pkgs, namespace, ... }:
with lib;
with lib.${namespace};
let
  cfg = config.${namespace}.suites.development;
in
{
  options.${namespace}.suites.development = with types; {
    enable = mkBoolOpt false "Whether or not to enable common development configuration.";
  };

  config = mkIf cfg.enable {
    networking.firewall.allowedTCPPorts = [
      12345
      3000
      3001
      8080
      8081
    ];

    ${namespace} = {

      programs = {
        terminal = {
          dev = {
            direnv = enable;
            nix-ld = enabled;
          };
        };
      };

      system = {
        virtualisation = {
          podman = enabled;
        };
      };
    };
  };
}
