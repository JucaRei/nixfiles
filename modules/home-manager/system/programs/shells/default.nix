{
  config,
  lib,
  pkgs,
  osConfig ? null,
  ...
}:
let
  inherit (lib)
    getExe
    getExe'
    mkIf
    mkMerge
    optional
    mkOption
    ;
  inherit (lib.types) enum bool;

  cfg = config.system.programs.shells;
  isNixOS = osConfig != null;

  nixDiff = {
    builtin = "nix store diff-closures";
    nvd = "${getExe pkgs.nvd} diff";
    nix-diff = getExe pkgs.nix-diff;
  };
in
{
  imports = [
    ./bash
    ./fish
    ./zsh
    ./direnv
    ./starship
  ];

  options.system.programs.shells = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable command-line shell configuration.";
    };

    default = mkOption {
      type = enum [
        "bash"
        "fish"
        "zsh"
      ];
      default = "bash";
      description = "Default shell to configure.";
    };

    aliases = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable useful shell aliases.";
      };

      systemd = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "Enable systemd-related aliases (sc-, scu-, jc- etc.).";
        };
      };

      process = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "Install process-related tools (procs).";
        };
      };

      nix = {
        enable = mkOption {
          type = bool;
          default = true;
          description = "Enable clean Nix command aliases.";
        };
        diffProgram = mkOption {
          type = enum [
            "builtin"
            "nvd"
            "nix-diff"
          ];
          default = "builtin";
          description = "Tool used by `nd` to show generation differences.";
        };
      };
    };

    direnv = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Enable direnv with good Nix integration.";
      };

      nix-direnv = mkOption {
        type = bool;
        default = true;
        description = "Use nix-direnv for persistent gc-rooted shells.";
      };
    };

    starship = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Enable Starship prompt with an aesthetic, lightweight configuration.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [

    # General aliases
    (mkIf cfg.aliases.enable {
      home.shellAliases = {
        mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
        lsusb = getExe pkgs.cyme;
        du = "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
        audio = "${pkgs.inxi}/bin/inxi -A";
        battery = "${pkgs.inxi}/bin/inxi -B -xxx";
        bluetooth = "${pkgs.inxi}/bin/inxi -E";
        graphics = "${pkgs.inxi}/bin/inxi -G";
        process = "${pkgs.inxi}/bin/inxi --processes";
        partitions = "${pkgs.inxi}/bin/inxi -P";
        sockets = "${pkgs.iproute2}/bin/ss -lp";
        system = "${pkgs.inxi}/bin/inxi -Fazy";
        usb = "${pkgs.inxi}/bin/inxi -J";
        wifi = "${pkgs.inxi}/bin/inxi -n";
        dmesg = "${pkgs.util-linux}/bin/dmesg --human --color=always";
        ports = "${pkgs.unixtools.netstat}/bin/netstat -tulanp";
        rsync = "${getExe pkgs.rsync} -aXxtv";
        tree = lib.mkDefault "${getExe pkgs.tree} -Cs";
        gitpfolders = "for i in */.git; do (echo \$i; cd \$i/..; git pull); done";

        pci = mkIf isNixOS "sudo 'PATH=\$PATH' env ${pkgs.inxi}/bin/inxi --slots";
        wifi_scan = mkIf isNixOS "${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && ${getExe' pkgs.networkmanager "nmcli"} device wifi list";

        search = "${pkgs.ripgrep}/bin/rg -p --glob '!node_modules/*' --glob '!vendor/*' \"\$@\"";
      };
    })

    # Systemd aliases
    (mkIf cfg.aliases.systemd.enable {
      home.shellAliases = import ./aliases/systemd.nix { inherit lib; };
    })

    # Process inspection tools
    (mkIf (cfg.aliases.enable && cfg.aliases.process.enable) {
      home.packages = [ pkgs.procs ];
    })

    # Nix aliases + tools
    (mkIf cfg.aliases.nix.enable {
      home = {
        packages = [
          pkgs.comma
        ]
        ++ optional (cfg.aliases.nix.diffProgram != "builtin") pkgs.${cfg.aliases.nix.diffProgram};

        shellAliases = {
          n = "nix";
          nf = "nix flake";
          nbr = "nix build --rebuild";
          nfc = "nix flake check";
          nd = nixDiff.${cfg.aliases.nix.diffProgram};
          nb = mkIf (!isNixOS) "${pkgs.nix}/bin/nix build --no-link --print-out-paths";
          ndev = "nix develop";
          nfu = "nix flake update";
          ne = "nix edit";
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
          ns = "nix search";
          nrepl = "nix repl";
          nsn = "nix search nixpkgs";
          nsh = "nix shell";
          nsu = "nix search nixpkgs-unstable";
          nsd = "nix show-derivation";
          nst = "nix store";
        };
      };
    })

  ]);
}
