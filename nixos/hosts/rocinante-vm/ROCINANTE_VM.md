# 🖥️ Host: `rocinante-vm` (Windows Hyper-V & Proxmox KVM)

Configuração virtualizada universal criada para testar e validar o ambiente desktop do **Rocinante** (BSPWM, Polybar, temas, VS Code com Gemini, dotfiles) dentro de máquinas virtuais no **Windows Hyper-V** e **Proxmox VE**.

---

## 🪟 Especificações Recomendadas para Windows Hyper-V

Ao criar a Máquina Virtual no **Gerenciador do Hyper-V (Hyper-V Manager)**:

| Recurso | Configuração Recomendada |
| :--- | :--- |
| **Geração** | **Geração 2 (Generation 2)** (Suporte UEFI / GPT nativo) |
| **Memória** | 4096 MB a 8192 MB (Memória Dinâmica ativada) |
| **Processadores** | 2 a 4 Processadores Virtuais |
| **Rede** | *Default Switch* (NAT com DHCP automático) ou *External Virtual Switch* |
| **Segurança (Secure Boot)** | **Habilitado** com Template: **"Microsoft UEFI Certificate Authority"** (ou desativado) |
| **Disco Rígido** | VHDX SCSI (`/dev/sda`), 32GB a 64GB |

---

## ⚙️ Especificações Recomendadas no Proxmox VE (KVM)

| Recurso | Configuração Recomendada |
| :--- | :--- |
| **OS Type** | Linux 6.x / 2.6 Kernel |
| **BIOS** | **OVMF (UEFI)** |
| **CPU** | Type: **`host`**, 2 Cores |
| **Display** | **SPICE (qxl)** ou **VirtIO-GPU** |
| **Hard Disk** | SCSI com VirtIO SCSI Single (`/dev/sda`), 32GB+ |
| **QEMU Agent** | Habilitado (Enabled: 1) |

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

### 1. Instalação Remota com `nixos-anywhere` (Recomendado - Direto do seu PC) 🚀
Com a VM ligada na ISO do NixOS (ex: no IP `10.10.10.221`), você pode particionar, formatar com Disko e instalar todo o sistema diretamente a partir do terminal da sua máquina principal com **um único comando**:

```bash
# Executado a partir da sua máquina principal (na pasta nixfiles):
nix run nixpkgs#nixos-anywhere -- --flake .#rocinante-vm nixos@10.10.10.221
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
