# 🧠 Memória e Diretrizes do Projeto (Antigravity / AI Pair Programming)

Este arquivo serve como **memória persistente** e guia de diretrizes para o assistente de IA neste repositório. Ele é carregado automaticamente a cada interação para manter o contexto, padrões arquiteturais e decisões tomadas.

---

## 📌 Contexto Geral do Repositório

- **Tipo**: Configuração declarativa usando **Nix Flakes** para **NixOS** e **Home Manager** (standalone e integrado).
- **Usuário Padrão**: `juca`
- **Hosts Comuns**: `fedora` (Home Manager standalone), `virtualvm` (NixOS), etc.
- **Documentação Base**: Ver [README.md](file:///mnt/d/workspace/MyRepos/nixfiles/README.md) e [WIKI.md](file:///mnt/d/workspace/MyRepos/nixfiles/WIKI.md).

---

## 📐 Padrões de Código e Convenções Nix

1. **Evitar Unused Bindings (Variáveis e Parâmetros Não Utilizados)**:
   - Em assinaturas de módulos (`{ lib, pkgs, ... }:`), declare **apenas** os argumentos que serão lidos no corpo do módulo.
   - O `...` (ellipsis) ao final da lista de argumentos absorve automaticamente argumentos extras injetados pelo NixOS/Home Manager (como `config`, `options`, `specialArgs`). Não declare `config` a menos que seu valor seja lido.
   - Em blocos `let ... in`, utilize `inherit` apenas para atributos efetivamente usados.
2. **Estrutura Modular**:
   - `home-manager/`: Dotfiles e ferramentas do usuário. O arquivo de entrada é [home-manager/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/home-manager/default.nix).
   - `nixos/`: Configurações de sistema e serviços em nível de SO.
   - `modules/`: Módulos customizados reaproveitáveis.
   - `lib/`: Funções utilitárias (`mkNixos`, `mkHome`).
   - `overlays/` e `pkgs/`: Pacotes próprios e extensões do nixpkgs.
3. **Boas Práticas de Modificação**:
   - Sempre manter comentários informativos e documentação existente.
   - Fazer alterações cirúrgicas e verificar a sintaxe com `nix flake check` quando apropriado.

---

## ⚡ Comandos Rápidos de Validação e Aplicação

- **Verificação de Sintaxe / Flake**:
  ```bash
  nix flake check
  ```
- **Home Manager Standalone**:
  ```bash
  home-manager switch --flake .#juca@<host>
  ```
- **NixOS Rebuild**:
  ```bash
  sudo nixos-rebuild switch --flake .#<host>
  ```

---

## 📝 Histórico de Ajustes e Decisões

- **`home-manager/default.nix`**: Removido parâmetro `config` não referenciado na assinatura de argumentos e removidos `isLinux` / `mkIf` não utilizados no bloco `let`.

---

> 💡 **Dica**: Você pode adicionar novas preferências ou regras a qualquer momento neste arquivo ou utilizando o comando `/learn`.
