{ config, lib, pkgs, ... }:

let
  cfg = config.services.aliases;

  nixDiffCommands = {
    builtin = "nix store diff-closures";
    nvd = "${pkgs.nvd}/bin/nvd diff";
    nix-diff = "${pkgs.nix-diff}/bin/nix-diff";
  };
in
{
  options.services.aliases = {
    enable = lib.mkEnableOption "Enable aliases for system" // { default = true; };

    systemd.shellAliases = lib.mkOption {
      type = with lib.types; attrsOf str;

      default =
        let
          userCommands = [
            "cat"
            "get-default"
            "help"
            "is-active"
            "is-enabled"
            "is-failed"
            "is-system-running"
            "list-dependencies"
            "list-jobs"
            "list-sockets"
            "list-timers"
            "list-unit-files"
            "list-units"
            "show"
            "show-environment"
            "status"
          ];

          sudoCommands = [
            "add-requires"
            "add-wants"
            "cancel"
            "daemon-reexec"
            "daemon-reload"
            "default"
            "disable"
            "edit"
            "emergency"
            "enable"
            "halt"
            "import-environment"
            "isolate"
            "kexec"
            "kill"
            "link"
            "list-machines"
            "load"
            "mask"
            "preset"
            "preset-all"
            "reenable"
            "reload"
            "reload-or-restart"
            "reset-failed"
            "rescue"
            "restart"
            "revert"
            "set-default"
            "set-environment"
            "set-property"
            "start"
            "stop"
            "switch-root"
            "try-reload-or-restart"
            "try-restart"
            "unmask"
            "unset-environment"
          ];

          powerCommands = [
            "hibernate"
            "hybrid-sleep"
            "poweroff"
            "reboot"
            "suspend"
          ];

          # mkSystemCommand :: String -> { name :: String, value :: String }
          mkSystemCommand = c: { name = "sc-${c}"; value = "systemctl ${c}"; };

          # mkUserCommand :: String -> { name :: String, value :: String }
          mkUserCommand = c: { name = "scu-${c}"; value = "systemctl --user ${c}"; };

          # mkSudoCommand :: String -> { name :: String, value :: String }
          mkSudoCommand = c: { name = "sc-${c}"; value = "sudo systemctl ${c}"; };
        in
        builtins.listToAttrs
          (lib.flatten [
            (builtins.map mkSudoCommand sudoCommands)
            (builtins.map mkSystemCommand powerCommands)
            (builtins.map mkSystemCommand userCommands)
            (builtins.map mkUserCommand sudoCommands)
            (builtins.map mkUserCommand userCommands)
          ]) // {
          # Extra systemctl commands
          sc-disable-now = "sc-disable --now";
          sc-enable-now = "sc-enable --now";
          sc-failed = "systemctl --failed";
          sc-mask-now = "sc-mask --now";
          scu-disable-now = "scu-disable --now";
          scu-enable-now = "scu-enable --now";
          scu-failed = "systemctl --user --failed";
          scu-mask-now = "scu-mask --now";

          # Journalctl commands
          jc-boot = "journalctl -b";
          jc-kernel = "journalctl -k";
          jc-list-boot = "journalctl --list-boots";
          jc-service = "journalctl -u";
          jc-usage = "journalctl --disk-usage";
          jcu-service = "journalctl --user -u";

          # Networkctl commands
          nc-cat = "networkctl cat";
          nc-delete = "networkctl delete";
          nc-down = "networkctl down";
          nc-edit = "networkctl edit";
          nc-frenew = "networkctl forcerenew";
          nc-label = "networkctl label";
          nc-list = "networkctl list";
          nc-lldp = "networkctl lldp";
          nc-mask = "networkctl mask";
          nc-reconfig = "networkctl reconfigure";
          nc-reload = "networkctl reload";
          nc-renew = "networkctl renew";
          nc-status = "networkctl status";
          nc-unmask = "networkctl unmask";
          nc-up = "networkctl up";

          # Resolvectl commands
          rc-query = "resolvectl query";
          rc-service = "resolvectl service";
          rc-openpgp = "resolvectl openpgp";
          rc-tlsa = "resolvectl tlsa";
          rc-status = "resolvectl status";
          rc-stat = "resolvectl statistics";
          rc-reset-stat = "resolvectl reset-statistics";
          rc-flush = "resolvectl flush-caches";
          rc-reset = "resolvectl reset-server-features";
          rc-dns = "resolvectl dns";
          rc-domain = "resolvectl domain";
          rc-default-route = "resolvectl default-route";
          rc-llmnr = "resolvectl llmnr";
          rc-mdns = "resolvectl mdns";
          rc-dnssec = "resolvectl dnssec";
          rc-dnsovertls = "resolvectl dnsovertls";
          rc-nta = "resolvectl nta";
          rc-revert = "resolvectl revert";
          rc-monitor = "resolvectl monitor";
          rc-show-cache = "resolvectl show-cache";
          rc-show-server-state = "resolvectl show-server-state";
          rc-log-level = "resolvectl log-level";

          # Systemd nspawn
          nspawn = "${pkgs.systemdMinimal}/bin/systemd-nspawn";

          # Others
          sxorg = "export DISPLAY=:0.0";
          nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
          mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
          mkdir = "mkdir -pv";
          ios = "sudo --preserve-env=PATH ${pkgs.dmidecode}/bin/dmidecode -t bios";
          # cat = "${pkgs.bat}/bin/bat --paging=never";
          cat = ''bat --paging=never --theme=tokyo_night --style="numbers,changes" --italic-text=always''; # bat (cat)
          ct = ''bat --paging=never --theme=tokyo_night --style="plain" --italic-text=always''; # bat (cat)
          ip = "${pkgs.iproute2}/bin/ip --color --brief";
          less = "${pkgs.bat}/bin/bat --paging=always";
          more = "${pkgs.bat}/bin/bat --paging=always";
          top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
          wget = "${pkgs.wget2}/bin/wget2";
          du = "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
          cp = "${pkgs.advmvcp}/bin/advcp -R --progress-bar";
          cd = "z"; #zoxide (cd)
          mv = "${pkgs.advmvcp}/bin/advmv --progress-bar";
          sk = ''"${pkgs.skim}/bin/sk --ansi -c 'grep -rI --color=always --line-number "{}" .'"'';
          audio = "${pkgs.inxi}/bin/inxi -A";
          battery = "${pkgs.inxi}/bin/inxi -B -xxx";
          bluetooth = "${pkgs.inxi}/bin/inxi -E";
          graphics = "${pkgs.inxi}/bin/inxi -G";
          macros = "cpp -dM /dev/null";
          pci = "sudo ${pkgs.inxi}/bin/inxi --slots";
          process = "${pkgs.inxi}/bin/inxi --processes";
          partitions = "${pkgs.inxi}/bin/inxi -P";
          repos = "${pkgs.inxi}/bin/inxi -r";
          sockets = "${pkgs.iproute2}/bin/ss -lp";
          system = "${pkgs.inxi}/bin/inxi -Fazy";
          usb = "${pkgs.inxi}/bin/inxi -J";
          wifi = "${pkgs.inxi}/bin/inxi -n";
        };

      description = ''
        Create Aliases for systemd tools.
      '';
    };

    process = {
      packages = lib.mkOption {
        type = with lib.types; listOf package;

        default = with pkgs; [
          nodePackages.fkill-cli
          procs
          strace
        ];

        description = ''
          Packages for process management.
        '';
      };

    };

    nix = {
      enable = lib.mkEnableOption "Nix config management" // { default = true; };
      diffProgram = lib.mkOption {
        type = lib.types.enum (builtins.attrNames nixDiffCommands);

        default = assert builtins.hasAttr "builtin" nixDiffCommands; "builtin";
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home = {
        inherit (cfg.systemd) shellAliases;

        packages = lib.flatten [
          cfg.process.packages
        ];
      };
    }

    (lib.mkIf cfg.nix.enable {
      home = {
        packages = [ pkgs.comma ]
          ++ lib.optional (cfg.nix.diffProgram != "builtin") [ pkgs.${cfg.nix.diffProgram} ]
          # ++ lib.optional cfg.nix.cachix.enable [ cfg.nix.cachix.package ]
        ;

        shellAliases = {
          ### Nix Aliases
          # TODO: Make this a separate like OMZ module?
          #
          "n" = "nix";

          "nb" = "nix build";
          "nbr" = "nix build --rebuild";

          "nd" = builtins.getAttr cfg.nix.diffProgram nixDiffCommands; # TODO: Make diff

          "ndev" = "nix develop";

          "ne" = "nix edit";

          "nf" = "nix flake";
          "nfc" = "nix flake check";
          "nfcl" = "nix flake clone";
          "nfi" = "nix flake init";
          "nfl" = "nix flake lock";
          "nfm" = "nix flake metadata";
          "nfs" = "nix flake show";
          "nfu" = "nix flake update";
          "nfuc" = "nix flake update && nix flake check";

          "nfmt" = "nix fmt";

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

          "nsh" = "nix shell";
          # TODO: Replace w/ working function
          # "nshn" = "nix shell nixpkgs";

          "nsd" = "nix show-derivation";

          "nst" = "nix store";
        } // (if builtins.hasAttr "ON_NIXOS" config.home.sessionVariables then {
          "nos" = "nixos-rebuild";
          "nosb" = "nixos-rebuild build";
          "nosbf" = "nixos-rebuild build --flake .";
          "nosc" = "nixos-container";
          "nosg" = "nixos-generate-config";
          "nosp" = "read-link '/nix/var/nix/profiles/system'";
          "nospl" = "ls -r '/nix/var/nix/profiles/system-*'";
          "nossw" = "nixos-rebuild switch --use-remote-sudo";
          "nosswf" = "nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswfc" = "nix flake check && nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswfuc" = "nix flake update && nix flake check && nixos-rebuild switch --use-remote-sudo --flake .";
          "nosswrb" = "nixos-rebuild switch --use-remote-sudo --rollback";
          "nosv" = "nixos-version";
        } else {
          "nos" = "home-manager";
          "nosb" = "home-manager build";
          "nosbf" = "home-manager build --flake .#`hostname`";
          "nossw" = "home-manager switch";
          "nosswf" = "home-manager switch --flake .#`hostname` -b '.bak'";
          "nosswfc" = "nix flake check && home-manager switch --flake .#`hostname` -b '.bak'";
          "nosswfuc" = "nix flake update && nix flake check && home-manager switch --flake .#`hostname` -b '.bak'";
          # "nosswrb" = "home-manager switch --rollback"; # FIXME: Find a workaround?
        });
      };
    })
  ]);
}
