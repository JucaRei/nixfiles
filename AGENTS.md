# 🧠 Memória e Diretrizes do Projeto (Antigravity / AI Pair Programming)

Este arquivo serve como **memória persistente** e guia de diretrizes para o assistente de IA neste repositório. Ele é carregado automaticamente a cada interação para manter o contexto, padrões arquiteturais e decisões tomadas.

---

## 📌 Contexto Geral do Repositório

- **Tipo**: Configuração declarativa usando **Nix Flakes** para **NixOS** e **Home Manager** (standalone e integrado).
- **Usuário Padrão**: `juca`
- **Hosts Comuns**: `fedora` (Home Manager standalone), `virtualvm` (NixOS), `rocinante` (NixOS — MacBook Pro 4,1).
- **Documentação Base**: Ver [README.md](file:///mnt/d/workspace/MyRepos/nixfiles/README.md) e [WIKI.md](file:///mnt/d/workspace/MyRepos/nixfiles/WIKI.md).
- **Memória por Host**: Consultar `nixos/hosts/<host>/ROCINANTE.md` (ou equivalente) para context específico de hardware.

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
3. **Boas Práticas de Modificação e Validação**:
   - Sempre manter comentários informativos e documentação existente.
   - **Validação Cirúrgica (Pontual)**: Durante edições passo a passo, valide apenas o que foi alterado (ex: `nix eval` da configuração alterada ou `nix flake check --no-build`) para evitar reavaliações e compilações pesadas desnecessárias.
   - **Verificação Global**: Deixe a execução completa de `nix flake check` apenas para o fechamento final da tarefa ou sob demanda do usuário.
4. **Padrão de Tiling Managers no Home Manager (NixOS vs Standalone)**:
   - Para qualquer Tiling Manager (Hyprland, BSPWM, etc.):
     - **Wrapper de Inicialização**: Gerar `~/.local/bin/start-<wm>` carregando o profile do Nix (`nix-daemon.sh` e `nix.sh`), drivers gráficos nativos (`GBM_BACKENDS_PATH` e `LIBGL_DRIVERS_PATH` no Wayland) e importação de variáveis (`dbus-update-activation-environment --systemd ...` e `systemctl --user import-environment ...`).
     - **Sessões Desktop**: Gerar `.desktop` em `~/.local/share/wayland-sessions/` ou `~/.local/share/xsessions/`. Em distros standalone, linkar para `/usr/share/*-sessions/` se o Display Manager não escanear diretórios de usuário.
     - **Autenticação PAM (Lockers)**: Screen lockers (`hyprlock`, `swaylock`) em distros standalone exigem link do helper setuid (`/run/wrappers/bin/unix_chkpwd -> /usr/sbin/unix_chkpwd` mantido via `systemd-tmpfiles`) e `/etc/pam.d/<locker>` configurado com `pam_unix.so try_first_pass nullok` e `pam_deny.so` (evita módulos inexistentes no Nix Store como `pam_pwquality`).
     - **Teclado Unificado**: Módulos devem herdar configurações de `home.keyboard` (`layout`, `variant`, `model`).


---

## ⚡ Comandos Rápidos de Validação e Aplicação

- **Validação Rápida / Cirúrgica (Sem build pesado de tudo)**:
  ```bash
  # Validação de sintaxe e tipos rápida sem compilar pacotes:
  nix flake check --no-build

  # Avaliar apenas a máquina / pacote alterado:
  nix eval .#homeConfigurations."juca@<host>".config.home.stateVersion
  nix eval .#nixosConfigurations.<host>.config.system.stateVersion
  ```
- **Verificação de Flake Completa (Apenas no final)**:
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
- **`flake.nix` & `lib/`**: Simplificação de `homeConfigurations`, modernização do `formatter` para `nixfmt-rfc-style`, redução de sistemas suportados para Linux (`x86_64-linux` e `aarch64-linux`), e adoção de validações pontuais em etapas intermediárias.
- **`overlays/default.nix` & `overlays/patches/`**: 
  - `inherit (final) system` renomeado para `inherit (final.stdenv.hostPlatform) system` (evita deprecation warning).
  - `permittedInsecurePackages` global removido (scoped para hosts específicos).
  - Patch `legacy340-for-nix-kernel-modules.patch` (Issue #554929 / PR #555840 + GCC 15 / Kernel 6.6 fixes) aplicado em `modifiedPackages` via `linuxKernel.packagesFor`:
    - Corrige KBuild com `$src` no nix store e target `modules_install`.
    - Injeta flags no `conftest.sh`: `-std=gnu11` (evita keywords C23 `bool`/`false` do GCC 15), `-fshort-wchar` (corrige parsing de EFI UTF-16) e `-Wno-error=implicit-function-declaration` (preserva lógica invertida de detecção de funções).
    - Adiciona fallback para `dma_mapping_error` no `nv-linux.h` substituindo a chamada legada removida `pci_dma_mapping_error`.
- **`modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix`** (driver NVIDIA 340 Legacy):
  - Atributo correto: `config.boot.kernelPackages.nvidia_x11_legacy340` (não `nvidiaPackages.legacy_340`).
  - **Não usar `hardware.nvidia`** — o módulo `hardware/video/nvidia.nix` do nixpkgs adiciona `nvidia_modeset`/`nvidia_drm` incondicionalmente, módulos que o Legacy 340 não possui. Configurado via `boot.extraModulePackages = [ legacy340.bin legacy340.mod ]` e `services.xserver.drivers` diretamente.
  - `xserver.videoDrivers = lib.mkForce []`.
- **Host `rocinante`** (MacBook Pro 4,1 - Early 2008): Ver [ROCINANTE.md](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/ROCINANTE.md). Configurado com boot dual:
  - **Padrão**: Kernel Zen (`pkgs.unstable.linuxPackages_zen`) com driver open-source `nouveau`.
  - **`specialisation.nvidia`**: Kernel 6.6 LTS (`pkgs.linuxPackages_6_6`) com driver proprietário NVIDIA 340 Legacy. Selecionável no menu GRUB.
  - **Boot CSM / Legacy**: `bootType = "legacy"` (GRUB BIOS `i386-pc` no MBR `/dev/sda` com partição `bios_grub` `/dev/sda1` e Hybrid MBR) é obrigatório para acionar a emulação BIOS da Apple, que espelha a Video BIOS (VBIOS) em `0xC0000`. Em EFI nativo, a NVIDIA 340 falha com `failed to copy vbios to system memory`.
  - **Fix `libglx.so`**: Adicionado `postFixup` no overlay de `nvidia_x11_legacy340` criando symlink `libglx.so -> libglx.so.340.108` em `$bin/lib/xorg/modules/extensions`, corrigindo o carregamento indevido do GLX do Mesa pelo Xorg.
  - **Parâmetros de Kernel**: `specialisation.nvidia` usa `mkForce` para definir parâmetros limpos sem `nouveau.modeset=1` nem `pcie_aspm=force`.
- **Estética Polybar e BSPWM**: Inspirada na suíte de rices [gh0stzk/dotfiles](https://github.com/gh0stzk/dotfiles), utilizando paleta Catppuccin Mocha com ícones Nerd Font coloridos, pills de workspaces (`󰮯`, `󰊠`, `󰀦`), indicadores de download/upload (`󰇚`, `󰕒`), menus interativos via Rofi (Wi-Fi, Bluetooth, Power Menu) e feedback visual OSD via Dunst.
- **Rede Dinâmica (Polybar) & Auto-switching (Rocinante)**:
  - **Polybar**: Módulo de rede dinâmico (`scripts.networkScript`) identifica automaticamente conexão cabeada (`󰈀 $con_name`) ou Wi-Fi (`󰤨 $ssid` com ramp de sinal), além de estados `Desativado` e `Offline`. O módulo de velocidade de tráfego (`netspeed`) mede tráfego agregado (`accumulate-stats = true`) de ambas as interfaces.
  - **Host `rocinante`**: Auto-switching configurado via NetworkManager dispatcher (`networking.networkmanager.dispatcherScripts`) e serviço systemd de boot (`systemd.services.wifi-wired-autoswitch`): desativa o rádio Wi-Fi ao plugar o cabo de rede (`up`), e reativa o rádio Wi-Fi ao desconectar o cabo (`down`).
- **Suporte a Clientes OpenGL no NVIDIA 340 Legacy (Alacritty / GLX)**:
  - O driver 340.108 é pré-libglvnd e monolítico (`libGL.so.340.108`). Binários Nix modernos trazem `libglvnd` no seu RPATH e buscam `libGLX_nvidia.so.0` (inexistente no Legacy 340), causando erro `failed to find suitable GL configuration` ou `couldn't find RGB GLX visual`.
  - Resolvido exportando `LD_LIBRARY_PATH=/run/opengl-driver/lib:/run/opengl-driver-32/lib` nas variáveis de sessão do NixOS (`environment.sessionVariables`, `environment.extraInit`), no Home Manager X11 e no `bspwmrc` antes do `sxhkd`. Isso prioriza o carregamento direto do `libGL.so.1` nativo da NVIDIA e ativa a renderização direta 3D por hardware na GeForce 8600M GT.
- **Janelas Flutuantes e Seletores de Arquivos/Pastas (BSPWM)**:
  - Diálogos de seleção de arquivos/pastas (ex: "Open Folder" / "Abrir pasta" do VSCode, `GtkFileChooserDialog`, `xdg-desktop-portal-gtk`) por padrão eram mapeados como janelas normais (tiled/fullscreen).
  - Configurado conjunto de regras estáticas e um script dinâmico via `external_rules_command` (`bspwm-external-rules` usando `xprop` e regex bilíngue PT/EN) que força estado flutuante centralizado e compacto (`state=floating center=on rectangle=850x550+0+0 follow=on`). Demais janelas modais (`_NET_WM_WINDOW_TYPE_DIALOG`) recebem `state=floating center=on` mantendo dimensões naturais.
- **Gestos do Touchpad (libinput-gestures no BSPWM)**:
  - **3 dedos**: Alternar entre workspaces/desktops do BSPWM (`swipe left 3` -> `next.local`, `swipe right 3` -> `prev.local`).
  - **4 dedos**: Alternar abas do navegador ou editor em uso (`swipe left 4` -> `ctrl+Page_Down` / próxima aba, `swipe right 4` -> `ctrl+Page_Up` / aba anterior) com `--clearmodifiers`, executado dinamicamente via script `browser-tab-switch` apenas quando um navegador ou aplicativo com abas estiver em foco.
  - Supervisionado via serviço systemd do usuário (`systemd.user.services.libinput-gestures`) com recarregamento automático no `home-manager switch`.
- **Módulo Hyprland (Wayland - Home Manager e NixOS)**:
  - **Home Manager**: Localizado em `modules/home-manager/desktop/environments/hyprland/`. Arquitetura modular composta por `hyprland.nix` (compositor, animações bezier `fastBezier`/`overshot`, blur de 2 passes, cantos arredondados de 10px, sombras suaves translúcidas, regras de janelas para diálogos modais e PIP, gestos de 3 dedos nativos), `waybar.nix` (barra superior flutuante estilo *floating pills* com tema Catppuccin Mocha, workspaces interativos, relógio com calendário, pulseaudio com scroll, rede dinâmica wifi/ethernet, backlight, bateria e menu de energia), `rofi.nix` (launcher e histórico de clipboard com `cliphist`), `hyprlock.nix` (bloqueio de tela moderno com blur, tipografia e avatar do usuário), `hypridle.nix` (gestão de inatividade), `hyprpaper.nix` (papel de parede), `dunst.nix` (notificações) e `packages.nix` (grim, slurp, wl-clipboard, etc.).
  - **NixOS**: Em `modules/nixos/desktop/environments/hyprland/default.nix`, adicionado serviço PAM para o `hyprlock` (`security.pam.services.hyprlock = {};`) e portals Wayland. Em `modules/nixos/desktop/display-managers/default.nix`, configurado mapeamento declarativo via `mkDefault` conectando `desktop.display-managers.name` aos respectivos DMs (`regreet`, `sddm`, `lightdm`, `gdm`).

- **Host `anubis` com Hyprland (Fedora Standalone)**:
  - Configurado via `desktop = "hyprland"` no `flake.nix`.
  - Gera `~/.local/bin/start-hyprland` com ambiente do Nix carregado e `.local/share/wayland-sessions/hyprland.desktop`.
  - **Display Manager**: SDDM instalado nativamente no Fedora (`dnf install sddm dconf`) com leitura de `/usr/share/wayland-sessions/hyprland.desktop`.
  - **Compatibilidade Hyprland 0.55+ (Nixpkgs 26.05)**:
    - `configType = "hyprlang"` forçado no Home Manager para evitar quebra de sintaxe com o gerador experimental em Lua.
    - Regras de janela migradas de `windowrulev2` para `windowrule = [ "match:class ..., float 1" ... ]` com valores estritos.
    - Gestos atualizados de `gestures.workspace_swipe` para `gesture = [ "3, horizontal, workspace" ]`.
    - Atalho de layout migrado de `togglesplit` para `layoutmsg, togglesplit`.
  - **Estabilização de Vídeo Intel HD 3000 (Sandy Bridge)**:
    - Desativado VFR (`debug.vfr = false`) para evitar oscilações de brilho/tensão no painel eDP em repouso.
    - Ativado cursor por software (`cursor.no_hardware_cursors = true`) para evitar micro-flickering de recálculo de plano DRM na GPU.
    - `render.direct_scanout = 0`.
    - Drivers Mesa e GBM declarados explicitamente via `GBM_BACKENDS_PATH` e `LIBGL_DRIVERS_PATH` no wrapper `start-hyprland` e propagados ao `systemd --user`.
    - Eliminada duplicidade de inicialização do `hyprpaper` (`exec-once` vs serviço systemd) que causava piscamento na tela a cada 2s.
  - **Aceleração VA-API (Intel HD 3000)**:
    - Sandy Bridge utiliza o driver legado `intel-vaapi-driver` (`i965`), pois o moderno `intel-media-driver` (`iHD`) suporta apenas Broadwell (Gen 8) em diante.
    - Exportados `LIBVA_DRIVER_NAME = "i965"` e `LIBVA_DRIVERS_PATH = "${pkgs.intel-vaapi-driver}/lib/dri:/usr/lib64/dri"`.
  - **Teclado Apple / Mac no Hyprland**:
    - Herdado declarativamente de `home.keyboard` (`layout = "us"`, `variant = "intl"`, `model = "apple"`).
    - Habilita suporte a dead keys para acentos em Português (`'c` -> `ç`, `~a` -> `ã`, `'e` -> `é`) e mapeamento físico correto no teclado do MacBook Air.
  - **Autenticação do Hyprlock no Fedora (PAM)**:
    - Em distribuições não-NixOS com Home Manager standalone, `/etc/pam.d/hyprlock` não existe por padrão, fazendo o PAM cair na regra `/etc/pam.d/other` (que rejeita qualquer tentativa como "Wrong password!").
    - Requer provisionar `/etc/pam.d/hyprlock` incluindo `system-auth` (`auth`, `account`, `password`, `session include system-auth`).
  - **Controle de Iluminação do Teclado e Tela (MacBook / Laptops)**:
    - Dispositivo `smc::kbd_backlight` integrado via script `hypr-kbd-brightness-osd` com feedback visual OSD via Dunst.
    - Atalhos configurados: `XF86KbdBrightnessUp`/`Down`, `XF86KbdLightOnOff`, com atalhos diretos `$mainMod + F6` (aumentar), `$mainMod + F5` (diminuir) e `$mainMod + Shift + F5` (liga/desliga).
    - Integrado ao `hypridle`: desliga a luz do teclado após 2.5 min de inatividade e restaura automaticamente.
- **Módulo MangoWM (Wayland - dwl / scenefx)**:
  - Adicionado suporte ao compositor **MangoWM** (`desktop = "mangowm"` ou `"mango"`), tiling Wayland moderno e ultra-leve com suporte a blur, sombras e cantos arredondados (scenefx) e tags estilo dwm/dwm.
  - Totalmente integrado à paleta Catppuccin Mocha, compartilhando Waybar, Rofi, Dunst, Hyprlock, Hypridle e Hyprpaper.
  - Wrapper `start-mango` em `~/.local/bin/` com drivers gráficos nativos e `.desktop` em `wayland-sessions`.
  - Herança de teclado unificada (`home.keyboard`) com dead keys e controles multimídia/brilho idênticos.
  - **Deploy no Anubis (Fedora Standalone)**:
    - Removido `alacritty` do `home.packages` do mangowm para prevenir colisão de `buildEnv` com o wrapper nixGL (`programs.alacritty`).
    - Wrapper `start-mango` sincronizado com drivers Mesa/VA-API (`i965`), limpeza de `WAYLAND_DISPLAY` legado do display manager e exportação para D-Bus / Systemd.
  - **Tema GTK e Dark Mode no Thunar / Wayland**:
    - O pacote `pkgs.catppuccin-gtk` gera o diretório do tema em caixa baixa: `catppuccin-mocha-blue-standard+rimless`. Nomes em CamelCase como `Catppuccin-Mocha-Standard-Blue-Dark` não encontravam os arquivos em `share/themes/`, fazendo o GTK3 e o Thunar caírem silenciosamente no Adwaita Claro (`rgb(246,245,244)`).
    - Unificado o nome em todos os ambientes (`mangowm`, `hyprland`, `bspwm`, `xfce4`) para `catppuccin-mocha-blue-standard+rimless`.
    - Declarado `dconf.settings."org/gnome/desktop/interface"` com `color-scheme = "prefer-dark"`, export de `GTK_THEME` nos wrappers e symlinks retrocompatíveis em `~/.themes` e `~/.local/share/themes`.
  - **Menu de Energia e Encerramento de Sessão (Logout)**:
    - O script `session-power-menu` (e alias `hyprland-power-menu`) foi tornado agnóstico ao compositor: identifica se está rodando no MangoWM (`pkill -SIGTERM -x mango` / `loginctl terminate-session`), no Hyprland (`hyprctl dispatch exit`) ou em sessão genérica systemd.
    - No MangoWM, configurados os atalhos `$SUPER + Shift + E` e `$SUPER + Escape` para o menu de energia, e `$SUPER + Shift + Q` para encerrar a sessão imediatamente (`quit`).
  - **Waybar Customizada e Layout Switcher Dinâmico (Inspirado em `theblackdon/mango-waybar`)**:
    - Separado o Waybar do MangoWM em `modules/home-manager/desktop/environments/mangowm/waybar.nix`, substituindo as dependências do Hyprland por módulos nativos do DWL (`dwl/tags` de 1 a 9 com estados `focused`, `active`, `occupied`, `urgent` e `dwl/window` com rewrite de títulos por ícones).
    - Criado módulo dinâmico `custom/layout` com script `mango-layout-switcher` que interroga o estado em tempo real via `mmsg -g`, exibe ícone e nome do layout (Tile, Scroller, Grid, Monocle, etc.) e ao clicar abre o seletor rápido `mango-layout-picker` via Rofi.
    - Adicionados scripts `mango-reload` (recarrega MangoWM via `mmsg -d reload_config` e Waybar via sinal `SIGUSR2`) e `mango-toggle-outer-gaps` (alterna entre gaps normais e modo gravação/foco).
    - Criado guia completo de referência e customização em [modules/home-manager/desktop/environments/mangowm/README.md](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/mangowm/README.md).
- **Host `rocinante-hyperv` (Bootloader, Resolução & Multimídia MPV)**:
  - **Label `EFI` na partição FAT32**: `/boot/efi` depende de `/dev/disk/by-label/EFI`. Se a partição estiver sem rótulo, o `boot-efi.mount` falha e cai no stub de automount `systemd-1` do PID 1, quebrando o `grub-install` com `Inappropriate ioctl for device`. Corrigido via `fatlabel /dev/sda2 EFI`.
  - **MPV e Perfil de Hardware (`hw-preset`)**: A diretiva `profile=hw-preset` deve ser declarada em uma seção `[default]` no final de `mpv.conf`, garantindo que as opções do hardware (ex: `vo=x11`, `hwdec=no` no Hyper-V sem GPU 3D) sobrescrevam a base (`vo=gpu`) e evitando inclusão recursiva dentro de `[hw-preset]`.
  - **Script `thumbfast`**: O parâmetro `hwdec` espera um booleano (`yes`/`no`), e o valor legado `'auto'` causava erro de parsing na inicialização. Fixado em `hwdec=no`.
  - **Pacote `xrandr`**: Em `home-manager/hosts/rocinante-hyperv/default.nix`, configurado `xrandr` (em vez do inexistente `xrender`) para suporte ao comando em `xsession.initExtra`.
- **Overlay `antigravity-cli`**:
  - O módulo `programs.antigravity-cli` do Home Manager busca `pkgs.antigravity-cli`. No canal estável (`nixpkgs`), o pacote ainda se chamava `gemini-cli` e não possuía o alias `antigravity-cli`.
  - Configurado fallback em `overlays/default.nix` (`modifiedPackages`): `antigravity-cli = prev.antigravity-cli or final.unstable.antigravity-cli;`, garantindo resolução transparente para todos os módulos e hosts.
- **MangoWM — Power Menu, WiFi e Tags Inteligentes**:
  - **`session-power-menu` duplicado no MangoWM**: O script era definido apenas no módulo Hyprland (`hyprland/waybar.nix`), causando falha no MangoWM que o referenciava sem path absoluto. Duplicado em `mangowm/waybar.nix` com mesma lógica agnóstica ao compositor e adicionado a `home.packages` + paths absolutos do Nix Store nos `on-click` da Waybar.
  - **`rofi-wifi-menu`**: Novo script de seleção WiFi via Rofi + `nmcli` nativo do Fedora (`/usr/bin/nmcli`). Suporta escanear redes, conectar/desconectar com senha via prompt Rofi, e ligar/desligar rádio WiFi. Vinculado ao `on-click` do módulo `network` da Waybar.
  - **Tags 6-9 ocultas quando vazias**: CSS `#tags button.empty:nth-child(n+6)` com `opacity: 0; font-size: 0; padding: 0;` para economizar espaço na tela de 1366x768 do MacBook Air. Tags aparecem automaticamente quando recebem janelas, foco ou urgência. `tag_num=9` e keybindings completos mantidos.
  - **Deploy remoto via SSH**: `nix copy --to ssh://` requer `nix-store` no PATH padrão do SSH (não-interativo). No Fedora com Determinate Nix, criado symlink `/usr/local/bin/nix-store -> /nix/var/nix/profiles/default/bin/nix-store` e adicionado `trusted-users = root juca` em `/etc/nix/nix.custom.conf` para permitir cópias sem assinatura.
  - **Hyprpaper falha no Intel HD 3000**: `PRIME export not supported` e `eglCreateImageKHR failed` — limitação do hardware Sandy Bridge. Wallpaper via `hyprpaper` não funciona; alternativa seria `swaybg`.
- **MangoWM — Fix de Inicialização do Waybar & Janela Ativa (`custom/window`)**:
  - **Crash por `SIGSEGV` do `dwl/window`**: O módulo nativo C++ `dwl/window` do Waybar 0.15.0 tentava conectar-se ao protocolo `dwl_status_manager_v2`. Como o MangoWM moderno/nightly não expõe essa interface específica, o construtor do Waybar causava core dump (`dwl::Window::Window` segfault) matando o Waybar no boot.
  - **Módulo `custom/window`**: Substituído o instável `dwl/window` por `custom/window` com script `mango-window-title` que consulta `mmsg get focusing-client` via IPC nativo do MangoWM, extrai `title` e `appid` com `jq -c` em linha única, aplica ícones dinâmicos Nerd Font (Firefox, VS Code, Terminal, etc.) e trunca títulos longos para telas menores.
  - **Sintaxe moderna do `mmsg`**: Atualizados os scripts `mangoLayoutSwitcher`, `mangoLayoutPicker`, `mangoReload` e `mangoToggleOuterGaps` para a sintaxe do MangoWM nightly (`mmsg get <query>` e `mmsg dispatch <func>[,arg...]`). Adicionado fallback automático para encontrar o socket `MANGO_INSTANCE_SIGNATURE` em `/run/user/<uid>/mango-*.sock`.
- **MangoWM — Suporte Nativo a Workspaces (`ext/workspaces`) & Gestos de 3 Dedos**:
  - **Workspaces na Waybar**: O MangoWM moderno adota o protocolo Wayland oficial `ext-workspace-v1` (`ext_workspace_manager_v1`), e não o legado `dwl_status_manager_v2`. O módulo foi migrado de `dwl/tags` para `ext/workspaces` com `sort-by-id = true`, exibindo os botões de workspace reativos com tema Catppuccin e ocultação de tags vazias acima de 5.
  - **Swipe de Workspaces com 3 dedos**: Configurado `gesturebind=none,left,3,viewtoright,0` e `gesturebind=none,right,3,viewtoleft,0` para alternar workspaces horizontalmente, e `up`/`down` para alternar overview (`toggleoverview`), movendo os comandos de foco de janela para 4 dedos.
- **Backlight e Iluminação (Passos de 2% no Anubis)**:
  - **Causa dos Saltos de 7%**: O kernel Linux no MacBook Air 4,1 registrava por padrão apenas a interface ACPI legada `acpi_video0` (`max_brightness = 15`), onde 1 passo representava 6.67% (~7%).
  - **Ativação PWM Nativa**: Injetado `acpi_backlight=native` nos parâmetros de boot do kernel via `grubby` e `/etc/default/grub` no Fedora, permitindo controle fino do backlight via `intel_backlight`.
  - **Scripts Unificados em 2%**: `mango-mon-brightness-osd`, `mango-kbd-brightness-osd`, `hypr-mon-brightness-osd` e o módulo `backlight` do Waybar atualizados para saltos de **2%** (`+2%` e `2%-`) com fallback para step unitário (`+1`/`1-`).
- **Antigravity IDE & Terminal Integrado no Fedora Standalone (`anubis`)**:
  - **Wrapper FHS vs Nativo**: O wrapper `pkgs.unstable.antigravity-ide-fhs` utiliza Bubblewrap (`bwrap`) para isolar o ambiente simulando o FHS no NixOS. No Fedora standalone, isso isolava o `/usr/bin` do host (comandos `sudo`, `systemctl`, `ps`, `ip`, `hostname` e `dnf` sumiam no terminal) e quebrava o link `/etc/os-release`, causando crash do `nitch` com `IOError` a cada inicialização de terminal.
  - **Módulo `editors/antigravity`**: Ajustado pacote padrão para `if isNixOS then pkgs.unstable.antigravity-ide-fhs else pkgs.unstable.antigravity-ide;`, garantindo execução nativa sem sandbox no Fedora e mantendo `-fhs` no NixOS. Mantido alias `antigravity` apontando para `antigravity-ide` e removido o alias `agy` para não sombrear o binário oficial do `antigravity-cli` (`agy`).
  - **Ação Customizada no Thunar**: Corrigido comando de `antigravity %f` para `antigravity-ide %f` em `thunar/default.nix`.
- **Módulo Chromium / Chrome (`chrome/default.nix`) & nixGL Wrapper (`nixGL.nix`)**:
  - Adicionado `mkOption` na opção `system.programs.browsers.chromium.version` (evita erro de avaliação ao declarar string em vez de submódulo).
  - Corrigidas as checagens condicionais de seleção do pacote do navegador de `cfg.browser` para `cfg.version`.
  - Substituído `++ mkIf (...) [...]` por `++ optionals (...) [...]` na lista `commandLineArgs` para evitar erro de concatenação lista + attrset (`expected a list but found a set`).
  - Corrigido `home.packages` para evitar lista aninhada com `libva-utils` e removido o pacote obsoleto `vivaldi-ffmpeg-codecs` (Chromium 123 incompatível).
  - Em `lib/nixGL.nix`, adicionado repasse transparente de `.override` e `.overrideAttrs` aos pacotes envelopados pelo nixGL, permitindo que módulos como `programs.chromium` apliquem flags customizadas via `package.override`.
- **Vivaldi 8.1 & Codecs / libffmpeg (`overlays/default.nix` & `chrome/default.nix`)**:
  - O binário `vivaldi-bin` possui dependência dinâmica de `libffmpeg.so` localizada diretamente em `opt/vivaldi/libffmpeg.so`. Adicionado `$out/opt/vivaldi` ao `LD_LIBRARY_PATH` no wrapper do Vivaldi para que ele encontre o fallback nativo sem crashar com erro 127.
  - O pacote que vem no .deb do Vivaldi contém apenas codecs abertos. Codecs proprietários (H.264 / AAC / MP4 para YouTube e streaming) são baixados pelo script oficial `update-ffmpeg` e salvos em `~/.local/lib/vivaldi/media-codecs-8.1-.../libffmpeg.so`.
  - Criar um symlink `libffmpeg.so.8.1 -> libffmpeg.so` no store enganava o script lançador `/opt/vivaldi/vivaldi`, fazendo-o precarregar a versão aberta e ignorar a versão proprietária em `~/.local`. Esse symlink falso foi removido e o `update-ffmpeg` foi marcado como executável (`chmod +x`).
  - Adicionada ativação `setupVivaldiCodecs` no módulo do Chrome para garantir que o script `update-ffmpeg --user` seja acionado se os codecs proprietários ainda não estiverem baixados.
  - Removido `--enable-zero-copy` de `commandLineArgs` que quebrava renderização de vídeo em GPUs legadas (Intel HD 3000 / Sandy Bridge).
- **Waybar — Sensor de Temperatura da CPU (`waybar.nix`)**:
  - **Causa da Temperatura Incorreta**: Por padrão, o módulo `temperature` do Waybar consulta `/sys/class/thermal/thermal_zone0/temp`. Em MacBooks e diversos laptops x86 com Linux, `thermal_zone0` corresponde à bateria (`BAT0`, ~36°C) e não à CPU.
  - **Detecção Dinâmica de Hwmon**: Configurado `hwmon-path-abs` com lista de caminhos de hardware (`/sys/devices/platform/coretemp.0/hwmon` para Intel, `/sys/devices/pci.../hwmon` para AMD) e `input-filename = "temp1_input"`, permitindo que o Waybar localize dinamicamente o sensor do processador mesmo que a ordem numérica de `hwmon#` mude entre reinicializações.
  - **Feedback Visual e Alertas**: Adicionado `critical-threshold = 80`, troca dinâmica para o ícone `` quando crítico (`format-critical`), estilização `#temperature.critical` em vermelho (`#f38ba8`), e tooltip detalhado `CPU: {temperatureC}°C`.
- **Thunar — Suporte a GVfs, Samba/SMB e Navegação em Rede (`thunar/default.nix`)**:
  - **Causa da Ausência da Rede**: O Thunar compila a seção "Rede" (*Browse Network*) dinamicamente via `thunar_g_vfs_is_uri_scheme_supported ("network")`. Por padrão em distribuições não-NixOS (como Fedora standalone), o binário do Nix não encontrava os módulos GIO do GVfs (`libgvfsdbus.so`), limitando o VFS ao esquema `file://`.
  - **Wrapper do Thunar & Sessão GIO**: Criado `thunar-wrapped` via `symlinkJoin` + `makeWrapper` injetando `GIO_EXTRA_MODULES` (`${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules`) e `XDG_DATA_DIRS` (`${pkgs.gvfs}/share:/usr/share`).
  - Adicionado `pkgs.gvfs` em `home.packages` e exportado `GIO_EXTRA_MODULES` em `home.sessionVariables`, garantindo acesso completo a compartilhamentos Samba (`smb://`), descoberta WS-Discovery/Avahi (`network:///`), lixeira e montagens remotas tanto no terminal quanto no ambiente gráfico.

- **Desktops Home Manager — Limpeza de Redundâncias e Padronização**:
  - **Remoção de Blocos Duplicados**: Os blocos `xdg.mimeApps.enable`, `xdg.systemDirs` (`data` e `config`) e `targets.genericLinux.enable` estavam repetidos em [mangowm/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/mangowm/default.nix), [hyprland/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/hyprland/default.nix) e [bspwm/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/bspwm/default.nix). Como [desktop/environments/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/default.nix) importa todos os ambientes e já os define centralmente para qualquer workstation, as declarações filhas causavam duplicação de diretórios em listas como `XDG_CONFIG_DIRS` (`["/etc/xdg" "/etc/xdg"]`) e no `sessionPath`.
  - **Limpeza de `$PATH`**: Removido `$HOME/.local/share/applications` de `home.sessionPath` (que continha `.desktop` em vez de executáveis) e mantido apenas `$HOME/.local/bin` centralizado na raiz.
  - **Eliminação de Unused Bindings**: Removidos `osConfig ? null` e `isNixOS` não utilizados das assinaturas desses 3 submódulos, seguindo as diretrizes de código limpo.
  - **Resolução de Conflitos e Inseguranças (`flake check`)**:
    - **`GIO_EXTRA_MODULES`**: Removida definição redundante e conflitante em [xfce4/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/xfce4/default.nix), deferindo a gestão completa ao módulo centralizado do Thunar.
    - **VS Code**: `builtins.readFile ./settings.json` adotado no lugar de interpolação em string `"${./settings.json}"`, prevenindo path inválido no Nix store.
    - **Broadcom STA (`rocinante` / `iso-rocinante`)**: Declarado `broadcom-sta-6.30.223.271-63-7.1.9` em `nixpkgs.config.permittedInsecurePackages` com verificação segura via `lib.hasPrefix` e `lib.strings.hasInfix`.

- **Home Manager — Limpeza de Módulos Externos e Redundâncias (`home-manager/default.nix`)**:
  - **Módulo NUR Redundante**: Removido `inputs.nur.modules.homeManager.default`. A função desse módulo oficial é unicamente injetar `inputs.nur.overlays.default` em `nixpkgs.overlays`. Como esse overlay já é injetado diretamente em [lib/helpers.nix](file:///mnt/d/workspace/MyRepos/nixfiles/lib/helpers.nix) (na instância `pkgs` do standalone) e em [modules/home-manager/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/default.nix) (via `nixpkgs.overlays`), a importação era desnecessária e triplicada.
  - **Remoção de Código Morto (`disabledModules`)**: Removido bloco `disabledModules` que desabilitava o submódulo `delta.nix` do Catppuccin, uma vez que o módulo do Catppuccin nem sequer é importado no Home Manager.

- **Wayland — Arquitetura de Shells Gráficos (`traditional` vs `noctalia`)**:
  - **Reestruturação Modular**: Os componentes visuais e de sessão Wayland foram migrados para `modules/home-manager/desktop/display-servers/wayland/`:
    - `wayland/traditional/`: Agrupa `waybar.nix`, `rofi.nix`, `dunst.nix`, `hyprlock.nix`, `hypridle.nix` e `hyprpaper.nix`. A Waybar foi unificada e detecta automaticamente se o compositor em execução é `mangowm` (carregando `ext/workspaces`, `custom/layout`, `custom/window`) ou `hyprland` (carregando `hyprland/workspaces`, `hyprland/window`), mantendo todos os scripts utilitários (`mangoLayoutSwitcher`, `sessionPowerMenu`, `rofiWifiMenu`, etc.).
    - `wayland/noctalia/`: Fornece integração com o `pkgs.noctalia-shell`, gerando declarativamente `~/.config/noctalia/settings.json` e `~/.config/noctalia/colors.json` com o tema **Catppuccin Mocha Dark**. Configura barra superior flutuante (`floating`) com cápsula moderna, dock inferior com auto-hide, launcher de aplicativos centralizado com clipboard, control center com atalhos multimídia/rede e session menu.
    - **Scripts IPC e Keybindings do Noctalia**: Mapeados comandos IPC (`noctalia-launcher`, `noctalia-cliphist`, `noctalia-control-center`, `noctalia-session-menu`, `noctalia-wallpaper`) com atalhos de teclado integrados no MangoWM e Hyprland (`Super+Space`, `Super+v`, `Super+p`, `Super+Escape`, `Super+Alt+w`).
    - **Ajustes de Sombra, Barra e Notificações no Noctalia**:
      - O componente `NDropShadow` do Noctalia aplica blur de 22px com opacidade 0.85 em superfícies layer-shell (`WlrLayer.Top` / `WlrLayer.Overlay`), o que projetava sombras pretas massivas sobrepondo e cortando janelas em tiling (como o Alacritty).
      - Configurado `general.enableShadows = false` e offsets zero, desativando a camada de sombra do Quickshell globalmente (barra, notificações, OSD e painéis).
      - Em `bar`, configurado `enableExclusionZoneInset = false` (evita que janelas sangrem por baixo da barra) com margens proporcionais (`marginVertical = 4`, `marginHorizontal = 8`).
      - Em `notifications`, definido `density = "compact"` (largura otimizada de 320px em vez de 440px para telas 1366x768 como a do MacBook Air / Anubis), opacidade 0.92 e tempos de exibição equilibrados.
      - **Clima no Calendário**: Adicionados blocos `location` (`name = "São Paulo, Brazil"`, `autoLocate = true`, `weatherEnabled = true`, `useFahrenheit = false`) e `calendar` com `weather-card`, permitindo que o `LocationService` consulte automaticamente as coordenadas e previsão da Open-Meteo para exibição no painel de relógio/calendário.
      - **Workspaces na Barra**: O widget `Workspace` em compositores Wayland genéricos/dwl requer `followFocusedScreen = true` (para parear saídas globais sem projeção fixa de output), `hideUnoccupied = false`, `labelMode = "index"` e `showLabelsOnlyWhenOccupied = false`, garantindo a exibição de todas as tags ativas com seus índices visíveis.
      - **Dock e Ícones**: Configurado `pinnedStatic = true` e nomes canônicos de `.desktop` instalados no host (`firefox.desktop`, `vivaldi-stable.desktop`, `thunar.desktop`, `Alacritty.desktop`, `antigravity-ide.desktop`), permitindo que o Quickshell resolva os ícones do tema Papirus-Dark / hicolor corretamente.
  - **Opções Declarativas**:
    - `desktop.wayland.shell`: Permite selecionar o shell desejado (`enum [ "traditional" "noctalia" ]`), tendo como default `"traditional"`.
    - `desktop.wayland.compositor`: Define/detecta o compositor em execução (`"hyprland"` ou `"mangowm"`).
    - `lib/helpers.nix`: Adicionado parâmetro opcional `waylandShell ? "traditional"` às funções `mkHome` e `mkNixos`, repassado via `extraSpecialArgs`.
  - **Desacoplamento dos Compositores**: `modules/home-manager/desktop/environments/hyprland/` e `modules/home-manager/desktop/environments/mangowm/` agora cuidam estritamente do gerenciador de janelas, monitores e regras de janelas, com seus blocos de inicialização (`exec-once`) e atalhos de launcher se adaptando dinamicamente ao shell selecionado (`traditional` ou `noctalia`). Eliminadas todas as duplicidades de arquivos entre compositores.

---

- **Noctalia Shell — Workspaces Dinâmicos no MangoWM (`ext-workspace-v1`)**:
  - **Causa da Ausência de Workspaces**: O Noctalia Shell detectava o MangoWM via `XDG_CURRENT_DESKTOP=mango` e forçava o `MangoService.qml`, que dependia do protocolo legado DWL IPC (`zdwl_ipc_manager_v2`). Como o MangoWM moderno/nightly utiliza o protocolo oficial Wayland `ext-workspace-v1` (`ext_workspace_manager_v1`), o `DwlIpc.available` falhava e a contagem de workspaces ficava em zero.
  - **Patch `noctalia-mangowm-workspaces.patch`**:
    - `CompositorService.qml`: chaveia o backend para `extWorkspaceComponent` ao detectar o MangoWM.
    - `ExtWorkspaceService.qml`: substitui o timer one-shot de 500ms por um timer de repetição com intervalo de 200ms para descoberta resiliente de `WindowManager.windowsets`, ordena os workspaces numericamente (1, 2, 3...) e calcula `isOccupied = (ws.shouldDisplay && !ws.active)` com base nas janelas relatadas pelo MangoWM.
  - **Comportamento Dinâmico Incrementável**: Configurado `hideUnoccupied = true` no widget `Workspace` em `modules/home-manager/desktop/display-servers/wayland/noctalia/default.nix`. Apenas workspaces ocupados (com janelas) e o workspace atualmente ativo são renderizados na barra superior ao lado do launcher. À medida que novos workspaces são navegados ou recebem janelas, eles surgem dinamicamente e se incrementam na barra.
  - **Idempotência no Overlay**: Injetado `final.lib.optional (!(builtins.elem ...))` em `overlays/default.nix` prevenindo duplicação de patches no encadeamento de overlays do Home Manager.

> 💡 **Dica**: Você pode adicionar novas preferências ou regras a qualquer momento neste arquivo ou utilizando o comando `/learn`.




