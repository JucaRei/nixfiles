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
Layout Mac com dead keys para acentos PT-BR (`layout = "us"`, `variant = "intl"`, `model = "apple"`) configurado em duas camadas:
1. **Nível de Sistema (Fedora)**:
   - `localectl set-x11-keymap us apple intl`
   - Arquivo `/etc/X11/xorg.conf.d/00-keyboard.conf` gerado automaticamente garantindo suporte no Xorg e no console virtual (`us-intl`).
2. **Nível de Usuário (Home Manager)**:
   - `home.keyboard = { layout = "us"; variant = "intl"; model = "apple"; };` em [default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/home-manager/hosts/anubis/default.nix).

### Touchpad (Touch to Click, Natural Scrolling)
Configurado permanentemente no Fedora via `/etc/X11/xorg.conf.d/40-libinput.conf`:
- `Tapping = "on"` (Touch to Click ativado nativamente)
- `NaturalScrolling = "true"` (Rolagem natural estilo macOS)
- `ClickMethod = "clickfinger"` (Dois dedos para botão direito)
- `DisableWhileTyping = "true"`

### Controle de Brilho da Tela e Teclado
Permissões no sysfs tornadas persistentes no Fedora via `/etc/tmpfiles.d/backlight.conf`:
```
z /sys/class/backlight/*/brightness 0666 - - -
z /sys/class/leds/*kbd_backlight*/brightness 0666 - - -
```
Pacote `brightnessctl` instalado no Fedora para suporte udev.

### Wi-Fi (Broadcom BCM43224)
- **Driver**: `brcmsmac` + barramento `bcma` (drivers nativos open-source do kernel Linux)
- **Nome da Interface**: `wlp2s0b1`
- **Módulos no Boot**: `/etc/modules-load.d/wifi.conf` contém `bcma` e `brcmsmac`
- **Serviço de Inicialização Pré-Rede**: `/etc/systemd/system/ensure-wifi.service` habilitado no `multi-user.target` garantindo a carga de `bcma` e `brcmsmac` antes do NetworkManager.
- **Prevenção de Quedas (Powersave Desativado)**:
  - `/etc/NetworkManager/conf.d/disable-wifi-powersave.conf` com `wifi.powersave = 2`.
  - Conexão Wi-Fi com `802-11-wireless.powersave = 2`, `connection.autoconnect-retries = 0` (tentativas infinitas de reconexão automática) e `connection.autoconnect-priority = 100`.
- **Initramfs (Dracut)**: Atualizado com `sudo dracut -f` para carregar `bcma`/`brcmsmac` e respeitar a blacklist desde o início do boot.
- **Polkit**: `/etc/polkit-1/rules.d/50-networkmanager.rules` permite ao grupo `wheel` gerenciar conexões do NetworkManager sem prompt de senha.
- **Motivo**: O driver proprietário `wl` causa Kernel Panic (`exitcode=0x00000009`) nas versões recentes do kernel Fedora (7.x) e falhava na associação em redes 5GHz por operar com `passivemode=1`.
- **Configuração ativa em `/etc/modprobe.d/broadcom-wifi.conf`**:
  ```
  blacklist wl
  blacklist ssb
  blacklist b43
  ```
- **Como reverter para o `wl` (se necessário)**:
  ```bash
  sudo cp /etc/modprobe.d/broadcom-wifi.conf.bak /etc/modprobe.d/broadcom-wifi.conf
  sudo cp /etc/modprobe.d/wl-options.conf.bak /etc/modprobe.d/wl-options.conf
  ```

### Resolução de Erros Comuns no `switch-home`
- **Erro `Existing file ... would be clobbered`**:
  - Ocorre quando arquivos de configuração (ex: `~/.config/alacritty/alacritty.toml` ou `~/.config/gtk-3.0/settings.ini`) foram salvos como arquivos normais em vez de symlinks do Nix Store, e já existe um `.backup`.
  - **Solução**: Renomear o arquivo físico conflitante para `.old` (ex: `mv ~/.config/alacritty/alacritty.toml ~/.config/alacritty/alacritty.toml.old`) e rodar `switch-home` novamente.

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
