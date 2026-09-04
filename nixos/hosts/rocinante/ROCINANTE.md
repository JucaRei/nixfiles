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
| [`default.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/default.nix) | Configuração principal do host |
| [`filesystem.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/filesystem.nix) | Montagens BTRFS e swap partition (sem EFI em legacy) |
| [`disko-legacy.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/disko-legacy.nix) | Particionamento declarativo MBR (msdos) puro para BIOS/CSM |
| [`disko.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/disko.nix) | Particionamento GPT anterior (referência) |
| [`modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix`](file:///mnt/d/workspace/MyRepos/nixfiles/modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix) | Módulo do driver NVIDIA 340 Legacy (ativado pela `specialisation`) |

---

## 🧱 Layout de Disco (MBR / msdos puro para Apple CSM / BIOS)

```
/dev/sda1  →  swap (6 GB, partição primária swap nativa)
/dev/sda2  →  NixOS (BTRFS, primária, bootable flag ativada para CSM)
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

## 🖥️ Boot — GRUB BIOS / CSM

| Parâmetro | Valor |
|---|---|
| `bootType` | `"legacy"` — GRUB BIOS `i386-pc` no MBR `/dev/sda` (obrigatório para Apple CSM / VBIOS NVIDIA) |
| `device` | `/dev/sda` |
| `efiSysMountPoint` | `/boot/efi` (partição EFI FAT32 montada com automount / fallback) |
| `default` | `0` (evita `error: sparse file not allowed` no BTRFS) |
| Plymouth | `true` |

### Apple CSM e VBIOS da NVIDIA:
Em modo EFI nativo, o firmware da Apple não espelha a Video BIOS (VBIOS) da GeForce 8600M GT em `0xC0000` e desativa a Option ROM no barramento PCIe, fazendo o driver proprietário falhar com `NVRM: failed to copy vbios to system memory`. O arranque em modo **Legacy BIOS / CSM** (via GRUB `i386-pc` com partição `bios_grub` `/dev/sda1` e Hybrid MBR) ativa a camada de emulação BIOS da Apple, que disponibiliza a VBIOS para o driver NVIDIA.

---

## 🚀 Drivers Gráficos e Boot Dual (Nouveau vs NVIDIA Legacy)

O sistema possui duas opções de arranque configuradas via `specialisation` e selecionáveis no menu GRUB:

1. **Boot Padrão (Nouveau + Kernel Zen)**:
   ```nix
   boot.kernelPackages = pkgs.unstable.linuxPackages_zen;
   hardware.graphics.cards.gpu = null;  # nouveau + Mesa
   ```
   - Kernel Zen do canal `unstable` (baixa latência, agilidade máxima para desktop em Core 2 Duo).
   - Driver gráfico: `nouveau` (open-source, aceleração Mesa 2D/3D nativa na GeForce 8600M GT).
   - Variáveis de aceleração: `LIBVA_DRIVER_NAME=nouveau`, `VDPAU_DRIVER=nouveau`.

2. **Boot Alternativo (`specialisation.nvidia` — Kernel 6.6 LTS + NVIDIA 340 Legacy)**:
   ```nix
   specialisation.nvidia.configuration = {
     system.nixos.tags = [ "nvidia-kernel-6.6" ];
     boot.kernelPackages = pkgs.linuxPackages_6_6;
     boot.kernelParams = [ "nouveau.modeset=0" ];
     hardware.graphics.cards.gpu = "nvidia-legacy";
   };
   ```
   - Kernel 6.6 LTS (último kernel estável compatível com os patches da série 340.108).
   - Driver proprietário NVIDIA 340.108 com aceleração VDPAU completa via hardware.
   - Patch aplicado via overlay em `overlays/patches/legacy340-for-nix-kernel-modules.patch` para resolver incompatibilidade de KBuild em store read-only (Nixpkgs #554929 / PR #555840).


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
**Problema**: `nvidia-kernel-modules-340.108` falhava com `mkdir: cannot create directory 'conftest': Permission denied` no Nixpkgs 26.05 porque a variável KBuild `$src` apontava para o store read-only.
**Solução**: Resolvido via patch em `overlays/patches/legacy340-for-nix-kernel-modules.patch` (baseado no upstream PR #555840 / Issue #554929) injetado através de `modifiedPackages` em `overlays/default.nix`.
**Status**: **Resolvido** — disponível no boot alternativo através da `specialisation.nvidia` com Kernel 6.6 LTS.

### 7. `hardware.nvidia.mod` missing (nixpkgs nvidia.nix)
**Problema**: O módulo `hardware/video/nvidia.nix` do nixpkgs adiciona `nvidia_modeset` e `nvidia_drm` incondicionalmente quando `videoDrivers = [ "nvidia" ]`, módulos que o Legacy 340 não possui.
**Solução**: Configurar o driver directamente em `modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix` via `boot.extraModulePackages = [ legacy340.bin legacy340.mod ]`, `boot.kernelModules = [ "nvidia" ]`, e no X11 usar `services.xserver.drivers` com `modules = [ legacy340.bin ]` e `videoDrivers = lib.mkForce []`.

### 8. Atributo errado do driver NVIDIA legacy
**Problema**: `kernelPackages.nvidiaPackages.legacy_340` não existe no nixpkgs unstable.
**Solução**: O atributo correcto é `kernelPackages.nvidia_x11_legacy340`.

### 9. `broadcom-sta` insecure package (versão dinâmica)
**Problema**: A versão do `broadcom-sta` muda com cada kernel (ex: `broadcom-sta-6.30.223.271-59-6.17.9`). É necessário pré-autorizar todas as versões prováveis.
**Solução**: Lista em `nixpkgs.config.permittedInsecurePackages` **exclusivamente no host rocinante** (não nos módulos globais).

### 10. `overlays/default.nix`: `inherit (final) system` deprecated
**Problema**: Warning `'system' has been renamed to 'stdenv.hostPlatform.system'`.
**Solução**: Usar `inherit (final.stdenv.hostPlatform) system` nos overlays `unstablePackages` e `oldstablePackages`.

### 11. Alternância Automática Cabo Ethernet / Wi-Fi
**Comportamento**: Quando o cabo de rede (Ethernet) é conectado e obtém IP, o rádio Wi-Fi é automaticamente desativado (`nmcli radio wifi off`). Ao desconectar o cabo de rede, o rádio Wi-Fi é reativado imediatamente (`nmcli radio wifi on`).
**Implementação**: Script de dispatcher no NetworkManager (`networking.networkmanager.dispatcherScripts`) associado ao serviço de sincronização no boot (`systemd.services.wifi-wired-autoswitch`).

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
options hid_apple fnmode=1 swap_opt_cmd=0
# fnmode=1: teclas F1-F12 são multimídia por padrão (sem Fn)
# swap_opt_cmd=0: tecla física Command = Super (Mod4), tecla física Option = Alt (Mod1)

# Nível Home-Manager / X11 (BSPWM):
home.keyboard.options = [ "altwin:swap_alt_win" ];
services.xserver.xkb = { layout = "us"; variant = "mac"; options = "terminate:ctrl_alt_bksp"; };
```

---

> 📅 Última actualização: 2026-08-24
> 📝 Gerado durante sessão de instalação e configuração do NixOS na Rocinante via Antigravity IDE
