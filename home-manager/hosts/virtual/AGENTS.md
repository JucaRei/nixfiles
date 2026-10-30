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

