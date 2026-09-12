# 🖥️ Host: `rocinante-hyperv` (Windows Hyper-V Virtual Machine)

Configuração virtualizada criada para testar e executar o ambiente desktop do **Rocinante** (BSPWM, Polybar, temas, VS Code com Gemini, dotfiles) dentro de uma máquina virtual no **Windows Hyper-V**.

---

## 🪟 Especificações Recomendadas no Gerenciador do Hyper-V

Ao criar a Máquina Virtual no **Hyper-V Manager**:

| Recurso | Configuração Recomendada |
| :--- | :--- |
| **Geração** | **Geração 2 (Generation 2)** (Suporte UEFI / GPT nativo) |
| **Memória** | 4096 MB a 8192 MB (Memória Dinâmica ativada) |
| **Processadores** | 2 a 4 Processadores Virtuais |
| **Rede** | **Default Switch** (NAT com DHCP automático) ou *External Virtual Switch* |
| **Segurança (Secure Boot)** | **Habilitado** com Template: **"Microsoft UEFI Certificate Authority"** (ou desativado) |
| **Disco Rígido** | VHDX SCSI (`/dev/sda`), 32GB a 64GB |

---

## 📦 Serviços e Integrações Hyper-V Incluídos

1. **`virtualisation.hypervGuest.enable = true`**:
   - Daemons nativos do Hyper-V (VSS para snapshots consistentes, KVP, FCOPY e Heartbeat de status no Windows).
2. **Drivers Sintéticos Hyper-V**:
   - `hv_vmbus`, `hv_storvsc`, `hv_netvsc`, `hv_balloon`, `hv_utils`, `hyperv_fb`, `hid_hyperv`.
3. **Resolução Full HD Nativa**:
   - `video=hyperv_fb:1920x1080` para console nítido em 1080p.
4. **Nix-LD**:
   - Carregador dinâmico de bibliotecas ativo para executar servidores de IDE e extensões do VS Code sem crashes.
5. **Rede e DNS Technitium**:
   - `nameservers = [ "10.10.10.25" "1.1.1.1" "8.8.8.8" ]`
   - `search = [ "home.lan" ]`
   - `hostname = "rocinante-hyperv"`

---

## 🚀 Como Instalar via `nixos-anywhere`

1. Ligue a VM dando boot pela ISO do NixOS (ex: `iso-xfce4` ou `nixos-minimal`).
2. No console da VM no Hyper-V, defina uma senha temporária:
   ```bash
   sudo passwd nixos
   ```
3. Descubra o IP da VM com `ip -c a`.
4. No terminal da sua máquina principal (na pasta `nixfiles`):
   ```bash
   nix run nixpkgs#nixos-anywhere -- --flake .#rocinante-hyperv nixos@<IP_DA_VM_HYPERV>
   ```

---

## 🔄 Rebuild do Sistema (Dentro da VM já instalada)
```bash
sudo nixos-rebuild switch --flake .#rocinante-hyperv
```

---

## 🛠️ Notas de Resolução e Troubleshooting

- **Partição EFI e Erro `failed to get canonical path of systemd-1`**:
  - O NixOS monta a partição EFI através de `/dev/disk/by-label/EFI`. Se a partição FAT32 (ex: `/dev/sda2`) não possuir o label `EFI`, o `boot-efi.mount` falha e o systemd mantém apenas o stub de automount (`systemd-1` via autofs).
  - O `grub-install` não consegue resolver pipes `autofs` e falha com `failed to get canonical path of 'systemd-1'` e `Inappropriate ioctl for device`.
  - **Correção**: Atribuir o label correto à partição EFI:
    ```bash
    sudo fatlabel /dev/sda2 EFI
    sudo udevadm trigger
    sudo systemctl restart boot-efi.mount
    ```

