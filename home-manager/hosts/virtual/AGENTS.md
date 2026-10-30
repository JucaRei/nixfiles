# Host `virtual` — guia do host

Configuração Home Manager standalone para VM de testes no Proxmox rodando Debian (simula o host `nitro`).

## Contexto

- **Hardware**: VM Proxmox (QEMU Standard VGA `1234:1111`, bochs-drm, sem aceleração por hardware dedicada).
- **Rede / Acesso**: IP `10.10.10.233`, usuário `juca`.
- **Ambiente**: X11 (BSPWM + Polybar + LightDM).
- **Monitor**: `Virtual-1` (Full HD 1920x1080 @ 60Hz).
- **Saída do flake**: `homeConfigurations."juca@virtual"`.
- **Entrada**: `home-manager/hosts/virtual/default.nix`.

## Decisões em vigor

- **Finalidade**: Host de testes para validação de switches e integridade de módulos antes ou após alterações no repositório.
- **Gráficos**: Como roda sob QEMU VGA no Debian, utiliza fallback de software rasterizer (swrast/Mesa). Gráficos híbridos desativados (`multimedia.mpv.hybridGraphics = false`).
- **Polybar**: O módulo de bateria é desativado automaticamente pela Polybar na ausência de sensores físicos de bateria (`/sys/class/power_supply`).

## Validação e Teste de Switch

```bash
# Validação sintática e dry-run local
nix eval .#homeConfigurations."juca@virtual".config.home.stateVersion
nix build .#homeConfigurations."juca@virtual".activationPackage --dry-run

# Teste de switch remoto na VM
OUT=$(nix build .#homeConfigurations."juca@virtual".activationPackage --no-link --print-out-paths)
nix copy --to ssh://juca@10.10.10.233 "$OUT"
ssh -t juca@10.10.10.233 "HOME_MANAGER_BACKUP_EXT=backup $OUT/activate"
```

## Gotchas do host

- **Espaço de Build e `/tmp` em RAM (`tmpfs`)**: No Debian, `/tmp` é montado em `tmpfs` limitado a ~1.4 GB. Builds de derivações locais pesadas estouram com `No space left on device`. O `TMPDIR` no `home.sessionVariables` aponta para `/var/tmp` (65 GB em disco), e o `nix-daemon` no sistema requer override em `/etc/systemd/system/nix-daemon.service.d/override.conf` com `Environment="TMPDIR=/var/tmp"`.
- **Pacotes unfree/pesados (ex: RustDesk GUI)**: Pacotes unfree não possuem binários no cache oficial (`cache.nixos.org`) e forçam compilação local da fonte. Na VM de 2 vCPUs e 2.8 GB de RAM, prefira Flatpak (`system.services.flatpak.packages`) para evitar compilações longas e crashes de OOM.
- **Podman rootless**: O Podman opera de forma rootless sob o usuário `juca` via user systemd. Nunca executar comandos `podman` ou `docker` com `sudo`.


