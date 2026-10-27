# Hyprland — guia do ambiente

Compositor Wayland dinâmico com efeitos e animações avançadas.

## Contexto

Utilizado como alternativa Wayland em hosts como `anubis`.
Entrada do módulo: `default.nix`.

## Decisões em vigor

- **Sintaxe Hyprland 0.55+**:
  - `configType = "hyprlang"`
  - Usar `windowrule` (a diretiva legada `windowrulev2` foi unificada)
  - Gestos: `gesture = [ "3, horizontal, workspace" ]`
- **Gotchas de GPU Legada (Intel HD 3000 / Sandy Bridge)**:
  - `debug.vfr = false`
  - `cursor.no_hardware_cursors = true`
  - `render.direct_scanout = 0`
  - Papel de parede: `hyprpaper` falha no Sandy Bridge devido a ausência de suporte a PRIME export; utilizar `swaybg`.
- **Lockscreen**: Hyprlock requer provisionamento de `/etc/pam.d/hyprlock` com `system-auth` em distros standalone.

## Como prosseguir

- Ao atualizar sintaxe ou opções, verificar a wiki oficial do Hyprland para evitar opções descontinuadas.
- Cores de bordas e acentos devem vir de `config.desktop.theme.colorsBare`.

## Validação

```bash
nix-instantiate --parse modules/home-manager/desktop/environments/hyprland/default.nix
nix build .#homeConfigurations."juca@anubis".activationPackage --dry-run
```
