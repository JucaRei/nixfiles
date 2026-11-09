# ❄️ Nixfiles - NixOS & Home Manager Flake

Configuração declarativa e modular para **NixOS** e **Home Manager** (standalone), utilizando **Nix Flakes**.

> 📖 **Guia do Usuário**: Consulte **[docs/COMO-MEXER.md](./docs/COMO-MEXER.md)** para receitas passo a passo de como alterar temas, programas e monitores sem precisar saber Nix.
> 📚 **Referência Completa**: Consulte **[WIKI.md](./WIKI.md)** para a arquitetura técnica e comandos detalhados.

---

## ⚡ Comandos Rápidos

### Utilitário `nx` (Recomendado para o dia a dia)
```bash
./scripts/nx apply             # Aplica alterações no computador atual (com confirmação)
./scripts/nx check             # Valida o repositório dentro dos limites de segurança
./scripts/nx rollback          # Desfaz a última alteração (volta à versão anterior)
./scripts/nx list-generations  # Lista versões anteriores disponíveis
./scripts/nx new-host <nome>   # Cria uma nova máquina a partir do modelo
./scripts/nx themes            # Lista as paletas de cores disponíveis
```

### Home Manager (Standalone em distros tradicionais como Fedora e Debian)
```bash
home-manager switch --flake .#juca@fedora
# Outros hosts: juca@anubis, juca@nitro, juca@virtual, juca@virtualvm, juca@anubisvm
```

### NixOS (Sistema operacional completo com Home Manager integrado)
```bash
sudo nixos-rebuild switch --flake .#rocinante
# Em máquina virtual: sudo nixos-rebuild switch --flake .#rocinante-vm
```

### Verificação do Repositório (com limite de 50% de CPU, 50% de RAM e até 60% de swap)
```bash
nfc
# Em máquinas com pouca memória, use NX_LOW_MEMORY=1 para o modo econômico (40% CPU, 40% RAM, até 60% swap):
# NX_LOW_MEMORY=1 nfc
```

---

## 📂 Estrutura de Diretórios

- **`hosts.nix`**: Registro central de todas as máquinas e imagens.
- **`flake.nix`**: Ponto de entrada do Flake com dependências e saídas.
- **`profiles/`**: Perfis compartilhados de sistema e usuário.
- **`lib/`**: Funções utilitárias e geradores de perfis.
- **`nixos/`**: Configurações de sistema operacional NixOS.
- **`home-manager/`**: Dotfiles e configurações de programas do usuário.
- **`modules/`**: Módulos customizados reutilizáveis.
- **`overlays/`** & **`pkgs/`**: Pacotes próprios e modificações do Nixpkgs.
