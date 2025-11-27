{ config, lib, pkgs, osConfig ? null, ... }:
let
  inherit (lib) getExe getExe' mkIf mkMerge optional mkOption mdDoc;
  inherit (lib.types) enum bool;
  cfg = config.system.programs.shells;
  isNixOS = osConfig != null;

  # Choose your favorite `nix store diff-closures` wrapper
  nixDiff = {
    builtin = "nix store diff-closures";
    nvd = "${pkgs.nvd}/bin/nvd diff";
    nix-diff = "${pkgs.nix-diff}/bin/nix-diff";
  };
in
{
  imports = [
    ./bash
    ./fish
    ./zsh
    ./direnv
  ];

  options = {
    system = {
      programs = {
        shells = {
          enable = mkOption {
            default = false;
            type = bool;
            description = mdDoc "Enable's command-line shell configuration.";
          };
          default = mkOption {
            default = "bash";
            description = mdDoc "The default command-line shell configuration.";
            type = enum [ "bash" "fish" "zsh" ];
          };

          aliases = {
            enable = mkOption {
              type = bool;
              default = false;
              description = mdDoc "Enable a small, powerful set of shell aliases.";
            };

            systemd = mkOption {
              type = bool;
              default = true;
              description = mdDoc "Enable essential systemd aliases (sc-, scu-, jc-).";
            };

            process = mkOption {
              type = bool;
              default = true;
              description = mdDoc "Install process tools (procs, fkill).";
            };

            nix = {
              enable = mkOption {
                type = bool;
                default = true;
                description = mdDoc "Enable clean Nix aliases (n, nd, nf, nsh, …).";
              };
              diffProgram = mkOption {
                type = enum [ "builtin" "nvd" "nix-diff" ];
                default = "builtin";
                description = mdDoc "Which tool `nd` uses to show generation differences.";
              };
            };
          };

          direnv = {
            enable = mkOption {
              type = bool;
              default = false;
              description = mdDoc "Enable direnv with best-in-class Nix integration.";
            };

            nix-direnv = mkOption {
              type = bool;
              default = true;
              description = "Use nix-direnv (persistent gc-rooted shells).";
            };
          };
        };
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf config.aliases.enable {
      home.shellAliases = {
        mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
        lsusb = "${getExe pkgs.cyme}";
        du = "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
        audio = "${pkgs.inxi}/bin/inxi -A";
        battery = "${pkgs.inxi}/bin/inxi -B -xxx";
        bluetooth = "${pkgs.inxi}/bin/inxi -E";
        graphics = "${pkgs.inxi}/bin/inxi -G";
        pci = mkIf (isNixOS) "sudo 'PATH=$PATH' env ${pkgs.inxi}/bin/inxi --slots";
        process = "${pkgs.inxi}/bin/inxi --processes";
        partitions = "${pkgs.inxi}/bin/inxi -P";
        sockets = "${pkgs.iproute2}/bin/ss -lp";
        system = "${pkgs.inxi}/bin/inxi -Fazy";
        usb = "${pkgs.inxi}/bin/inxi -J";
        wifi = "${pkgs.inxi}/bin/inxi -n";
        dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
        ports = "${pkgs.unixtools.netstat}/bin/netstat -tulanp"; # Show open ports
        rsync = "${getExe pkgs.rsync} -aXxtv"; # Better copying with Rsync
        tree = "${getExe pkgs.tree} -Cs"; # -colorized - sorted
        wifi_scan = mkIf (isNixOS) "${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && ${getExe' pkgs.networkmanager "nmcli"} device wifi list";
        gitpfolders = "for i in */.git; do ( echo $i; cd $i/..; ${pkgs.git}/bin/git pull; ); done";
        search = '' "${pkgs.ripgrep}/bin/rg -p --glob "!node_modules/*" --glob "!vendor/*" "$@"'" '';
      };
    })

    # ── Systemd shortcuts (sc-restart, scu-status, jc-boot, …) ─────────────────────
    (mkIf cfg.aliases.systemd.enable {
      home.shellAliases = import ./aliases/systemd.nix {
        inherit lib pkgs;
      };
    })

    # ── Process tools ─────────────────────────────────────────────────────────────
    (mkIf cfg.aliases.process.enable {
      home.packages = with pkgs; [
        nodePackages.fkill-cli
        procs
        strace
      ];
    })

    # ── Nix ───────────────────────────────────────────────────────────────────────
    (mkIf cfg.aliases.nix.enable {
      home = {
        packages = [ pkgs.comma ]
          ++ optional (cfg.nix.diffProgram != "builtin") pkgs.${cfg.nix.diffProgram};

        shellAliases = {
          n = "nix";
          nbr = "nix build --rebuild";
          nd = nixDiff.${cfg.nix.diffProgram}; # ← respects your choice
          nb = mkIf (!isNixOS) "${pkgs.nix}/bin/nix build --no-link --print-out-paths";
          ndev = "nix develop";
          ne = "nix edit";

          nf = "nix flake";
          nfc = "nix flake check";
          nfcl = "nix flake clone";
          nfi = "nix flake init";
          nfl = "nix flake lock";
          nfm = "nix flake metadata";
          nfu = "nix flake update";
          nfuc = "nix flake update && nix flake check";

          nlog = "nix log";
          np = "nix profile";
          nph = "nix profile history";
          npi = "nix profile install";
          npl = "nix profile list";
          npu = "nix profile upgrade";
          nprm = "nix profile remove";
          nprb = "nix profile rollback";
          npw = "nix profile wipe-history";

          nr = "nix run";
          nrepl = "nix repl";
          ns = "nix search";
          nsn = "nix search nixpkgs";
          nsu = "nix search nixpkgs-unstable";
          nsh = "nix shell";
          nsd = "nix show-derivation";
          nst = "nix store";
        };
      };
    })

    (mkIf cfg.direnv.enable {
      programs = {
        direnv = {
          enable = true;
          package = pkgs.direnv;

          # Always load Nix integration
          enableNixDirenvIntegration = true;

          # Use nix-direnv if requested (recommended)
          stdlib = mkIf cfg.nix-direnv ''
            # Keep shells alive and avoid re-building every time
            use_nix() {
              if [ -f shell.nix ] || [ -f flake.nix ] || [ -f default.nix ]; then
                eval "$(nix-direnv-watch)"
              fi
            }
            # Optional: auto-load flake.nix without .envrc
            : ''${DIRENV_AUTO_LOAD_FLAKE:=1}
            if [ -f flake.nix ] && [ ! -f .envrc ] && (( DIRENV_AUTO_LOAD_FLAKE )); then
              echo "use flake" > .envrc
              direnv allow
            fi
          '';
        };

        bash.initExtra = mkIf (cfg.direnv.nix-direnv && cfg.default == "bash") ''
          eval "$(${pkgs.nix-direnv}/bin/direnv hook bash)"
        '';
        zsh.initExtra = mkIf (cfg.direnv.nix-direnv && cfg.default == "zsh") ''
          eval "$(${pkgs.nix-direnv}/bin/direnv hook zsh)"
        '';
        fish.interactiveShellInit = mkIf (cfg.direnv.nix-direnv && cfg.default == "fish") ''
          ${pkgs.nix-direnv}/bin/direnv hook fish | source
        '';
      };

      home = {
        packages = optional cfg.direnv.nix-direnv pkgs.nix-direnv;
      };
    })
  ]);
}
