# ❄️ Nixfiles - NixOS & Home Manager Flake

Configuração declarativa e modular para **NixOS** e **Home Manager** (standalone), utilizando **Nix Flakes**.

> 📖 **Documentação Completa**: Consulte o arquivo **[WIKI.md](file:///d:/workspace/MyRepos/nixfiles/WIKI.md)** para o guia detalhado de arquitetura, todos os comandos do NixOS, Home Manager, testes e manutenção.

---

## ⚡ Comandos Rápidos

### Home Manager (Stand-alone em distros não-NixOS ex: Fedora, Arch)
```bash
home-manager switch --flake .#juca@fedora
```

### NixOS System (Com Home Manager integrado)
```bash
sudo nixos-rebuild switch --flake .#virtualvm
```

### Validar e Testar o Repositório
```bash
nix flake check
```

---

## 📂 Estrutura de Diretórios

- **`flake.nix`**: Ponto de entrada com máquinas e dependências.
- **`lib/`**: Helpers para geração de perfis (`mkNixos` e `mkHome`).
- **`nixos/`**: Configurações de sistema NixOS (hardware, boot, serviços).
- **`home-manager/`**: Dotfiles e softwares de nível de usuário.
- **`modules/`**: Módulos customizados e reutilizáveis.
- **`overlays/`** & **`pkgs/`**: Pacotes customizados e modificações do Nixpkgs.
- **`WIKI.md`**: Guia completo de referência de comandos e arquitetura.
