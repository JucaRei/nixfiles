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

### 1. Instalação Remota com `nix-anywhere` (Recomendado - Direto do seu PC) 🚀
Com a VM ligada na ISO do NixOS (ex: no IP `10.10.10.221`), você pode particionar, formatar com Disko e instalar todo o sistema diretamente a partir do terminal da sua máquina principal com **um único comando**:

```bash
# Executado a partir da sua máquina principal (na pasta nixfiles):
nix run github:nix-community/nix-anywhere -- --flake .#rocinante-vm nixos@10.10.10.221
```
*(Se a ISO estiver logada como root sem senha, basta usar `root@<IP_DA_VM>` ou definir uma senha temporária com `passwd` na VM antes).*

---

### 2. Instalação Manual via Disko (Direto no Console da VM)
Se preferir rodar os comandos diretamente dentro do console noVNC/SPICE da VM:

```bash
# 1. Particionamento e montagem automática com Disko:
sudo nix --experimental-features "nix-command flakes" run github:nix-community/disko -- \
  --mode zap_create_mount \
  --flake github:JucaRei/nixfiles#rocinante-vm

# 2. Instalação do sistema:
sudo nixos-install --flake github:JucaRei/nixfiles#rocinante-vm
sudo reboot
```

---

### 3. Rebuild do Sistema (Dentro da VM já instalada)
```bash
sudo nixos-rebuild switch --flake .#rocinante-vm
```
*(ou `switch-host`)*
