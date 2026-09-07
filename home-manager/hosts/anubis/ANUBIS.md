# 🖥️ Anubis — MacBook Air 4,1 (Mid 2011, 11")

Documentação de hardware e decisões de configuração para o host **Anubis**.

---

## 📋 Hardware

| Componente       | Detalhe                                                        |
| ---------------- | -------------------------------------------------------------- |
| **Modelo**       | Apple MacBook Air 4,1 (Mid 2011, 11")                         |
| **CPU**          | Intel Core i5-2467M (Sandy Bridge, 2C/4T, 800–2300 MHz)       |
| **RAM**          | 2 GB DDR3 (soldada — não expansível)                           |
| **GPU**          | Intel HD Graphics 3000 (driver `i915`, DRI `crocus`)           |
| **Display**      | 1366×768 (11.6", 136 dpi, Apple Color LCD)                     |
| **Storage**      | Apple SSD TS064C (56.5 GiB, SATA 3 Gb/s)                      |
| **WiFi**         | Broadcom BCM43224 802.11a/b/g/n (driver proprietário `wl`)     |
| **Bluetooth**    | Apple Built-in BT 2.0+EDR (btusb, BT 4.0 LMP)                |
| **Áudio**        | Intel 6 Series/C200 HDA (PipeWire)                             |
| **Webcam**       | Apple FaceTime Camera (uvcvideo)                               |
| **Bateria**      | 18.7/35.1 Wh (53.2%), 1340 ciclos                             |
| **Firmware**     | UEFI (Apple EFI v135.0.0.0.0)                                 |

---

## 🖥️ Sistema Operacional

- **Distro**: Fedora Linux 44
- **Gerenciamento do Desktop**: **Home Manager standalone** (não NixOS)
- **Display Manager**: LightDM (instalado via `dnf`, serviço de sistema)
- **WM**: BSPWM (via Home Manager / Nix)
- **Filesystem**: Btrfs com subvolumes (`@` root, `/home`, `/var/log`)
- **Swap**: zram (1.76 GiB, lz4) + partição swap (5 GiB)
- **Boot**: UEFI com EFI partition (`/boot/efi`, 500 MiB)

---

## ⚙️ Decisões de Configuração

### Display Manager (LightDM via Fedora)
O DM **deve ser instalado pelo sistema nativo** (Fedora/dnf), pois Home Manager standalone não tem acesso ao systemd de sistema. O módulo BSPWM do Home Manager já gera automaticamente:
- `~/.local/share/xsessions/bspwm.desktop` — entrada de sessão
- `~/.local/bin/start-bspwm` — wrapper que carrega Nix daemon
- `~/.dmrc` — sessão padrão

### Picom (xrender, sem efeitos)
Com apenas 2 GB de RAM e Intel HD 3000:
- Backend `xrender` (leve, sem shaders pesados)
- Animações desativadas
- Blur desativado
- `useDamage = true` (repinta apenas regiões modificadas)

### Teclado
Layout BR ABNT2 configurado via `home.keyboard` no Home Manager.
Parâmetros de kernel (ex: `hid_apple.swap_opt_cmd`) são configurados diretamente no GRUB do Fedora, fora do escopo do Home Manager.

### Parâmetros de Kernel (Fedora/GRUB)
Gerenciados nativamente no Fedora (`/etc/default/grub`):
```
pci=nomsi pcie_aspm=off iwlwifi.power_save=0 i915.enable_psr=0
zswap.enabled=1 zswap.compressor=lz4 mitigations=auto
```

### Otimização de Memória
Com apenas 2 GB de RAM, evitar pacotes redundantes. Preferir ferramentas leves (ex: `htop` em vez de `btop`).

---

## 🔗 Referências

- Configuração do host: [default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/home-manager/hosts/anubis/default.nix)
- Flake entry: [flake.nix L55-58](file:///mnt/d/workspace/MyRepos/nixfiles/flake.nix#L55-L58)
- Módulo BSPWM (Home Manager): [bspwm/](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/bspwm/)
- Sessão xsessions (não-NixOS): [packages.nix L88-115](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/bspwm/packages.nix#L88-L115)
