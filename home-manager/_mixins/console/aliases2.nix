{ config, lib, pkgs, ... }:

let
  cfg = config.services.aliases;

  nixDiffCommands = {
    builtin = "nix store diff-closures";
    nvd = "nvd diff";
    nix-diff = "nix-diff";
  };
in
{
  options.services.aliases = {
    enable = lib.mkEnableOption "Enable aliases for system" // { default = true; };

    neofetch.enable = lib.mkEnableOption "neofetch config" // { default = true; };

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
          nspawn = "systemd-nspawn";

          # Others
          sxorg = "export DISPLAY=:0.0";
          nix-hash-sha256 = "nix-hash --flat --base32 --type sha256";
          mkhostid = "head -c4 /dev/urandom | od -A none -t x4";
          mkdir = "mkdir -pv";
          ios = "sudo --preserve-env=PATH ${pkgs.dmidecode}/bin/dmidecode -t bios";
          cat = "${pkgs.bat}/bin/bat --paging=never";
          ip = "${pkgs.iproute2}/bin/ip --color --brief";
          less = "${pkgs.bat}/bin/bat --paging=always";
          more = "${pkgs.bat}/bin/bat --paging=always";
          top = "${pkgs.bottom}/bin/btm --basic --tree --hide_table_gap --dot_marker --mem_as_value";
          wget = "${pkgs.wget2}/bin/wget2";
          du = "${pkgs.ncdu}/bin/ncdu --color dark -r -x --exclude .git --exclude .svn --exclude .asdf --exclude node_modules --exclude .npm --exclude .nuget --exclude Library";
          cp = "${pkgs.unstable.advcpmv}/bin/advcp -R --progress-bar";
          mv = "${pkgs.unstable.advcpmv}/bin/advmv --progress-bar";
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
  };

  config = lib.mkIf cfg.enable
    {
      home = {
        inherit (cfg.systemd) shellAliases;
      };
    };
}
