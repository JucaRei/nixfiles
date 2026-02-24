{ config, lib, pkgs, osConfig ? null, ... }:
let
  inherit (lib) getExe getExe' mkIf mkMerge optional mkOption mdDoc;
  inherit (lib.types) enum bool;

  cfg = config.system.programs.shells;
  isNixOS = osConfig != null;

  nixDiff = {
    builtin   = "nix store diff-closures";
    nvd       = "${pkgs.nvd}/bin/nvd diff";
    nix-diff  = "${pkgs.nix-diff}/bin/nix-diff";
  };
in
{
  imports = [
    ./bash
    ./fish
    ./zsh
    ./direnv
  ];

  options.system.programs.shells = {
    enable = mkOption {
      type = bool;
      default = false;
      description = mdDoc "Enable command-line shell configuration.";
    };

    default = mkOption {
      type = enum [ "bash" "fish" "zsh" ];
      default = "bash";
      description = mdDoc "Default shell to configure.";
    };

    aliases = {
      enable = mkOption {
        type = bool;
        default = false;
        description = mdDoc "Enable useful shell aliases.";
      };

      systemd = mkOption {
        type = bool;
        default = true;
        description = mdDoc "Enable systemd-related aliases (sc-, scu-, jc- etc.).";
      };

      process = mkOption {
        type = bool;
        default = true;
        description = mdDoc "Install process-related tools (procs, fkill).";
      };

      nix = {
        enable = mkOption {
          type = bool;
          default = true;
          description = mdDoc "Enable clean Nix command aliases.";
        };
        diffProgram = mkOption {
          type = enum [ "builtin" "nvd" "nix-diff" ];
          default = "builtin";
          description = mdDoc "Tool used by `nd` to show generation differences.";
        };
      };
    };

    direnv.enable = mkOption {
      type = bool;
      default = false;
      description = mdDoc "Enable direnv with good Nix integration.";
    };

    direnv.nix-direnv = mkOption {
      type = bool;
      default = true;
      description = mdDoc "Use nix-direnv for persistent gc-rooted shells.";
    };
  };

  config = mkIf cfg.enable (mkMerge [

    # General aliases
    (mkIf cfg.aliases.enable {
      home.shellAliases = {
        mkhostid  = "head -c4 /dev/urandom | od -A none -t x4";
        lsusb     = getExe pkgs.cyme;
        du        = "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
        audio     = "${pkgs.inxi}/bin/inxi -A";
        battery   = "${pkgs.inxi}/bin/inxi -B -xxx";
        bluetooth = "${pkgs.inxi}/bin/inxi -E";
        graphics  = "${pkgs.inxi}/bin/inxi -G";
        process   = "${pkgs.inxi}/bin/inxi --processes";
        partitions= "${pkgs.inxi}/bin/inxi -P";
        sockets   = "${pkgs.iproute2}/bin/ss -lp";
        system    = "${pkgs.inxi}/bin/inxi -Fazy";
        usb       = "${pkgs.inxi}/bin/inxi -J";
        wifi      = "${pkgs.inxi}/bin/inxi -n";
        dmesg     = "${pkgs.util-linux}/bin/dmesg --human --color=always";
        ports     = "${pkgs.unixtools.netstat}/bin/netstat -tulanp";
        rsync     = "${getExe pkgs.rsync} -aXxtv";
        tree      = "${getExe pkgs.tree} -Cs";
        gitpfolders = "for i in */.git; do (echo \$i; cd \$i/..; git pull); done";

        # Conditional aliases – empty when condition false
        pci       = mkIf isNixOS "sudo 'PATH=\$PATH' env ${pkgs.inxi}/bin/inxi --slots";
        wifi_scan = mkIf isNixOS "${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && ${getExe' pkgs.networkmanager "nmcli"} device wifi list";

        search    = "${pkgs.ripgrep}/bin/rg -p --glob '!node_modules/*' --glob '!vendor/*' \"\$@\"";
      };
    })

    # Systemd aliases
    (mkIf cfg.aliases.systemd.enable {
      home.shellAliases = import ./aliases/systemd.nix { inherit lib pkgs; };
    })

    # # Process tools
    # (mkIf cfg.aliases.process.enable {
    #   home.packages = with pkgs; [
    #     nodePackages.fkill-cli
    #     procs
    #     strace
    #   ];
    # })

    # Nix aliases + tools
    (mkIf cfg.aliases.nix.enable {
      home = {
        packages = [ pkgs.comma ]
          ++ optional (cfg.aliases.nix.diffProgram != "builtin") pkgs.${cfg.aliases.nix.diffProgram};

        shellAliases = {
          n   = "nix";          nf  = "nix flake";
          nbr = "nix build --rebuild";  nfc = "nix flake check";
          nd  = nixDiff.${cfg.aliases.nix.diffProgram};
          nb  = mkIf (!isNixOS) "${pkgs.nix}/bin/nix build --no-link --print-out-paths";
          ndev= "nix develop";  nfu = "nix flake update";
          ne  = "nix edit";     nfuc= "nix flake update && nix flake check";

          nlog= "nix log";      np  = "nix profile";
          nph = "nix profile history";  npi = "nix profile install";
          npl = "nix profile list";     npu = "nix profile upgrade";
          nprm= "nix profile remove";   nprb= "nix profile rollback";
          npw = "nix profile wipe-history";

          nr  = "nix run";      ns  = "nix search";
          nrepl="nix repl";     nsn = "nix search nixpkgs";
          nsh = "nix shell";    nsu = "nix search nixpkgs-unstable";
          nsd = "nix show-derivation";
          nst = "nix store";
        };
      };
    })

    # Direnv
    (mkIf cfg.direnv.enable {
      programs.direnv = {
        enable = true;
        package = pkgs.direnv;
        enableNixDirenvIntegration = true;

        stdlib = mkIf cfg.direnv.nix-direnv ''
          use_nix() {
            if [ -f shell.nix ] || [ -f flake.nix ] || [ -f default.nix ]; then
              eval "$(nix-direnv-watch)"
            fi
          }
          : ''${DIRENV_AUTO_LOAD_FLAKE:=1}
          if [ -f flake.nix ] && [ ! -f .envrc ] && (( DIRENV_AUTO_LOAD_FLAKE )); then
            echo "use flake" > .envrc
            direnv allow
          fi
        '';
      };

      programs.bash.initExtra = mkIf (cfg.direnv.nix-direnv && cfg.default == "bash") ''
        eval "$(${pkgs.nix-direnv}/bin/direnv hook bash)"
      '';
      programs.zsh.initExtra = mkIf (cfg.direnv.nix-direnv && cfg.default == "zsh") ''
        eval "$(${pkgs.nix-direnv}/bin/direnv hook zsh)"
      '';
      programs.fish.interactiveShellInit = mkIf (cfg.direnv.nix-direnv && cfg.default == "fish") ''
        ${pkgs.nix-direnv}/bin/direnv hook fish | source
      '';

      home.packages = optional cfg.direnv.nix-direnv pkgs.nix-direnv;
    })

  ]);
}