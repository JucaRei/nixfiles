# 🌌 Guia & Wiki de Customização do Hyprland

Este documento é a referência completa para a customização do **Hyprland** e seus componentes visuais (Waybar, Rofi, Dunst, Hyprlock, Hypridle, Hyprpaper) no repositório `nixfiles`.

---

## 📑 Sumário

1. [Visão Geral e Arquitetura](#-1-visão-geral-e-arquitetura)
2. [Estrutura de Arquivos](#-2-estrutura-de-arquivos)
3. [Componentes Visuais do Ambiente](#-3-componentes-visuais-do-ambiente)
   - [Hyprland Compositor (hyprland.nix)](#hyprland-compositor-hyprlandnix)
   - [Waybar (waybar.nix)](#waybar-waybarnix)
   - [Bloqueio e Energia (hyprlock.nix & hypridle.nix)](#bloqueio-e-energia-hyprlocknix--hypridlenix)
   - [Launcher & Clipboard (rofi.nix)](#launcher--clipboard-rofinix)
4. [Como Fazer Customizações e Alterações](#-4-como-fazer-customizações-e-alterações)
   - [1. Configurar Monitores](#1-configurar-monitores)
   - [2. Configurar Teclado e Dead Keys (MacBook / US-Intl)](#2-configurar-teclado-e-dead-keys-macbook--us-intl)
   - [3. Regras de Janelas (windowrule / windowrulev2)](#3-regras-de-janelas-windowrule--windowrulev2)
   - [4. Animações e Curvas Bezier](#4-animações-e-curvas-bezier)
   - [5. Estabilização e Aceleração Gráfica (Intel HD 3000 / Sandy Bridge)](#5-estabilização-e-aceleração-gráfica-intel-hd-3000--sandy-bridge)
   - [6. Autenticação PAM do Hyprlock em Distros Standalone (Fedora)](#6-autenticação-pam-do-hyprlock-em-distros-standalone-fedora)
5. [Tabela de Atalhos Rápidos (Cheat Sheet)](#-5-tabela-de-atalhos-rápidos-cheat-sheet)
6. [Troubleshooting & Dicas](#-6-troubleshooting--dicas)

---

## 🌟 1. Visão Geral e Arquitetura

O **Hyprland** é um compositor Wayland de tiling dinâmico baseado em wlroots com fluidez visual inigualável, aceleração gráfica moderna e animações dinâmicas personalizáveis.

No ecossistema `nixfiles`:
- **Tema Visual**: Catppuccin Mocha com cantos arredondados de 10px, bordas ativas em gradiente azul (`#89b4fa`), sombras difusas translúcidas e efeito blur dual-pass (8 passes/radius).
- **Barra Waybar**: Estilo *floating pills* isoladas, com workspaces interativos em formato de pills numéricas com ícones Nerd Font (`󰮯`, `󰊠`, `󰀦`, etc.), relógio com popover de calendário, pulseaudio com scroll, rede dinâmica wifi/cabo com medidor de velocidade e menu de energia.
- **Ecossistema Completo**: Rofi Wayland com suporte a histórico de clipboard (`cliphist`), Dunst OSD para volume e brilho (tela e teclado Apple), Hyprlock com relógio moderno e avatar, e Hypridle para gestão de energia.

---

## 🗂️ 2. Estrutura de Arquivos

Toda a configuração declarativa do Hyprland está localizada nesta pasta:

```
modules/home-manager/desktop/environments/hyprland/
├── default.nix      # Ativação central, integração e importações
├── hyprland.nix     # Configuração principal do compositor (hyprland.conf)
├── waybar.nix       # Barra Waybar superior flutuante e scripts de energia
├── rofi.nix         # Launcher drun e histórico de área de transferência
├── dunst.nix        # Notificações e popups OSD
├── hyprlock.nix     # Tela de bloqueio moderna com blur e tipografia
├── hypridle.nix     # Gerenciamento de ociosidade e suspensão
├── hyprpaper.nix    # Gerenciador de papel de parede leve
├── packages.nix     # Pacotes essenciais Wayland (grim, slurp, wl-clipboard, etc.)
└── README.md        # Esta documentação
```

---

## 🎨 3. Componentes Visuais do Ambiente

### Hyprland Compositor (`hyprland.nix`)
- **Animações**: Curvas Bezier customizadas (`fastBezier` e `overshot`) para abertura de janelas fluida, transição suave de foco e troca de workspaces.
- **Gestos Touchpad**: Suporte nativo a gestos com 3 dedos para alternar workspaces (`gesture = [ "3, horizontal, workspace" ]`).
- **Compatibilidade Hyprland 0.55+**: Sintaxe estrita declarada via `configType = "hyprlang"` para prevenir falhas de parser com o gerador experimental em Lua.

### Waybar (`waybar.nix`)
- **Estilo Floating Pills**: Módulos encapsulados em cápsulas independentes com fundo translúcido `rgba(30, 30, 46, 0.85)` e bordas finas `rgba(137, 180, 250, 0.2)`.
- **Workspaces Dinâmicos**: Ícones exclusivos por workspace:
  - 1: `󰮯` | 2: `󰊠` | 3: `󰀦` | 4: `󰈹` | 5: `󰓇` | 6: `󰭹` | 7: `󰚀` | 8: `󱔗` | 9: `󰒱` | 10: `󰐥`
- **Rede Dinâmica**: Detecta automaticamente interface Wi-Fi com medidor de sinal ou cabo Ethernet, exibindo taxa de download e upload em tempo real.

### Bloqueio e Energia (`hyprlock.nix` & `hypridle.nix`)
- Fundo com blur da tela atual ou wallpaper padrão Catppuccin Mocha.
- Relógio moderno centralizado em tipografia grande, campo de senha com indicador de Caps Lock e avatar do usuário.
- Inatividade configurada: desliga iluminação do teclado após 2.5 min, tela após 5 min e bloqueia após 10 min.

---

## 🛠️ 4. Como Fazer Customizações e Alterações

### 1. Configurar Monitores
Em [hyprland.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/hyprland/hyprland.nix) ou nas configurações da máquina:

```nix
desktop.hyprland.monitors = [
  "eDP-1, 1440x900@60, 0x0, 1"
  "HDMI-A-1, 1920x1080@60, 1440x0, 1"
  ", preferred, auto, 1" # Fallback automático para monitores plugados
];
```

> **Dica**: Use o comando `hyprctl monitors` no terminal para inspecionar os nomes, resoluções e taxas de atualização dos monitores conectados.

### 2. Configurar Teclado e Dead Keys (MacBook / US-Intl)
Para garantir que dead keys (`'c` → `ç`, `~a` → `ã`, `'e` → `é`) funcionem perfeitamente, configure no [home-manager/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/home-manager/default.nix):

```nix
home.keyboard = {
  layout = "us";
  variant = "intl";
  model = "apple"; # Habilita mapeamento físico do teclado Apple/Mac
};
```
O `hyprland.nix` herda essas configurações automaticamente sem necessidade de duplicar.

### 3. Regras de Janelas (`windowrule` / `windowrulev2`)
Para forçar aplicativos a abrirem flutuantes ou centralizados:

```nix
windowrule = [
  "match:title (Open Folder|Abrir pasta|Open File|Salvar como), float 1, center 1, size 850 550"
  "match:class (thunar|org.gnome.Nautilus), float 1, center 1, size 900 600"
  "match:class (pavucontrol|nm-connection-editor|blueman-manager), float 1, center 1"
  "match:class (floating-kitty), float 1, center 1, size 850 500"
];
```

### 4. Animações e Curvas Bezier
Em [hyprland.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/hyprland/hyprland.nix):

```nix
bezier = [
  "fastBezier, 0.05, 0.9, 0.1, 1.05"
  "overshot, 0.13, 0.99, 0.29, 1.1"
  "smoothOut, 0.36, 0, 0.66, -0.56"
];

animation = [
  "windows, 1, 4, fastBezier, slide"
  "windowsOut, 1, 4, fastBezier, slide"
  "workspaces, 1, 4, fastBezier, slide"
];
```

### 5. Estabilização e Aceleração Gráfica (Intel HD 3000 / Sandy Bridge)
Para notebooks antigos com GPU Intel HD 3000 (como MacBook Air 4,1/4,2), o módulo aplica ajustes essenciais de estabilização:
```nix
# Desativa VFR para evitar flickering de tensão no painel eDP
debug.vfr = false;

# Cursor por software previne micro-flickering de DRM scanout
cursor.no_hardware_cursors = true;
render.direct_scanout = 0;

# Driver VA-API correto: sandy bridge usa i965 (não o moderno iHD)
LIBVA_DRIVER_NAME = "i965";
```

### 6. Autenticação PAM do Hyprlock em Distros Standalone (Fedora)
Em distros não-NixOS com Home Manager standalone, `/etc/pam.d/hyprlock` precisa existir no host para que a verificação de senha não seja rejeitada. Execute uma vez no terminal do host:

```bash
sudo tee /etc/pam.d/hyprlock << 'EOF'
#%PAM-1.0
auth        include       system-auth
account     include       system-auth
password    include       system-auth
session     include       system-auth
EOF
```

---

## ⌨️ 5. Tabela de Atalhos Rápidos (Cheat Sheet)

### Sistema e Aplicativos
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Return` | Abre o terminal (`alacritty`) |
| `$SUPER + Ctrl + Return` | Abre o terminal flutuante |
| `$SUPER + Espaço` ou `$SUPER + D` | Launcher de aplicativos (`rofi`) |
| `$SUPER + E` | Gerenciador de arquivos (`thunar`) |
| `$SUPER + V` | Histórico da área de transferência (`cliphist`) |
| `$SUPER + L` | Bloqueia a tela (`hyprlock`) |
| `$SUPER + Escape` / `$SUPER + Shift + E` | Menu de Energia / Logout |
| `$SUPER + Shift + Q` | Encerra a sessão Hyprland imediatamente |
| `$SUPER + Shift + R` | Reinicia Waybar e Dunst |

### Janelas e Layouts
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Q` ou `$SUPER + C` | Fecha a janela em foco (`killactive`) |
| `$SUPER + F` ou `$SUPER + S` | Alterna modo flutuante (`togglefloating`) |
| `Alt + A` | Alterna tela cheia (`fullscreen, 0`) |
| `$SUPER + P` | Alterna modo pseudo-tiling (`pseudo`) |
| `$SUPER + J` | Alterna split horizontal / vertical (`layoutmsg, togglesplit`) |
| `$SUPER + Tab` | Alterna o foco para a próxima janela |

### Foco e Movimentação (Setas e Vim Keys)
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + Setas` ou `$SUPER + H/J/K/L` | Move o foco para a janela adjacente |
| `$SUPER + Shift + Setas` ou `$SUPER + Shift + H/J/K/L` | Move a janela para a posição adjacente |

### Workspaces (1 a 10)
| Atalho | Ação |
| :--- | :--- |
| `$SUPER + 1..9, 0` | Troca para o workspace 1 a 10 |
| `$SUPER + Shift + 1..9, 0` | Move a janela ativa para o workspace 1 a 10 |
| `$SUPER + Scroll do Mouse` | Alterna sequencialmente entre workspaces |
| **Swipe com 3 dedos (Touchpad)** | Desliza para o workspace adjacente |

### Multimídia e Hardware
| Atalho | Ação |
| :--- | :--- |
| `Print` / `$SUPER + Shift + S` | Captura de tela cheia / Recorte de área (`grim + slurp`) |
| `XF86AudioRaiseVolume` / `Lower` | Aumenta / Diminui volume com feedback OSD |
| `XF86AudioMute` | Silencia áudio |
| `XF86MonBrightnessUp` / `Down` | Aumenta / Diminui brilho da tela com feedback OSD |
| `XF86KbdBrightnessUp` / `Down` | Aumenta / Diminui luz do teclado Apple (`smc::kbd_backlight`) |
| `$SUPER + F6` / `$SUPER + F5` | Atalho direto: Aumenta / Diminui luz do teclado |
| `$SUPER + Shift + F5` | Liga / Desliga luz do teclado |

---

## 🔧 6. Troubleshooting & Dicas

- **Verificar Monitores e Propriedades**:
  ```bash
  hyprctl monitors
  hyprctl clients
  ```
- **Recarregar Configurações a Quente**:
  ```bash
  hyprctl reload
  ```
- **Logs do Hyprland**:
  ```bash
  cat $XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/hyprland.log
  ```
- **Reiniciar Waybar**:
  ```bash
  killall waybar && waybar &
  ```

---

> 💡 **Para aplicar alterações no Home Manager**:
> ```bash
> home-manager switch --flake .#juca@<host>
> ```
