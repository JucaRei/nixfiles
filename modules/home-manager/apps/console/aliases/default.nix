{ config, lib, pkgs, options, ... }:
let
  inherit (lib) mkIf getExe getExe' mkOption types;
  inherit (pkgs.stdenv) isLinux;
  cfg = config.apps.console.aliases;

  # Helper functions for systemd aliases
  mkSystemCommand = cmd: "systemctl ${cmd}";
  mkUserCommand = cmd: "systemctl --user ${cmd}";
  mkSudoCommand = cmd: "sudo systemctl ${cmd}";

  # Systemd commands lists
  systemdUserCommands = [
    "cat" "get-default" "help" "is-active" "is-enabled" "is-failed" "is-system-running"
    "list-dependencies" "list-jobs" "list-sockets" "list-timers" "list-unit-files"
    "list-units" "show" "show-environment" "status"
  ];

  systemdSudoCommands = [
    "add-requires" "add-wants" "cancel" "daemon-reexec" "daemon-reload" "default"
    "disable" "edit" "emergency" "enable" "halt" "import-environment" "isolate"
    "kexec" "kill" "link" "list-machines" "load" "mask" "preset" "preset-all"
    "reenable" "reload" "reload-or-restart" "reset-failed" "rescue" "restart"
    "revert" "set-default" "set-environment" "set-property" "start" "stop"
    "switch-root" "try-reload-or-restart" "try-restart" "unmask" "unset-environment"
  ];

  systemdPowerCommands = [ "hibernate" "hybrid-sleep" "poweroff" "reboot" "suspend" ];

  # Alias definitions
  systemdAliases = builtins.listToAttrs (
    (map (cmd: { name = "sc-${cmd}"; value = mkSystemCommand cmd; }) systemdUserCommands) ++
    (map (cmd: { name = "sc-${cmd}"; value = mkSudoCommand cmd; }) systemdSudoCommands) ++
    (map (cmd: { name = "sc-${cmd}"; value = mkSystemCommand cmd; }) systemdPowerCommands) ++
    (map (cmd: { name = "scu-${cmd}"; value = mkUserCommand cmd; }) systemdUserCommands) ++
    (map (cmd: { name = "scu-${cmd}"; value = mkUserCommand cmd; }) systemdSudoCommands)
  ) // {
    # Extra systemctl commands
    "sc-disable-now" = "sc-disable --now";
    "sc-enable-now" = "sc-enable --now";
    "sc-failed" = "systemctl --failed";
    "sc-mask-now" = "sc-mask --now";
    "scu-disable-now" = "scu-disable --now";
    "scu-enable-now" = "scu-enable --now";
    "scu-failed" = "systemctl --user --failed";
    "scu-mask-now" = "scu-mask --now";
  };

  journalctlAliases = {
    "jc-boot" = "journalctl -b";
    "jc-kernel" = "journalctl -k";
    "jc-list-boot" = "journalctl --list-boots";
    "jc-service" = "journalctl -u";
    "jc-usage" = "journalctl --disk-usage";
    "jcu-service" = "journalctl --user -u";
  };

  networkctlAliases = {
    "nc-cat" = "networkctl cat";
    "nc-delete" = "networkctl delete";
    "nc-down" = "networkctl down";
    "nc-edit" = "networkctl edit";
    "nc-frenew" = "networkctl forcerenew";
    "nc-label" = "networkctl label";
    "nc-list" = "networkctl list";
    "nc-lldp" = "networkctl lldp";
    "nc-mask" = "networkctl mask";
    "nc-reconfig" = "networkctl reconfigure";
    "nc-reload" = "networkctl reload";
    "nc-renew" = "networkctl renew";
    "nc-status" = "networkctl status";
    "nc-unmask" = "networkctl unmask";
    "nc-up" = "networkctl up";
  };

  resolvectlAliases = {
    "rc-query" = "resolvectl query";
    "rc-service" = "resolvectl service";
    "rc-openpgp" = "resolvectl openpgp";
    "rc-tlsa" = "resolvectl tlsa";
    "rc-status" = "resolvectl status";
    "rc-stat" = "resolvectl statistics";
    "rc-reset-stat" = "resolvectl reset-statistics";
    "rc-flush" = "resolvectl flush-caches";
    "rc-reset" = "resolvectl reset-server-features";
    "rc-dns" = "resolvectl dns";
    "rc-domain" = "resolvectl domain";
    "rc-default-route" = "resolvectl default-route";
    "rc-llmnr" = "resolvectl llmnr";
    "rc-mdns" = "resolvectl mdns";
    "rc-dnssec" = "resolvectl dnssec";
    "rc-dnsovertls" = "resolvectl dnsovertls";
    "rc-nta" = "resolvectl nta";
    "rc-revert" = "resolvectl revert";
    "rc-monitor" = "resolvectl monitor";
    "rc-show-cache" = "resolvectl show-cache";
    "rc-show-server-state" = "resolvectl show-server-state";
    "rc-log-level" = "resolvectl log-level";
  };

  utilityAliases = {
    "nspawn" = "${pkgs.systemdMinimal}/bin/systemd-nspawn";
    "sxorg" = "export DISPLAY=:0.0";
    "nix-hash-sha256" = "nix-hash --flat --base32 --type sha256";
    "mkhostid" = "head -c4 /dev/urandom | od -A none -t x4";
    "mkdir" = "mkdir -pv";
    "lsusb" = "${getExe pkgs.cyme}";
    "ios" = "sudo --preserve-env=PATH ${pkgs.dmidecode}/bin/dmidecode -t bios";
    "cat" = "bat --paging=never --style=\"numbers,changes\" --italic-text=always";
    "ct" = "bat --paging=never --style=\"plain\" --italic-text=always";
    "cp" = "${pkgs.xcp}/bin/xcp";
    "ip" = mkIf isLinux "${pkgs.iproute2}/bin/ip --color --brief";
    "less" = "${pkgs.bat}/bin/bat --paging=always";
    "more" = "${pkgs.bat}/bin/bat --paging=always";
    "ps" = "${getExe pkgs.procs}";
    "dd" = "${pkgs.writedisk}/bin/writedisk";
    "wget" = "${pkgs.wget2}/bin/wget2";
    "du" = "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
    "audio" = "${pkgs.inxi}/bin/inxi -A";
    "battery" = "${pkgs.inxi}/bin/inxi -B -xxx";
    "bluetooth" = "${pkgs.inxi}/bin/inxi -E";
    "graphics" = "${pkgs.inxi}/bin/inxi -G";
    "macros" = "${pkgs.llvmPackages.clangNoLibc}/bin/cpp -dM /dev/null";
    "pci" = "sudo 'PATH=$PATH' env ${pkgs.inxi}/bin/inxi --slots";
    "process" = "${pkgs.inxi}/bin/inxi --processes";
    "partitions" = "${pkgs.inxi}/bin/inxi -P";
    "repos" = "${pkgs.inxi}/bin/inxi -r";
    "sockets" = "${pkgs.iproute2}/bin/ss -lp";
    "system" = "${pkgs.inxi}/bin/inxi -Fazy";
    "usb" = "${pkgs.inxi}/bin/inxi -J";
    "wifi" = "${pkgs.inxi}/bin/inxi -n";
    "dmesg" = "${pkgs.util-linux}/bin/dmesg --human --color=always";
    "ports" = "${pkgs.unixtools.netstat}/bin/netstat -tulanp";
    "wifi_scan" = "${getExe' pkgs.networkmanager "nmcli"} device wifi rescan && ${getExe' pkgs.networkmanager "nmcli"} device wifi list";
    "grep" = "${getExe' pkgs.gnugrep "grep"} -E --color=auto";
    "rsync" = "${getExe pkgs.rsync} -aXxtv";
    "tree" = "${getExe pkgs.tree} -Cs";
    "nb" = "${pkgs.nix}/bin/nix build --no-link --print-out-paths";
  };

  nixAliases = {
    "n" = "nix";
    "nbr" = "nix build --rebuild";
    "ndev" = "nix develop";
    "ne" = "nix edit";
    "nf" = "nix flake";
    "nfc" = "nix flake check";
    "nfcl" = "nix flake clone";
    "nfi" = "nix flake init";
    "nfl" = "nix flake lock";
    "nfm" = "nix flake metadata";
    "nfu" = "nix flake update";
    "nfuc" = "nix flake update && nix flake check";
    "nlog" = "nix log";
    "np" = "nix profile";
    "nph" = "nix profile history";
    "npi" = "nix profile install";
    "npl" = "nix profile list";
    "npu" = "nix profile upgrade";
    "nprm" = "nix profile remove";
    "nprb" = "nix profile rollback";
    "npw" = "nix profile wipe-history";
    "npath" = "nix path-info";
    "nr" = "nix run";
    "nrepl" = "nix repl";
    "nreg" = "nix registry";
    "nregls" = "nix registry list";
    "ns" = "nix search";
    "nsn" = "nix search nixpkgs";
    "nsu" = "nix search nixpkgs-unstable";
  };

  nixDiffCommands = {
    builtin = "nix store diff-closures";
    nvd = "${pkgs.nvd}/bin/nvd diff";
    nix-diff = "${pkgs.nix-diff}/bin/nix-diff";
  };
in
{
  options.apps.console.aliases = {
    enable = mkOption {
      default = false;
      type = types.bool;
      description = "Enable a comprehensive set of shell aliases for various tools.";
    };

    systemd.shellAliases = mkOption {
      type = types.attrsOf types.str;
      default = systemdAliases // journalctlAliases // networkctlAliases // resolvectlAliases // utilityAliases;
      description = "Shell aliases for systemd-related tools and general utilities.";
    };

    process.packages = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [ nodePackages.fkill-cli procs strace ];
      description = "Packages for process management.";
    };

    nix = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable Nix-related aliases and tools.";
      };

      diffProgram = mkOption {
        type = types.enum (builtins.attrNames nixDiffCommands);
        default = "builtin";
        description = "Program to use for Nix diff operations.";
      };
    };
  };

  config = mkIf cfg.enable (lib.mkMerge [
    {
      home = {
        inherit (cfg.systemd) shellAliases;
        packages = cfg.process.packages;
      };
    }

    (mkIf cfg.nix.enable {
      home = {
        packages = [ pkgs.comma ]
          ++ lib.optional (cfg.nix.diffProgram != "builtin") (pkgs.${cfg.nix.diffProgram});

        shellAliases = nixAliases // {
          nd = builtins.getAttr cfg.nix.diffProgram nixDiffCommands;
        };
      };
    })
  ]);
}
