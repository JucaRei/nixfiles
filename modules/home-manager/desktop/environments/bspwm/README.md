# 🌲 Guia & Wiki de Customização do BSPWM

Este documento é a referência completa para a customização do **BSPWM** (Binary Space Partitioning Window Manager) e seu ecossistema (SXHKD, Polybar, Picom, Rofi, Dunst, libinput-gestures) no repositório `nixfiles`.

---

## 📑 Sumário

1. [Visão Geral e Arquitetura](#-1-visão-geral-e-arquitetura)
2. [Estrutura de Arquivos](#-2-estrutura-de-arquivos)
3. [Componentes Visuais do Ambiente](#-3-componentes-visuais-do-ambiente)
   - [BSPWM Window Manager (bspwm.nix)](#bspwm-window-manager-bspwmnix)
   - [Barra Polybar (polybar/)](#barra-polybar-polybar)
   - [Compositor Picom (picom.nix)](#compositor-picom-picomnix)
   - [Atalhos SXHKD (sxhkd.nix)](#atalhos-sxhkd-sxhkdnix)
   - [Gestos no Touchpad (libinput-gestures)](#gestos-no-touchpad-libinput-gestures)
4. [Como Fazer Customizações e Alterações](#-4-como-fazer-customizações-e-alterações)
   - [1. Configurar Desktops / Workspaces](#1-configurar-desktops--workspaces)
   - [2. Regras de Janelas e Diálogos Flutuantes Dinâmicos](#2-regras-de-janelas-e-diálogos-flutuantes-dinâmicos)
   - [3. Customizar a Polybar](#3-customizar-a-polybar)
   - [4. Efeitos Visuais no Picom (Blur, Cantos e Sombras)](#4-efeitos-visuais-no-picom-blur-cantos-e-sombras)
   - [5. Suporte a GPU Legada (NVIDIA 340 Legacy & OpenGL)](#5-suporte-a-gpu-legada-nvidia-340-legacy--opengl)
5. [Tabela de Atalhos Rápidos (Cheat Sheet)](#-5-tabela-de-atalhos-rápidos-cheat-sheet)
6. [Troubleshooting & Dicas](#-6-troubleshooting--dicas)

---

## 🌟 1. Visão Geral e Arquitetura

O **BSPWM** é um gerenciador de janelas X11 baseado no particionamento binário de espaços: as janelas são folhas de uma árvore binária completa. Ele não trata atalhos de teclado por si mesmo, delegando essa função ao daemon dedicado **sxhkd**.

No ecossistema `nixfiles`:
- **Estética gh0stzk / Catppuccin Mocha**: Rice visual polido inspirado na suíte [gh0stzk/dotfiles](https://github.com/gh0stzk/dotfiles), trazendo pílulas coloridas, ícones Nerd Font vibrantes e paleta escura harmoniosa.
- **Polybar Modular**: Barra com cantos arredondados, workspaces interativos (`󰮯`, `󰊠`, `󰀦`, etc.), módulo de rede dinâmica (detecta automaticamente cabo `󰈀` ou Wi-Fi `󰤨` com tráfego acumulado), menus interativos Rofi (Wi-Fi, Bluetooth e Power Menu) e relógio.
- **Janelas Flutuantes Inteligentes**: Script dinâmico de regras externas (`bspwm-external-rules`) que detecta diálogos GTK, seletores de arquivos (Open/Save/VSCode) e modais via `xprop`, forçando estado flutuante centralizado em 850x550 para evitar que janelas de diálogo ocupem a tela inteira.
- **Gestos do Touchpad Integrados**: Swipe com 3 dedos para alternar desktops e 4 dedos para trocar abas no navegador/editor em foco (`browser-tab-switch`).

---

## 🗂️ 2. Estrutura de Arquivos

Toda a configuração declarativa do BSPWM está localizada nesta pasta:

```
modules/home-manager/desktop/environments/bspwm/
├── default.nix       # Ativação do módulo, integração com o display server e importações
├── bspwm.nix         # Configuração central do bspwmrc e external rules
├── sxhkd.nix         # Daemon de atalhos, scripts OSD de volume/brilho e quick-settings
├── picom.nix         # Compositor X11 com blur, cantos arredondados e sombras
├── rofi.nix          # Menus interativos (launcher drun, wifi, bluetooth, clipboard)
├── dunst.nix         # Notificações e barras de progresso OSD
├── packages.nix      # Pacotes X11, utilitários de tela e ferramentas CLI
├── polybar/          # Módulos modulares e temas da Polybar
└── README.md         # Esta documentação
```

---

## 🎨 3. Componentes Visuais do Ambiente

### BSPWM Window Manager (`bspwm.nix`)
- **Gaps e Bordas**: Borda de 2px, gaps internos de 6px e gaps externos de 10px.
- **Cores Catppuccin Mocha**:
  - Janela ativa: `#89b4fa` (Azul)
  - Janela normal: `#313244` (Base escura)
  - Feedback de inserção de split: `#fab387` (Pêssego)
- **Regras Externas (`bspwm-external-rules`)**: Script automatizado executado a cada nova janela mapeada. Se for modal de diálogo, janela de preferências ou seletor de arquivos, força `state=floating center=on rectangle=850x550+0+0 follow=on`.

### Barra Polybar (`polybar/`)
- **Workspaces Dinâmicos**: Pílulas coloridas para workspaces 1 a 6 (`󰮯`, `󰊠`, `󰀦`, `󰈹`, `󰓇`, `󰭹`).
- **Módulo de Rede Inteligente**: Identifica a interface ativa sem necessidade de hardcode. Mostra nome do Wi-Fi ou conexão cabeada, com medidor de velocidade agregado (`accumulate-stats = true`).
- **Menus Rápidos Rofi**: Clique no ícone de Wi-Fi abre o seletor de redes sem fio; clique no Bluetooth abre dispositivos pareados; clique no relógio abre calendário; clique no botão power abre menu de logout.

### Compositor Picom (`picom.nix`)
- **Cantos Arredondados**: Raio de 10px em janelas tiled e floating.
- **Blur Dual-Kawase**: Blur translúcido acelerado por GPU com exclusão automática de janelas que não devem borrar (Polybar, Dunst).
- **Sombras Difusas**: Raio de 14px com opacidade ajustada e offset centralizado.

### Gestos no Touchpad (`libinput-gestures`)
- **3 Dedos (Esquerda/Direita)**: Alterna entre workspaces/desktops vizinhos.
- **4 Dedos (Esquerda/Direita)**: Alterna abas no navegador em foco (`Ctrl+PageDown` / `Ctrl+PageUp`) através do script inteligente `browser-tab-switch`.

---

## 🛠️ 4. Como Fazer Customizações e Alterações

### 1. Configurar Desktops / Workspaces
Em [bspwm.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/bspwm/bspwm.nix):

```nix
bspc monitor -d 1 2 3 4 5 6
```
Caso possua múltiplos monitores, você pode especificar os desktops para cada saída:
```nix
bspc monitor DP-1 -d 1 2 3 4
bspc monitor HDMI-1 -d 5 6 7 8
```

### 2. Regras de Janelas e Diálogos Flutuantes Dinâmicos
Regras estáticas são declaradas no `bspwm.nix`:
```nix
bspc rule -a Thunar state=floating center=on rectangle=900x600+0+0
bspc rule -a Pavucontrol state=floating center=on
bspc rule -a Blueman-manager state=floating center=on
bspc rule -a mpv state=floating center=on
```
Para diálogos dinâmicos (como janelas de "Abrir pasta" ou "Salvar como"), o script `bspwm-external-rules` trata padrões bilíngues via regex:
```bash
if [[ "$title" =~ (Abrir|Open|Salvar|Save|Choose|Select|Escolher) ]]; then
  echo "state=floating center=on rectangle=850x550+0+0 follow=on"
fi
```

### 3. Customizar a Polybar
Os módulos e layout da barra estão organizados dentro do subdiretório [polybar/](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/bspwm/polybar/):
- `modules.nix`: Definição de cada bloco visual (cpu, memória, pulseaudio, network, workspaces, clock, powermenu).
- `config.ini`: Posição da barra, margens, fontes, altura e espaçamento entre módulos.

### 4. Efeitos Visuais no Picom (Blur, Cantos e Sombras)
Em [picom.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/bspwm/picom.nix):

```nix
corner-radius = 10;
shadow = true;
shadow-radius = 14;
shadow-opacity = 0.6;

blur = {
  method = "dual_kawase";
  strength = 6;
};
```

### 5. Suporte a GPU Legada (NVIDIA 340 Legacy & OpenGL)
Em sistemas com placas de vídeo antigas sem suporte ao `libglvnd` moderno (ex: GeForce 8600M GT no host `rocinante`), binários Nix modernos precisam que as bibliotecas GL nativas do driver proprietário tenham prioridade. O wrapper e o `bspwmrc` exportam automaticamente:
```bash
export LD_LIBRARY_PATH="/run/opengl-driver/lib:/run/opengl-driver-32/lib:$LD_LIBRARY_PATH"
```
Isso garante aceleração 3D por hardware completa no Alacritty, Picom e reprodutores multimídia sem erros de GL visual.

---

## ⌨️ 5. Tabela de Atalhos Rápidos (Cheat Sheet)

### Sistema e Aplicativos
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Return` | Abre o terminal (`alacritty`) |
| `$SUPER + Espaço` ou `$SUPER + D` | Launcher de aplicativos (`rofi`) |
| `$SUPER + E` | Gerenciador de arquivos (`thunar`) |
| `$SUPER + V` | Histórico da área de transferência (`cliphist`) |
| `$SUPER + N` | Menu Rofi de redes Wi-Fi |
| `$SUPER + B` | Menu Rofi de dispositivos Bluetooth |
| `$SUPER + S` | Painel Quick Settings / Manual de Atalhos |
| `$SUPER + Escape` / `$SUPER + Shift + E` | Menu de Energia / Logout |
| `$SUPER + Alt + R` | Recarrega BSPWM e SXHKD (`bspc wm -r`) |

### Janelas e Layouts
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Q` ou `$SUPER + C` | Fecha a janela em foco (`bspc node -c`) |
| `$SUPER + W` | Alterna modo flutuante / tiled |
| `$SUPER + F` | Alterna modo tela cheia (`fullscreen`) |
| `$SUPER + Shift + F` | Alterna modo pseudo-tiled |
| `$SUPER + Tab` | Alterna foco com a última janela usada |

### Foco e Troca de Posição (Setas e Vim Keys)
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Setas` ou `$SUPER + H/J/K/L` | Foca a janela na direção correspondente |
| `$SUPER + Shift + Setas` ou `$SUPER + Shift + H/J/K/L` | Troca a janela de posição na direção |
| `$SUPER + Ctrl + Setas` | Pré-seleciona a direção de split para a próxima janela |
| `$SUPER + Ctrl + Espaço` | Cancela a pré-seleção de split |

### Redimensionamento de Janelas
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Alt + H / L` | Expande / Contrai janela horizontalmente |
| `$SUPER + Alt + J / K` | Expande / Contrai janela verticalmente |
| `$SUPER + Botão Direito do Mouse` | Redimensiona livremente com o cursor |
| `$SUPER + Botão Esquerdo do Mouse` | Move a janela livremente com o cursor |

### Workspaces / Desktops (1 a 6)
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + 1..6` | Troca para o desktop correspondente |
| `$SUPER + Shift + 1..6` | Envia a janela ativa para o desktop correspondente |
| `$SUPER + Scroll do Mouse` | Alterna sequencialmente entre desktops |
| **Swipe com 3 dedos (Touchpad)** | Alterna para o desktop anterior / próximo |
| **Swipe com 4 dedos (Touchpad)** | Alterna abas no navegador/editor em foco |

### Multimídia e Hardware
| Atalho | Ação |
| :--- | :--- |
| `Print` / `$SUPER + Shift + S` | Captura de tela cheia / Recorte de área |
| `XF86AudioRaiseVolume` / `Lower` | Aumenta / Diminui volume com feedback OSD |
| `XF86AudioMute` | Silencia áudio |
| `XF86MonBrightnessUp` / `Down` | Aumenta / Diminui brilho da tela com feedback OSD |
| `XF86KbdBrightnessUp` / `Down` | Aumenta / Diminui luz do teclado Apple |
| `$SUPER + F6` / `$SUPER + F5` | Atalho direto: Aumenta / Diminui luz do teclado |

---

## 🔧 6. Troubleshooting & Dicas

- **Recarregar SXHKD Manualmente**:
  ```bash
  pkill -USR1 -x sxhkd
  ```
- **Reiniciar BSPWM sem fechar janelas**:
  ```bash
  bspc wm -r
  ```
- **Reiniciar Polybar**:
  ```bash
  polybar-msg cmd restart
  ```
- **Identificar classe de janela para regras**:
  Execute `xprop WM_CLASS` no terminal e clique na janela desejada.

---

> 💡 **Para aplicar alterações no Home Manager**:
> ```bash
> home-manager switch --flake .#juca@<host>
> ```
