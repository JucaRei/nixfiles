# Host `nitro` — guia do host

Configuração Home Manager standalone para o Acer Nitro 5 rodando Debian.

## Contexto

- **Hardware**: Acer Nitro 5 (Intel Core i5-8300H, Intel UHD 630 + NVIDIA GeForce GTX 1050 Mobile).
- **Ambiente**: X11 (BSPWM + Polybar).
- **Saída do flake**: `homeConfigurations."juca@nitro"`.
- **Entrada**: `home-manager/hosts/nitro/default.nix`.

## Decisões em vigor

- **nixGL em Optimus**: Definir `nixGLType = "intel"` no `mkHome`. A Intel gerencia o display do Xorg. O `nixGLIntel` é usado para todas as aplicações gráficas do usuário.
- **NVIDIA Modeset (Gotcha Crítico)**: **NUNCA** ativar `nvidia-drm.modeset=1` no kernel/GRUB/modprobe do Debian. Quando o KMS é ativado na NVIDIA no Debian, o Xorg carrega o `libglxserver_nvidia` que quebra o GLX do Mesa/Intel com o erro `failed to find suitable GL configuration`. Manter `modeset=0`.
- **Wi-Fi**: Chipset Intel AC 9560 configurado com backend `iwd` no NetworkManager.
- **BSPWM Multi-Monitor**: Workspaces ímpares (1, 3, 5, 7, 9) na tela primária, pares (2, 4, 6, 8, 0) na secundária.
- **Bluetooth e Dunst**: Auto-trust no startup do BSPWM para dispositivos pareados, `org/blueman/general.notification-daemon = true` para evitar diálogos modais centralizados, e timeout Dunst de 4 segundos.

## Como prosseguir

- Alterações em atalhos e layout do BSPWM devem ser feitas nos módulos de `desktop/environments/bspwm/`.

## Validação

```bash
nix eval .#homeConfigurations."juca@nitro".config.home.stateVersion
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
