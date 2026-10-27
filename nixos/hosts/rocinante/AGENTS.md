# Host `rocinante` — guia do host

Configuração NixOS para o MacBook Pro 4,1 (15 polegadas, Early 2008).

## Contexto

- **Hardware**: MacBook Pro 4,1 (Intel Core 2 Duo Penryn T9300, NVIDIA GeForce 8600M GT 512 MB, Wi-Fi Broadcom BCM4321).
- **Ambiente**: NixOS com DWM-Titus e Quickshell.
- **Saída do flake**: `nixosConfigurations.rocinante`.
- **Entrada**: `nixos/hosts/rocinante/default.nix`.

## Decisões em vigor

- **Boot CSM/Legacy Obrigatório**: `bootType = "legacy"` (GRUB em MBR/BIOS). Em boot EFI puro de 32/64 bits da Apple, a GPU NVIDIA 340 Legacy falha na inicialização com o erro `failed to copy vbios`.
- **Driver NVIDIA 340 Legacy**:
  - Não utilizar `hardware.nvidia`.
  - Drivers carregados via `boot.extraModulePackages = [ legacy340.bin legacy340.mod ]` e `services.xserver.drivers`.
  - `xserver.videoDrivers = lib.mkForce []`.
  - Fix `libglx.so`: overlay com symlink `libglx.so -> libglx.so.340.108`.
- **Dual Boot**: Boot padrão com Nouveau (Kernel Zen) + especialização `specialisation.nvidia` (Linux 6.6 LTS + driver proprietário 340).
- **Wi-Fi Broadcom BCM4321**: Utiliza o driver `broadcom-sta` (módulo de kernel `wl`), permitido explicitamente via `nixpkgs.config.permittedInsecurePackages`.
- **Quickshell**: Renderização forçada em software (`QT_QUICK_BACKEND=software`) devido a limitações de contexto GL no driver 340.
- **Lockscreen**: `betterlockscreen` + `i3lock-color` com serviço PAM configurado.

## Como prosseguir

- Para testar alterações no sistema sem aplicar ao disco de boot:
  `nix build .#nixosConfigurations.rocinante.config.system.build.toplevel --dry-run`

## Validação

```bash
nix eval .#nixosConfigurations.rocinante.config.system.stateVersion
nix build .#nixosConfigurations.rocinante.config.system.build.toplevel --dry-run
```
