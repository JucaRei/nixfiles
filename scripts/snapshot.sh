#!/usr/bin/env bash
set -euo pipefail

if [ -z "${1:-}" ]; then
  echo "Uso: $0 <rotulo>" >&2
  exit 1
fi

LABEL="$1"
SNAPSHOT_DIR=".snapshots/$LABEL"
mkdir -p "$SNAPSHOT_DIR"

HM_EXPR='
cfg:
let
  sanitize = val:
    let ev = builtins.tryEval val; in
    if !ev.success then "<eval-error>"
    else
      let v = ev.value; in
      if builtins.isAttrs v then
        if (v._type or "") == "derivation" || (v.type or "") == "derivation" then
          (v.pname or v.name or "<derivation>")
        else
          builtins.mapAttrs (_: sanitize)
            (builtins.removeAttrs v [ "_module" "_override" "content" "source" ])
      else if builtins.isList v then map sanitize v
      else if builtins.isFunction v then "<function>"
      else v;

  sortList = builtins.sort (a: b: a < b);
  pkgNames = map (p: let ev = builtins.tryEval (p.pname or p.name or "pkg"); in if ev.success then ev.value else "<error>") (cfg.home.packages or []);
  files = builtins.attrNames (cfg.home.file or {});
  services = builtins.attrNames (cfg.systemd.user.services or {});
  desktopOpts = if cfg ? desktop then sanitize cfg.desktop else {};
  systemOpts = if cfg ? system then sanitize cfg.system else {};
in {
  kind = "home-manager";
  homePackages = sortList pkgNames;
  homeFiles = sortList files;
  systemdServices = sortList services;
  desktop = desktopOpts;
  system = systemOpts;
}
'

NIXOS_EXPR='
cfg:
let
  sanitize = val:
    let ev = builtins.tryEval val; in
    if !ev.success then "<eval-error>"
    else
      let v = ev.value; in
      if builtins.isAttrs v then
        if (v._type or "") == "derivation" || (v.type or "") == "derivation" then
          (v.pname or v.name or "<derivation>")
        else
          builtins.mapAttrs (_: sanitize)
            (builtins.removeAttrs v [ "_module" "_override" "content" "source" "build" ])
      else if builtins.isList v then map sanitize v
      else if builtins.isFunction v then "<function>"
      else v;

  sortList = builtins.sort (a: b: a < b);
  pkgNames = map (p: let ev = builtins.tryEval (p.pname or p.name or "pkg"); in if ev.success then ev.value else "<error>") (cfg.environment.systemPackages or []);
  services = builtins.attrNames (cfg.systemd.services or {});
  fsSummary = builtins.mapAttrs (_mp: fs: {
    device = fs.device or null;
    fsType = fs.fsType or null;
    options = fs.options or [];
  }) (cfg.fileSystems or {});
  bootLoader = sanitize (cfg.boot.loader or {});
  desktopOpts = if cfg ? desktop then sanitize cfg.desktop else {};
  systemOpts = if cfg ? system then sanitize (builtins.removeAttrs cfg.system [ "build" ]) else {};

  hmUser = cfg.home-manager.users.juca or (cfg.home-manager.users.nixos or null);
  hmPkgNames = if hmUser != null then map (p: let ev = builtins.tryEval (p.pname or p.name or "pkg"); in if ev.success then ev.value else "<error>") (hmUser.home.packages or []) else [];
  hmFiles = if hmUser != null then builtins.attrNames (hmUser.home.file or {}) else [];
  hmDesktop = if hmUser != null && (hmUser ? desktop) then sanitize hmUser.desktop else {};
  hmSystem = if hmUser != null && (hmUser ? system) then sanitize hmUser.system else {};
in {
  kind = "nixos";
  systemPackages = sortList pkgNames;
  systemdServices = sortList services;
  fileSystems = fsSummary;
  bootLoader = bootLoader;
  desktop = desktopOpts;
  system = systemOpts;
  homeManager = if hmUser != null then {
    homePackages = sortList hmPkgNames;
    homeFiles = sortList hmFiles;
    desktop = hmDesktop;
    system = hmSystem;
  } else null;
}
'

echo "=== Gravando snapshot: $LABEL ==="

# 1. Home Manager hosts
echo "--> Extraindo Home Manager configurations..."
mapfile -t hm_hosts < <(nix eval --raw .#homeConfigurations --apply 'cfg: builtins.concatStringsSep "\n" (builtins.attrNames cfg)')
for host in "${hm_hosts[@]}"; do
  [ -z "$host" ] && continue
  echo "    * HM: $host"
  nix eval --json ".#homeConfigurations.\"$host\".config" --apply "$HM_EXPR" > "$SNAPSHOT_DIR/$host.json"
done

# 2. NixOS hosts
echo "--> Extraindo NixOS configurations..."
mapfile -t nixos_hosts < <(nix eval --raw .#nixosConfigurations --apply 'cfg: builtins.concatStringsSep "\n" (builtins.attrNames cfg)')
for host in "${nixos_hosts[@]}"; do
  [ -z "$host" ] && continue
  echo "    * NixOS: $host"
  nix eval --json ".#nixosConfigurations.\"$host\".config" --apply "$NIXOS_EXPR" > "$SNAPSHOT_DIR/$host.json"
done

echo "=== Snapshot '$LABEL' salvo em $SNAPSHOT_DIR ==="
