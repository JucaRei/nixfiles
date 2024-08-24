{ config
, lib
, namespace
, ...
}:
let
  inherit (lib.${namespace}) enabled;
in
{
  excalibur = {
    user = {
      enable = true;
      inherit (config.snowfallorg.user) name;
    };

    programs = {
      terminal = {
        tools = {
          git = enabled;
          ssh = enabled;
        };
      };
    };

    services = {
      # sops = {
      #   enable = true;
      #   defaultSopsFile = lib.snowfall.fs.get-file "secrets/excalibur/excalibur/default.yaml";
      #   sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      # };
    };

    system = {
      xdg = enabled;
    };

    suites = {
      common = enabled;
      development = enabled;
    };
  };

  home.stateVersion = "21.11";
}
