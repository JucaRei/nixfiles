# Guia Prático: Como Mexer no Nixfiles

Tudo o que você precisa configurar pode ser feito editando apenas o arquivo `settings.nix` da sua máquina e rodando um comando.

> 🔒 **Segurança**: Todas as verificações de sistema limitam o consumo a no máximo 50% de CPU, 50% de RAM e 20% de Swap, garantindo que seu computador nunca trave por falta de memória durante as checagens.

---

## 🛠️ As 9 Tarefas do Dia a Dia

Em todas as tarefas abaixo, edite o arquivo `settings.nix` da sua máquina (ex: `home-manager/hosts/nitro/settings.nix`).

| # | Tarefa | O que alterar no `settings.nix` | Comando para rodar |
|---|---|---|---|
| 1 | **Trocar tema** | Mude `theme.name = "catppuccin-mocha";` para `theme.name = "tokyo-night";` (veja opções com `./scripts/nx themes`) | `./scripts/nx apply` |
| 2 | **Trocar destaque** | Mude `theme.accent = "blue";` para `theme.accent = "purple";` (opções: red, orange, yellow, green, teal, cyan, blue, purple, pink) | `./scripts/nx apply` |
| 3 | **Instalar programa** | Adicione o nome em `my.apps.cli = [ "htop" ];` ou `my.apps.gui = [ "firefox" ];` | `./scripts/nx apply` |
| 4 | **Remover programa** | Apague a linha do programa de `my.apps.cli` ou `my.apps.gui` | `./scripts/nx apply` |
| 5 | **Mudar wallpaper** | Mude `wallpaper.directory = "/caminho/para/pasta/com/fotos";` | `./scripts/nx apply` |
| 6 | **Mudar monitor** | Altere a resolução e taxa em `desktop.monitors`: `{ name = "eDP-1"; width = 1920; height = 1080; refresh = 60; primary = true; }` | `./scripts/nx apply` |
| 7 | **Criar máquina** | Rode o comando e responda às 3 perguntas simples | `./scripts/nx new-host meu-pc` |
| 8 | **Aplicar mudanças** | Salve o arquivo e execute a sincronização | `./scripts/nx apply` |
| 9 | **Desfazer (rollback)** | Caso algo dê errado, reverta imediatamente para a versão anterior | `./scripts/nx rollback` |

---

## ❓ Erros Comuns e Como Resolver

| Mensagem / Problema | Causa provável | O que fazer |
|---|---|---|
| **Hostname desconhecido** | O nome do computador em `/etc/hostname` não está listado em `hosts.nix`. | Adicione a máquina em `hosts.nix` ou crie com `./scripts/nx new-host <nome>`. |
| **Pacote não encontrado** | O nome do programa foi digitado incorretamente em `my.apps.*`. | Procure pelo nome oficial com `./scripts/nx search <nome>` ou no site search.nixos.org. |
| **Falta de memória no check** | O teste do repositório foi interrompido por atingir o limite de segurança. | Feche outros programas pesados ou valide apenas arquivos modificados com `statix check .`. |
| **Conflito de arquivos (collision)** | Um arquivo já existia em `$HOME` antes do Home Manager ser instalado. | Faça backup do arquivo existente ou aplique passando `-b backup` para renomeá-lo. |

---

## 📖 Glossário em Português Claro

1. **Flake**: Arquivo mestre que tranca as versões exatas de todos os programas para garantir que funcionem sempre igual em qualquer máquina.
2. **Módulo**: Bloco reutilizável de configurações dedicado a um tema, ambiente de trabalho ou programa específico.
3. **Host**: O nome único atribuído ao computador ou máquina virtual configurada.
4. **Perfil**: Conjunto de configurações padrão compartilhado entre vários computadores (ex: workstation para desktop, minimal para servidores).
5. **Switch**: Comando que compila todas as receitas e ativa a nova versão do sistema imediatamente.
6. **Geração**: Fotografia salva de uma versão do sistema. Toda vez que você aplica uma alteração, uma nova geração é guardada, facilitando desfazer mudanças.
7. **Overlay**: Modificação personalizada sobre um pacote oficial para trocar versões, aplicar correções ou adicionar patches.
8. **Standalone**: Uso do Home Manager isolado em distribuições Linux comuns (como Fedora, Debian, Ubuntu) sem precisar do NixOS.
9. **Derivação**: Receita do Nix que descreve exatamente de onde baixar o código-fonte e como compilar um pacote sem tocar no restante do sistema.
10. **nixGL**: Camada especial que permite programas gráficos do Nix usarem a aceleração 3D da sua placa de vídeo em distribuições não-NixOS.
