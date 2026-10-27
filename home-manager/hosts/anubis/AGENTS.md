# Host `anubis` — guia do host

Configuração Home Manager standalone para o MacBook Air 4,1 rodando Fedora.

## Contexto

- **Hardware**: MacBook Air 4,1 (Intel Core i5 Sandy Bridge, GPU integrada Intel HD 3000, 2 GB RAM).
- **Ambiente**: Wayland (MangoWM padrão ou Hyprland como alternativo, Noctalia Shell v5+).
- **Saída do flake**: `homeConfigurations."juca@anubis"`.
- **Entrada**: `home-manager/hosts/anubis/default.nix`.

## Decisões em vigor

- **Restrição Severa de RAM (2 GB)**: Desativar obrigatoriamente `system.programs.browsers.psd.enable = false`. O `tmpfs` em `/run/user/1000` limitado a 10% da RAM (~180 MB) estoura rapidamente e causa erros de `No space left on device (28)` e crashes em navegadores.
- **Intel HD 3000 (Sandy Bridge)**:
  - Driver VA-API: `i965` (`intel-vaapi-driver`). `LIBVA_DRIVER_NAME = "i965"`.
  - Configurações gráficas: `debug.vfr = false`, `cursor.no_hardware_cursors = true`, `render.direct_scanout = 0`.
  - Papel de parede: utilizar `swaybg` (o `hyprpaper` não suporta PRIME export no Sandy Bridge).
  - Idle fade: `pre_action_fade_seconds = 0.0` no Noctalia para evitar flickering.
- **MangoWM**: Sintaxe estrita `snake_case` em todas as diretivas.
- **Backlight**: Controlado via ACPI nativo (`acpi_backlight=native`) em passos graduais de 2%.

## Como prosseguir

- Ao editar configurações do MangoWM ou Noctalia, valide sintaxe com `mango -c ~/.config/mango/config.conf -p`.

## Validação

```bash
nix eval .#homeConfigurations."juca@anubis".config.home.stateVersion
nix build .#homeConfigurations."juca@anubis".activationPackage --dry-run
```
