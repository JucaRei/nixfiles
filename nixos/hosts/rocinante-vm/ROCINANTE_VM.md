# 🖥️ Host: `rocinante-vm` (Proxmox / KVM Virtual Machine)

Configuração virtualizada criada para testar e validar o ambiente desktop do **Rocinante** (BSPWM, Polybar, temas, VS Code com Gemini, dotfiles) dentro de uma máquina virtual no **Proxmox VE**.

---

## ⚙️ Especificações Recomendadas da VM no Proxmox VE

Para obter a melhor performance e integração gráfica com o SPICE/noVNC:

| Recurso | Configuração Recomendada |
| :--- | :--- |
| **OS Type** | Linux 6.x / 2.6 Kernel |
| **BIOS** | **OVMF (UEFI)** (Recomendado) ou SeaBIOS |
| **Machine** | `q35` ou `i440fx` |
| **CPU** | Type: `host` (habilita AES-NI e todas as instruções da CPU do servidor), 2 a 4 Cores |
| **Memory** | 4096 MB a 8192 MB (com Ballooning ativado) |
| **Display** | **SPICE (qxl)** ou **VirtIO-GPU** (para suporte a 3D e redimensionamento automático) |
| **Hard Disk** | VirtIO Block (`/dev/vda`) ou SCSI com VirtIO SCSI Single (`/dev/sda`), 32GB+ |
| **Network** | VirtIO (paravirtualized), Bridge `vmbr0` |
| **QEMU Agent** | **Habilitado** (Enabled: 1) |

---

## 📦 Serviços e Otimizações de VM Incluídos

1. **`qemuGuest.enable = true`**:
   - Integração completa com o painel do Proxmox (status do IP na aba *Summary*, desligamento limpo sem corromper Btrfs, e `fsfreeze` antes de snapshots).
2. **`spice-vdagentd.enable = true`**:
   - Redimensionamento dinâmico da resolução da tela ao redimensionar a janela do console SPICE.
   - Clipboard bidirecional (copiar e colar texto entre seu computador e a VM).
3. **Drivers VirtIO Paravirtualizados**:
   - `virtio_net`, `virtio_pci`, `virtio_blk`, `virtio_scsi`, `virtio_balloon`, `virtio_gpu`, `qxl`.
4. **Nix-LD**:
   - Carregador dinâmico de bibliotecas ativo para executar servidores de IDE e extensões do VS Code sem crashes.
5. **Rede e DNS Technitium**:
   - `nameservers = [ "10.10.10.25" "1.1.1.1" "8.8.8.8" ]`
   - `search = [ "home.lan" ]`
   - `hostname = "rocinante-vm"`

---

## 🚀 Como Instalar / Aplicar na VM

### 1. Instalação via Disko (A partir de uma ISO NixOS)
Dê boot na VM pela ISO do NixOS (ex: `iso-xfce4` ou `iso-console`) e execute:

```bash
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode zap_create_mount \
  --flake github:JucaRei/nixfiles#rocinante-vm

sudo nixos-install --flake github:JucaRei/nixfiles#rocinante-vm
sudo reboot
```

### 2. Rebuild do Sistema (Dentro da VM já instalada)
```bash
sudo nixos-rebuild switch --flake .#rocinante-vm
```
*(ou `switch-host`)*

### 3. Rebuild do Home Manager Standalone
```bash
home-manager switch --flake .#juca@rocinante-vm
```
