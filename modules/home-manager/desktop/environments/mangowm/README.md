# 🥭 Guia & Wiki de Customização do MangoWM & Waybar

Este documento é a referência completa para a customização do **MangoWM** e da **Waybar** integrada no repositório `nixfiles`. Ele explica a arquitetura, como alterar temas e cores, regras de janelas e tags, layouts, atalhos de teclado e gestos do touchpad, além de comandos de IPC via `mmsg` e resolução de problemas comuns.

---

## 📑 Sumário

1. [Visão Geral e Arquitetura](#-1-visão-geral-e-arquitetura)
2. [Estrutura de Arquivos](#-2-estrutura-de-arquivos)
3. [A Barra Waybar Customizada](#-3-a-barra-waybar-customizada)
   - [Módulo de Tags (dwl/tags)](#módulo-de-tags-dwltags)
   - [Módulo de Layout Dinâmico (custom/layout)](#módulo-de-layout-dinâmico-customlayout)
   - [Módulo de Janela Ativa (dwl/window)](#módulo-de-janela-ativa-dwlwindow)
   - [Módulos de Sistema e Utilitários](#módulos-de-sistema-e-utilitários)
4. [Como Fazer Customizações e Alterações](#-4-como-fazer-customizações-e-alterações)
   - [1. Alterar Layouts por Tag ou Monitor](#1-alterar-layouts-por-tag-ou-monitor)
   - [2. Ajustar o Layout Scroller](#2-ajustar-o-layout-scroller)
   - [3. Regras de Janelas (windowrule)](#3-regras-de-janelas-windowrule)
   - [4. Efeitos Visuais (Blur, Sombras, Cantos e Opacidade)](#4-efeitos-visuais-blur-sombras-cantos-e-opacidade)
   - [5. Cores e Paletas de Tema](#5-cores-e-paletas-de-tema)
   - [6. Atalhos de Teclado, Mouse e Gestos](#6-atalhos-de-teclado-mouse-e-gestos)
5. [Tabela de Atalhos Rápidos (Cheat Sheet)](#-5-tabela-de-atalhos-rápidos-cheat-sheet)
6. [Comandos IPC (`mmsg`) & Troubleshooting](#-6-comandos-ipc-mmsg--troubleshooting)

---

## 🌟 1. Visão Geral e Arquitetura

O **MangoWM** é um compositor Wayland de dynamic tiling moderno, ultra-leve e personalizável, baseado no **dwl** e na biblioteca de efeitos **scenefx**. Ele combina a eficiência e robustez do modelo de tags do dwm/dwl com recursos visuais de ponta:

- **Efeitos Scenefx**: Blur de múltiplos passos por hardware, cantos arredondados suavizados (*rounded corners*), sombras difusas com suporte a transparência e opacidade configurável por estado de foco.
- **Layouts Flexíveis**: Além do clássico Master-Stack (`tile`), suporta layout estilo Niri/PaperWM (`scroller`), `grid`, `center_tile`, `deck`, `monocle`, layouts verticais e variantes personalizadas por monitor e tag.
- **Comunicação por IPC (`mmsg`)**: Permite consultar o estado do compositor (`mmsg -g`) e enviar comandos de controle em tempo real (`mmsg -d switch_layout`, `mmsg -d reload_config`, etc.).
- **Integração com Waybar**: Status bar nativa com tags DWL, layout switcher dinâmico, rewritten window titles, hardware monitors e menu de energia.
- **Paleta Catppuccin Mocha**: Rice visual harmonizado com tema escuro rimless, ícones Papirus Dark e fontes JetBrains Mono Nerd Font.

---

## 🗂️ 2. Estrutura de Arquivos

Toda a configuração declarativa do MangoWM no Home Manager está localizada nesta pasta:

```
modules/home-manager/desktop/environments/mangowm/
├── default.nix      # Ativação do ambiente, integração GTK, XDG e importações
├── mango.nix        # Configuração principal gerada em ~/.config/mango/config.conf
├── waybar.nix       # Barra Waybar customizada, scripts de layout e estilo CSS
├── packages.nix     # Pacotes, start-mango wrapper, regras de portal e scripts utilitários
└── README.md        # Esta documentação
```

---

## 📊 3. A Barra Waybar Customizada

A Waybar do MangoWM foi desenhada com módulos dedicados que aproveitam o protocolo DWL do Mango:

### Módulo de Tags (`dwl/tags`)
Diferente do Hyprland que utiliza workspaces numerados estáticos, o MangoWM opera com **Tags (1 a 9)**.
- **Botão Focado / Ativo (`.focused`, `.active`)**: Destacado em azul Catppuccin (`#89b4fa`) com fonte em negrito.
- **Botão Ocupado (`.occupied`)**: Sinalizado em amarelo suave (`#f9e2af`) indicando que existem janelas presentes na tag.
- **Botão Urgente (`.urgent`)**: Realçado em vermelho (`#f38ba8`) para notificações pendentes.
- **Botão Vazio (`.empty`)**: Cor atenuada discreta (`#585b70`).

### Módulo de Layout Dinâmico (`custom/layout`)
Exibe em tempo real o layout ativo no monitor focado via polling no script `mango-layout-switcher`:
- **Ícone e Nome**:
  - `󰹑 Scroller` (S)
  - `󰕰 Tile` (T)
  - `󰕲 Center Tile` (CT)
  - `󰝘 Grid` (G)
  - `󰍹 Monocle` (M)
  - `󰓩 Deck` (K)
  - `󰕳 Right Tile` (RT)
  - `󰹒 Vert Scroller` (VS)
  - `󰕴 Vert Tile` (VT)
  - `󰝙 Vert Grid` (VG)
  - `󰓪 Vert Deck` (VK)
  - `󰕱 TGMix` (TG)
- **Clique Interativo**: Ao clicar com o mouse no layout na Waybar, o script `mango-layout-picker` abre um menu Rofi centralizado permitindo selecionar e aplicar qualquer layout imediatamente.

### Módulo de Janela Ativa (`dwl/window`)
Exibe o título da janela em foco com substituição automática por ícones Nerd Font elegantes:
- Firefox (`󰈹`), Chromium (``), VSCode (`󰨞`), Zed (`󱓷`), Discord (`󰙯`), Steam (`󰓓`), Alacritty (``), Kitty (`󰄛`), Thunar (`󰉋`).

### Módulos de Sistema e Utilitários
- **Hardware**: CPU (``), Temperatura (``), RAM (`󰍛`), Disco (`󰋊`), Rede com medidor de download/upload (`󰤨`/`󰈀`).
- **Controles**: Pulseaudio com scroll para volume e clique para abrir `pavucontrol`, Backlight com scroll de brilho, Bateria com ícones de carga e alertas, Relógio com calendário popover e Menu de Sessão (`session-power-menu`).

---

## 🛠️ 4. Como Fazer Customizações e Alterações

### 1. Alterar Layouts por Tag ou Monitor
Em [mango.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/mangowm/mango.nix):

```nix
# Define o layout padrão de cada tag (1 a 9)
tagrule=id:1,layout_name:scroller
tagrule=id:2,layout_name:tile
tagrule=id:3,layout_name:grid
```

Para aplicar layouts diferentes dependendo do monitor:
```nix
# Exemplo: Monitor eDP-1 usa scroller, monitor externo HDMI-A-1 usa tile
tagrule=id:1,monitor_name:^eDP-1$,layout_name:scroller
tagrule=id:1,monitor_name:^HDMI-A-1$,layout_name:tile
```

### 2. Ajustar o Layout Scroller
O layout `scroller` organiza as janelas em uma fita contínua navegável:
```nix
scroller_structs=450                 # Largura base da coluna (pixels)
scroller_default_proportion=0.5      # Proporção inicial (50% da tela)
scroller_proportion_preset=0.5,0.7,1.0 # Predefinições alternáveis (ALT+Espaço)
```

Atalhos do Scroller:
- `$SUPER + Alt + F`: Força a janela em foco para tela cheia dentro do scroller (`proportion 1.0`).
- `$ALT + Espaço`: Alterna entre os presets de largura (50% → 70% → 100%).
- `$SUPER + C`: Agrupa/empilha a coluna para a esquerda (`scroller_stack left`).
- `$SUPER + Shift + C`: Agrupa/empilha a coluna para a direita (`scroller_stack right`).

### 3. Regras de Janelas (`windowrule`)
Para fazer aplicativos específicos abrirem flutuando, centralizados ou com dimensões fixas:

```nix
# Forçar janela flutuante com tamanho específico
windowrule=isfloating:1,width:850,height:550,title:floating-kitty

# Forçar flutuante por appid (Thunar, Pavucontrol, etc.)
windowrule=isfloating:1,appid:thunar
windowrule=isfloating:1,appid:pavucontrol
windowrule=isfloating:1,appid:nm-connection-editor

# Inibir bloqueio de tela quando um app ou jogo estiver focado
windowrule=idleinhibit_when_focus:1,appid:steam
```

> **Dica**: Para descobrir o `appid` de uma janela Wayland em execução, execute `mmsg -g` ou consulte o terminal ao inicializar o aplicativo.

### 4. Efeitos Visuais (Blur, Sombras, Cantos e Opacidade)
Em [mango.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/mangowm/mango.nix):

```nix
blur=1                          # 1 = Ativa blur, 0 = Desativa
blur_layer=1                    # Aplica blur em waybar e rofi
blur_params_num_passes=2        # Número de passadas do filtro de blur
blur_params_radius=5            # Raio do blur

shadows=1                       # Ativa sombras
shadow_only_floating=1          # Sombras apenas em janelas flutuantes
shadows_size=10
shadows_blur=15

border_radius=10                # Raio de arredondamento dos cantos (pixels)
focused_opacity=1.0             # Opacidade da janela ativa
unfocused_opacity=0.95          # Opacidade das janelas inativas
borderpx=2                      # Espessura da borda
gappih=6                        # Gaps internos horizontais
gappiv=6                        # Gaps internos verticais
gappoh=12                       # Gaps externos horizontais
gappov=12                       # Gaps externos verticais
```

### 5. Cores e Paletas de Tema
As cores no MangoWM utilizam a sintaxe hexadecimal com canal alpha `0xRRGGBBAA`:

```nix
rootcolor=0x1e1e2eff           # Fundo da área de trabalho
bordercolor=0x313244ff         # Borda de janelas inativas
focuscolor=0x89b4faff          # Borda da janela ativa (Azul Catppuccin)
dropcolor=0x89b4fa55           # Indicador de arraste
splitcolor=0xfab387ff          # Divisor de split
maximizescreencolor=0xa6e3a1ff # Indicador de janela maximizada
urgentcolor=0xf38ba8ff         # Indicador de alerta / urgente
scratchpadcolor=0x89b4faff     # Borda do scratchpad
globalcolor=0xcba6f7ff         # Borda de janelas globais/fixas
overlaycolor=0x89dcebff        # Borda de janelas overlay
```

### 6. Atalhos de Teclado, Mouse e Gestos
Os atalhos são definidos através de:
- `bind=MODIFICADOR,TECLA,AÇÃO,ARGUMENTOS`
- `mousebind=MODIFICADOR,BOTÃO,AÇÃO,ARGUMENTOS`
- `axisbind=MODIFICADOR,DIREÇÃO,AÇÃO` (Scroll do mouse)
- `gesturebind=MODIFICADOR,DIREÇÃO,DEDOS,AÇÃO,ARGUMENTOS` (Trackpad)

---

## ⌨️ 5. Tabela de Atalhos Rápidos (Cheat Sheet)

### Sistema e Aplicativos
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Return` | Abre o terminal (`alacritty`) |
| `$SUPER + Ctrl + Return` | Abre o terminal flutuante compacto |
| `$SUPER + Espaço` ou `$SUPER + D` | Abre o launcher de aplicativos (`rofi`) |
| `$SUPER + E` | Abre o gerenciador de arquivos (`thunar`) |
| `$SUPER + V` | Histórico da área de transferência (`cliphist`) |
| `$SUPER + L` | Bloqueia a tela (`hyprlock`) |
| `$SUPER + Escape` / `$SUPER + Shift + E` | Menu de Energia / Logout |
| `$SUPER + Shift + Q` | Encerra a sessão imediatamente (`quit`) |
| `$SUPER + Alt + R` | Recarrega as configurações e Waybar (`mango-reload`) |

### Janelas e Layouts
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Q` ou `$SUPER + C` | Fecha a janela em foco (`killclient`) |
| `$SUPER + W` ou `$SUPER + Shift + Espaço` | Alterna entre janela flutuante e ladrilhada |
| `$ALT + Tab` | Alterna o modo visão geral / overview (`toggleoverview`) |
| `$ALT + F` | Alterna tela cheia real (`togglefullscreen`) |
| `$ALT + Shift + F` | Alterna tela cheia simulada (`togglefakefullscreen`) |
| `$ALT + A` | Alterna estado maximizado (`togglemaximizescreen`) |
| `$SUPER + I` / `$SUPER + Shift + I` | Minimiza janela / Restaura minimizada |
| `$ALT + Z` | Alterna exibição do Scratchpad |
| `Ctrl + Espaço` ou `$SUPER + N` | Alterna para o próximo layout (`switch_layout`) |
| `Ctrl + Shift + Espaço` | Abre o seletor interativo de layout (`mango-layout-picker`) |
| `$SUPER + Alt + F` | Força proporção 100% no Scroller (`set_proportion 1.0`) |
| `$ALT + Espaço` | Alterna presets de largura no Scroller (50% / 70% / 100%) |
| `$SUPER + C` / `$SUPER + Shift + C` | Empilha coluna do Scroller para esquerda / direita |

### Dimensões e Gaps
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + =` / `$SUPER + -` | Aumenta / Diminui a largura da janela |
| `$SUPER + Ctrl + =` / `$SUPER + Ctrl + -` | Aumenta / Diminui a altura da janela |
| `$ALT + Shift + X` / `$ALT + Shift + Z` | Aumenta / Diminui gaps entre janelas |
| `$ALT + Shift + R` | Liga/Desliga gaps (`togglegaps`) |
| `$SUPER + Shift + A` | Alterna modo foco / gaps largos (`mango-toggle-outer-gaps`) |

### Navegação de Foco e Posição
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Setas` ou `$SUPER + H/J/K/L` | Move o foco para janela na direção |
| `$SUPER + Shift + Setas` ou `$SUPER + Shift + H/J/K/L` | Troca a posição da janela na direção |
| `$SUPER + Tab` | Move o foco para a próxima janela na pilha |

### Tags e Workspaces (1 a 9)
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + 1..9` | Visualiza a tag 1 a 9 |
| `$SUPER + Shift + 1..9` | Move a janela atual para a tag 1 a 9 |
| `$SUPER + Ctrl + Cima/Baixo` | Navega para a tag anterior / posterior |
| `$SUPER + Ctrl + Alt + Cima/Baixo` | Move a janela para a tag anterior / posterior |
| `$SUPER + Scroll do Mouse` | Alterna rapidamente entre tags adjacentes |
| `$SUPER + Ctrl + Scroll do Mouse` | Move a janela entre tags adjacentes |

### Gestos no Touchpad
| Gesto | Ação |
| :--- | :--- |
| **Swipe com 3 dedos (Esquerda / Direita / Cima / Baixo)** | Alterna o foco direcional entre as janelas |
| **Swipe com 4 dedos (Esquerda / Direita ou Cima / Baixo)** | Alterna entre as tags / workspaces |

---

## 🔧 6. Comandos IPC (`mmsg`) & Troubleshooting

O MangoWM disponibiliza a ferramenta de linha de comando `mmsg` para interação direta com o compositor.

### Consultar o Estado do Compositor
```bash
# Exibe todos os monitores, tags ativas e layout atual
mmsg get all-monitors

# Exibe a janela/cliente em foco (título, appid, dimensões)
mmsg get focusing-client

# Lista todos os layouts suportados
mmsg get layouts
```

### Alterar Layout via Terminal
```bash
# Alternar layout
mmsg dispatch switch_layout

# Definir layout específico diretamente
mmsg dispatch setlayout,scroller
mmsg dispatch setlayout,tile
mmsg dispatch setlayout,grid
mmsg dispatch setlayout,monocle
```

### Recarregar Configurações a Quente
Após editar qualquer opção no Nix e rodar `home-manager switch`, você pode recarregar a sessão sem reiniciar:
```bash
# Via script integrado (recarrega MangoWM + Waybar)
mango-reload

# Ou diretamente pelo mmsg
mmsg dispatch reload_config
```

### Reiniciar a Waybar Manualmente
Caso queira testar mudanças de CSS ou JSON da Waybar:
```bash
killall waybar && waybar &
```

---

> 💡 **Para aplicar alterações no Home Manager**:
> ```bash
> home-manager switch --flake .#juca@anubis
> ```
