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
