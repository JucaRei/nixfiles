# 🐭 Guia & Wiki de Customização do XFCE4

Este documento é a referência para a customização do **XFCE4** e seus componentes declarativos via Home Manager no repositório `nixfiles`.

---

## 📑 Sumário

1. [Visão Geral e Arquitetura](#-1-visão-geral-e-arquitetura)
2. [Estrutura de Arquivos](#-2-estrutura-de-arquivos)
3. [Configurações Declarativas (Xfconf)](#-3-configurações-declarativas-xfconf)
   - [Gerenciador de Janelas (XFWM4)](#gerenciador-de-janelas-xfwm4)
   - [Aparência Global (Xsettings)](#aparência-global-xsettings)
   - [Painel do XFCE (xfce4-panel)](#painel-do-xfce-xfce4-panel)
   - [Atalhos de Teclado](#atalhos-de-teclado)
4. [Como Fazer Customizações e Alterações](#-4-como-fazer-customizações-e-alterações)
5. [Tabela de Atalhos Rápidos](#-5-tabela-de-atalhos-rápidos)

---

## 🌟 1. Visão Geral e Arquitetura

O **XFCE4** é um ambiente de desktop tradicional, estável e extremamente leve para X11. Ele é ideal para máquinas virtuais, computadores de teste ou hardware legado onde compositores modernos de tiling não são necessários.

No ecossistema `nixfiles`:
- **Tema Catppuccin Mocha Unificado**: Tema GTK escuro `catppuccin-mocha-blue-standard+rimless`, ícones Papirus Dark e cursores Catppuccin Mocha.
- **Configuração 100% Declarativa**: Toda a configuração de temas, painel, atalhos de teclado e compositor do XFWM4 é gerada deterministicamente via canal `xfconf` do Home Manager.
- **Compatibilidade**: Opera perfeitamente com Alacritty, Rofi, Thunar e ferramentas de áudio e brilho modernas.

---

## 🗂️ 2. Estrutura de Arquivos

```
modules/home-manager/desktop/environments/xfce4/
├── default.nix      # Configurações declarativas do Xfconf, GTK, painéis e atalhos
└── README.md        # Esta documentação
```

---

## ⚙️ 3. Configurações Declarativas (Xfconf)

### Gerenciador de Janelas (XFWM4)
Em [default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/xfce4/default.nix):
- `theme`: Herda o tema Catppuccin Mocha.
- `title_font`: `Inter Bold 10`.
- `button_layout`: `O|HMC` (Botão de opções à esquerda; Minimizar, Maximizar e Fechar à direita).
- `use_compositing`: Ativado por padrão com sombras sutis em popups e docks.
- `workspace_count`: 4 áreas de trabalho virtuais.

### Aparência Global (Xsettings)
- Fontes: `Inter 10` para interface e `SFMono Nerd Font 10` / `JetBrains Mono` para terminais e texto monoespaçado.
- Anti-aliasing e hinting ativados com renderização subpixel RGB.

### Painel do XFCE (`xfce4-panel`)
- **Painel Superior Compacto**: 32px de altura, escuro e discreto.
- **Plugins Nativos**:
  1. Menu de aplicativos (Applications Menu)
  2. Botões de janelas / Lista de tarefas com ícones
  3. Separador expansível
  4. Bandeja do sistema (Systray / Notification Area)
  5. Plugin de áudio / controle de volume
  6. Indicador de bateria (quando laptop)
  7. Relógio digital com data e calendário popover
  8. Botão de encerramento de sessão

### Atalhos de Teclado
Mapeamento direto dos mesmos atalhos dos tiling managers:
- `$SUPER + Return`: Terminal (`alacritty` ou `xfce4-terminal`)
- `$SUPER + Espaço` / `$SUPER + D`: Launcher de aplicativos (`rofi`)
- `$SUPER + E`: Gerenciador de arquivos (`thunar`)
- `$SUPER + V`: Histórico de clipboard (`cliphist`)
- Teclas multimídia para volume (`pamixer`), brilho (`brightnessctl`) e controle de mídia (`playerctl`).

---

## 🛠️ 4. Como Fazer Customizações e Alterações

Para alterar qualquer propriedade do XFCE de forma declarativa, edite o bloco `xfconf.settings` em [default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/xfce4/default.nix):

```nix
# Exemplo: Aumentar a quantidade de áreas de trabalho para 6
xfconf.settings.xfwm4."general/workspace_count" = 6;

# Exemplo: Desativar a composição de janelas embutida
xfconf.settings.xfwm4."general/use_compositing" = false;
```

---

## ⌨️ 5. Tabela de Atalhos Rápidos

| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Return` | Abre o terminal |
| `$SUPER + Espaço` ou `$SUPER + D` | Launcher de aplicativos (`rofi`) |
| `$SUPER + E` | Gerenciador de arquivos (`thunar`) |
| `$SUPER + V` | Histórico da área de transferência (`cliphist`) |
| `Alt + F4` | Fecha a janela em foco |
| `Alt + Tab` | Alterna entre janelas abertas |
| `Ctrl + Alt + Setas` | Alterna entre as 4 áreas de trabalho |
| `XF86AudioRaiseVolume` / `Lower` | Aumenta / Diminui volume do sistema |
| `XF86MonBrightnessUp` / `Down` | Aumenta / Diminui brilho da tela |

---

> 💡 **Para aplicar alterações no Home Manager**:
> ```bash
> home-manager switch --flake .#juca@<host>
> ```
