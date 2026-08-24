# 🖥️ Rocinante — Memória e Documentação do Host

> **MacBook Pro 4,1 (Early 2008)** — NixOS via `nixos-anywhere`

---

## 📦 Inventário de Hardware

| Componente | Detalhe |
|---|---|
| **Modelo** | MacBook Pro 4,1 (MacBookPro4,1) |
| **CPU** | Intel Core 2 Duo Penryn (2 núcleos, ~2.4–2.5 GHz) |
| **RAM** | 6 GB (canal assimétrico: 4 GB + 2 GB) |
| **GPU** | NVIDIA GeForce 8600M GT (G84 / NV50 / família NV50) |
| **Wi-Fi** | Broadcom BCM43xx (requer driver proprietário `broadcom-sta` / módulo `wl`) |
| **Chipset** | Intel ICH8-M |
| **Firmware EFI** | 32-bit EFI com CPU 64-bit — arranque híbrido obrigatório |
| **SSD** | Substituiu o HDD original |
| **Disco** | `/dev/sda` |
| **Partição BIOS-Boot** | `/dev/sda1` (2M, EF02) |
| **Partição EFI** | `/dev/sda2` (512M, FAT32, label `EFI`) |
| **Partição Swap** | `/dev/sda3` (6 GB, label `swap`) |
| **Partição BTRFS** | `/dev/sda4` (label `NixOS`) |

---

## 🗂️ Ficheiros Relevantes

| Ficheiro | Papel |
|---|---|
| [`default.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/default.nix) | Configuração principal do host |
| [`filesystem.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/filesystem.nix) | Montagens BTRFS, swap partition e EFI |
| [`disko.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/disko.nix) | Definição declarativa das partições |
| [`modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix) | Módulo do driver NVIDIA 340 Legacy (ativado pela `specialisation`) |

---

## 🧱 Layout de Disco (BTRFS + Swap Dedicado)

```
/dev/sda1  →  BIOS-BOOT (2 MB, BIOS MBR/GPT fallback)
/dev/sda2  →  EFI  (FAT32, 512 MB, montado em /boot/efi)
/dev/sda3  →  swap (6 GB, partição swap nativa)
/dev/sda4  →  NixOS (BTRFS)
  ├── @             →  /
  ├── @home         →  /home
  ├── @nix          →  /nix
  ├── @snapshots    →  /.snapshots
  └── @var_log      →  /var/log
```

### Opções de montagem BTRFS (`btrfsOpts`):
```
rw, noatime, ssd, compress-force=zstd:2, space_cache=v2, commit=120, discard=async
```

### Swap em Partição Dedicada:
- Tamanho: **6 GB** em `/dev/disk/by-label/swap`
- Prioridade: `10` (fallback de emergência — o ZRAM tem prioridade `100`)
- Vantagem: Elimina problemas de ordenação systemd, fragmentação e compatibilidade de swapfile em BTRFS.

---

## 🖥️ Boot — GRUB Híbrido

| Parâmetro | Valor |
|---|---|
| `bootType` | `"hybrid-legacy"` — GRUB BIOS i386-pc (obrigatório para EFI 32-bit) |
| `device` | `/dev/sda` |
| `efiSysMountPoint` | `/boot/efi` (auto-detectado pelo módulo de boot) |
| `default` | `0` (evita `error: sparse file not allowed` no BTRFS) |
| Plymouth | **desativado** (`plymouth = false`) |

### Problema do firmware EFI 32-bit:
O MacBook Pro 4,1 tem firmware EFI 32-bit mas CPU 64-bit. O arranque com ISOs NixOS padrão e Ventoy falhou com erros como `hv_vmbus`, `initrd-find-nixos-closure`. A solução foi criar a ISO personalizada `iso-rocinante` com `boot.initrd.systemd.enable = mkForce false`.

---

## 🚀 Opções de Boot no Menu do GRUB

### 1. Padrão — Kernel Zen + Nouveau

```nix
boot.kernelPackages = pkgs.unstable.linuxPackages_zen;
hardware.graphics.cards.gpu = null;  # usa nouveau + Mesa
```

- Kernel Zen do canal `unstable` (baixa latência, otimizado para desktop)
- Driver gráfico: `nouveau` (open-source, aceleração Mesa 2D/3D nativa na NV50)
- Variáveis: `LIBVA_DRIVER_NAME=nouveau`, `VDPAU_DRIVER=nouveau`

### 2. Especialização `nvidia` — Kernel 7.2 + NVIDIA 340 Legacy

```nix
specialisation.nvidia.configuration = {
  boot.kernelPackages = lib.mkForce pkgs.unstable.linuxPackages_7_2;
  hardware.graphics.cards.gpu = lib.mkForce "nvidia-legacy";
};
```

- Kernel: `pkgs.unstable.linuxKernel.packages.linux_7_2` (`linuxPackages_7_2`)
- Driver: `pkgs.unstable.linuxKernel.packages.linux_7_2.nvidia_x11_legacy340` (injetado via `config.boot.kernelPackages.nvidia_x11_legacy340`)
- Configurado diretamente via `boot.extraModulePackages` e `services.xserver` sem ativar o módulo incompatível `hardware/video/nvidia.nix`


---

## 📡 Wi-Fi — Broadcom BCM43xx

O chip Wi-Fi BCM43xx requer o driver proprietário `broadcom-sta` (módulo `wl`):

```nix
# No boot:
boot.blacklistedKernelModules = [ "b43" "b43legacy" "bcma" "brcmsmac" "brcmfmac" "ssb" ];
boot.extraModulePackages = [ config.boot.kernelPackages.broadcom_sta ];

# Permissão local ao host (não global):
nixpkgs.config.permittedInsecurePackages = [
  "broadcom-sta-6.30.223.271-59-6.17.9"
  "broadcom-sta-6.30.223.271-63-7.1.7"
  "broadcom-sta-6.30.223.271-63-7.1.5"
  # ... (ver default.nix para lista completa)
];
```

### Fixes de repetidor Wi-Fi:
```nix
networking.networkmanager.wifi.scanRandMacAddress = false;  # MAC fixo
networking.networkmanager.wifi.powersave = false;            # sem hibernação Wi-Fi
```

---

## 🧠 Memória Virtual e ZRAM

| Parâmetro | Valor | Razão |
|---|---|---|
| `zramSwap.algorithm` | `lz4` | Menor latência de CPU que zstd — ideal para dual-core Penryn |
| `zramSwap.memoryPercent` | `75` | ~4.5 GB de ZRAM nos 6 GB de RAM |
| `zramSwap.priority` | `100` | Maior prioridade que o swapfile em disco |
| `vm.swappiness` | `180` | Prioriza compactar RAM antes de tocar o SSD |
| `vm.page-cluster` | `0` | Desativa swap em blocos — essencial para descompactação ZRAM sem latência |
| `vm.vfs_cache_pressure` | `50` | Mantém caches de inodes/dirs em RAM |
| `zswap.enabled=0` | kernel param | Desativado: dupla compressão com ZRAM seria desperdiçadora |

---

## ⚡ Parâmetros de Kernel

```
pcie_aspm=force          # Economia de energia no barramento PCIe (ICH8-M)
zswap.enabled=0          # ZRAM substitui zswap completamente
mitigations=off          # Ganho de 15-25% em Core 2 Duo Penryn (uso doméstico)
nowatchdog               # Libera ciclos de CPU do lockup detector
nouveau.modeset=1        # Garante KMS activo para NV50 (boot padrão)
transparent_hugepage=madvise  # Reduz fragmentação de memória nos 6 GB
elevator=bfq             # Scheduler de I/O de baixa latência para SSD
```

---

## 🌡️ Gestão Térmica e Energia

### MBPFan (curva optimizada para Penryn):
```nix
services.mbpfan.settings.general = {
  min_fan1_speed = 2000;
  max_fan1_speed = 6000;
  low_temp  = 50;   # inicia a acelerar aos 50°C
  high_temp = 68;   # máxima rotação aos 68°C
  max_temp  = 82;   # desligamento de segurança
  polling_interval = 2;
};
```

### TLP (governors optimizados para Core 2 Duo):
```nix
CPU_SCALING_GOVERNOR_ON_AC = "schedutil";    # frequência adaptativa rápida
CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
SATA_LINKPWR_ON_AC  = "med_power_with_dipm";
SATA_LINKPWR_ON_BAT = "min_power";
```

> `thermald` está **desativado** — suporta apenas Sandy Bridge+; Penryn/ICH8-M não é suportado.

---

## 👤 Utilizadores

| User | Shell | Senha inicial | SSH |
|---|---|---|---|
| `root` | (default) | `pass` (`initialPassword`) | Chave Ed25519 do Reinaldo |
| `juca` | `bash` (nível sistema) | `pass` (`initialPassword`) | Chave Ed25519 do Reinaldo |

> `juca` usa `zsh` configurado via Home Manager (após activação do home-manager).
> O shell no nível NixOS é `bash` para garantir login fiável no TTY (zsh requer `programs.zsh.enable = true` global).

---

## 🔑 Acesso SSH

```bash
ssh root@<IP>   # sem senha se a chave estiver presente
ssh juca@<IP>
```

Chave pública já incluída em `openssh.authorizedKeys.keys`:
```
ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINrd5yF/0aMECHqkM1oNrOX5QBQ4sYbkiNR15XzBGkUU Reinaldo P Jr
```

---

## 🔧 Problemas Conhecidos e Soluções

### 1. ISO NixOS não arranca (Ventoy / EFI 32-bit)
**Problema**: `initrd-find-nixos-closure`, `hv_vmbus`, `no init= parameter`.
**Causa**: O initrd systemd não funciona com firmware EFI 32-bit / Ventoy.
**Solução**: ISO personalizada `iso-rocinante` com `boot.initrd.systemd.enable = mkForce false`.

### 2. GRUB `error: sparse file not allowed` (BTRFS)
**Problema**: `boot.loader.grub.default = "saved"` incompatível com BTRFS.
**Solução**: `default = 0;` no módulo de boot.

### 3. Ordenação do Swapfile (ciclo systemd)
**Problema**: `Ordering cycle found, skipping /swap` e `Ordering cycle found, skipping Swaps`.
**Solução**: `systemd.services.btrfs-swapfile-init` com `DefaultDependencies = false`, `after = ["local-fs.target"]`, `before = ["swap.target"]`.

### 4. Login no TTY reseta imediatamente
**Problema**: O shell do utilizador `juca` era `zsh`, mas `programs.zsh.enable = true` não estava activado globalmente no NixOS → PAM rejeita o shell ausente de `/etc/shells`.
**Solução**: `programs.zsh.enable = true` em `modules/nixos/default.nix`; shell padrão revertido para `bash` no nível do NixOS.

### 5. Home Manager: `settings.json: No such file or directory`
**Problema**: O script de activação do VSCode tentava escrever `settings.json` sem o diretório pai existir.
**Solução**: `mkdir -p "${settingsDir}"` antes de escrever o ficheiro.

### 6. Driver NVIDIA 340 Legacy não compila
**Problema**: `nvidia-kernel-modules-340.108` falha com `mkdir: cannot create directory 'conftest': Permission denied` — o instalador antigo de 2019 tenta escrever na árvore de fontes read-only do kernel no sandbox do Nix.
**Status**: **Não resolvido** — o pacote `nvidiaPackages.legacy_340` está quebrado no NixOS moderno, mesmo no kernel 5.15. A opção de boot padrão usa `nouveau` que funciona perfeitamente.

### 7. `hardware.nvidia.mod` missing (nixpkgs nvidia.nix)
**Problema**: O módulo `hardware/video/nvidia.nix` do nixpkgs 25.05 exige que o package do driver tenha atributos `.mod` e `.open`, que `nvidia_x11_legacy340` não possui.
**Solução**: **Não usar `hardware.nvidia`** — configurar o driver directamente via `boot.extraModulePackages` e `boot.kernelModules`. O `xserver.videoDrivers` fica vazio (`lib.mkForce []`); o módulo kernel carregado no boot é suficiente para o X11 detectar e usar o driver.

### 8. Atributo errado do driver NVIDIA legacy
**Problema**: `kernelPackages.nvidiaPackages.legacy_340` não existe no nixpkgs unstable.
**Solução**: O atributo correcto é `kernelPackages.nvidia_x11_legacy340`.

### 9. `broadcom-sta` insecure package (versão dinâmica)
**Problema**: A versão do `broadcom-sta` muda com cada kernel (ex: `broadcom-sta-6.30.223.271-59-6.17.9`). É necessário pré-autorizar todas as versões prováveis.
**Solução**: Lista em `nixpkgs.config.permittedInsecurePackages` **exclusivamente no host rocinante** (não nos módulos globais).

### 10. `overlays/default.nix`: `inherit (final) system` deprecated
**Problema**: Warning `'system' has been renamed to 'stdenv.hostPlatform.system'`.
**Solução**: Usar `inherit (final.stdenv.hostPlatform) system` nos overlays `unstablePackages` e `oldstablePackages`.

---

## 🚀 Implantação via `nixos-anywhere`

```bash
# No directório do repositório:
nix run github:nix-community/nixos-anywhere -- \
  --flake .#rocinante \
  --target-host nixos@<IP>
```

### Pré-requisitos no Live USB (ambiente `nixos`):
- Utilizador: `nixos`, senha: `admin`
- SSH activo e acessível
- Partições formatadas por `disko.nix` (feito automaticamente pelo nixos-anywhere)

### Após implantação:
```bash
# Ligar ao Wi-Fi:
nmcli dev wifi connect "NOME_REDE" password "SENHA"

# Mudar a senha do utilizador:
passwd juca

# Activar home-manager:
home-manager switch --flake .#juca@rocinante
```

---

## 📋 Checklist de Arranque Limpo

- [ ] Boot no Live USB (ISO personalizada `iso-rocinante`)
- [ ] Obter IP via DHCP ou cabo Ethernet
- [ ] Executar `nixos-anywhere`
- [ ] Reiniciar após instalação
- [ ] Login no TTY (usuário `juca` ou `root`, senha `pass`)
- [ ] Ligar ao Wi-Fi com `nmcli`
- [ ] Verificar boot Nouveau com `glxinfo | grep "OpenGL renderer"`
- [ ] Opcional: reiniciar para a especialização `nvidia` no GRUB
- [ ] `home-manager switch --flake .#juca@rocinante` (após clonar o repo)
- [ ] Mudar senha com `passwd`

---

## 🌐 Teclado Apple

```nix
# Nível kernel (modprobe):
options hid_apple fnmode=1 swap_opt_cmd=1
# fnmode=1: teclas F1-F12 são multimídia por padrão (sem Fn)
# swap_opt_cmd=1: troca fisicamente Command e Option

# Nível X11:
services.xserver.xkb = { layout = "us"; variant = "mac"; options = "terminate:ctrl_alt_bksp"; };
```

---

> 📅 Última actualização: 2026-08-24
> 📝 Gerado durante sessão de instalação e configuração do NixOS na Rocinante via Antigravity IDE
