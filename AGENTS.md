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
   - **Atualização Contínua da Memória (`AGENTS.md`)**: Sempre que um diagnóstico, solução de problema técnico ou decisão arquitetural for realizada, atualizar imediatamente e de forma proativa este arquivo (`AGENTS.md`), mantendo o histórico e os passos de reprodução/correção sem depender de pedido explícito do usuário.
   - **Validação Cirúrgica (Pontual)**: Durante edições passo a passo, valide apenas o que foi alterado (ex: `nix eval` da configuração alterada ou `nix flake check --no-build`) para evitar reavaliações e compilações pesadas desnecessárias.
   - **Verificação Global**: Deixe a execução completa de `nix flake check` apenas para o fechamento final da tarefa ou sob demanda do usuário.
4. **Padrão de Tiling Managers no Home Manager (NixOS vs Standalone)**:
   - Para qualquer Tiling Manager (Hyprland, BSPWM, etc.):
     - **Wrapper de Inicialização**: Gerar `~/.local/bin/start-<wm>` carregando o profile do Nix (`nix-daemon.sh` e `nix.sh`), drivers gráficos nativos (`GBM_BACKENDS_PATH` e `LIBGL_DRIVERS_PATH` no Wayland) e importação de variáveis (`dbus-update-activation-environment --systemd ...` e `systemctl --user import-environment ...`).
     - **Sessões Desktop**: Gerar `.desktop` em `~/.local/share/wayland-sessions/` ou `~/.local/share/xsessions/`. Em distros standalone, linkar para `/usr/share/*-sessions/` se o Display Manager não escanear diretórios de usuário.
     - **Autenticação PAM e Privilégios Setuid**: Em distros standalone, utilitários do Nixpkgs exigem links para helpers setuid nativos mantidos via `systemd-tmpfiles` em `/run/wrappers/bin/`:
       - Screen lockers (`hyprlock`, `swaylock`): `/run/wrappers/bin/unix_chkpwd -> /usr/sbin/unix_chkpwd` e `/etc/pam.d/<locker>` configurado.
       - Agentes Polkit (`polkit-gnome`): `/run/wrappers/bin/polkit-agent-helper-1 -> /usr/lib/polkit-1/polkit-agent-helper-1`.
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

- **`modules/home-manager/default.nix`**: Adicionado `config.nix.package` a `home.packages` em hosts não-NixOS (`!isNixOS`). No Home Manager standalone, a opção `nix.package` apenas valida o `nix.conf`, mas não expõe os binários ao PATH; com essa inclusão, a versão mais recente do Nix declarada (`pkgs.nixVersions.latest`) passa a ter precedência sobre o pacote do sistema host (ex: Debian `nix-bin`).
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
- **Host `nitro` (Debian Standalone) — nixGL e Alacritty**:
  - **Problema**: Alacritty falhava com `Error: "failed to find suitable GL configuration."` no Debian. Dual GPU: Intel UHD 630 (display) + NVIDIA GTX 1050 Mobile (discreta).
  - **Causa raiz em 3 camadas**:
    1. `nixgl.overlay` avalia `auto.nixGLDefault` ao construir `pkgs`. Com `--impure`, lê `/proc/driver/nvidia/version` (v580.178.04) e tenta construir `nixGLNvidia-580.178.04`.
    2. O nixpkgs 26.05 **mudou a API do pacote NVIDIA** (removeu argumento `kernel`), causando falha em `nvidiaDrivers.override { libsOnly = true; }`.
    3. O wrapper em `lib/nixGL.nix` chamava `${nixGL}/bin/nixGL` mas o binário do `nixGLIntel` se chama `nixGLIntel` (não `nixGL`).
  - **Correção**:
    - `flake.nix`: `nixGLType = "intel"` para o host `nitro` (Intel gerencia o display).
    - `lib/helpers.nix`: Quando `nixGLType != null && != "auto"`, aplica `nixGLOverrideOverlay` **após** o `nixgl.overlay` que substitui `auto.nixGLDefault` pelo wrapper correto, prevenindo a avaliação do nixGLNvidia quebrado.
    - `lib/nixGL.nix`: Adicionado parâmetro `nixGLType` (intel/nvidia/mesa/auto/null) e `nixGLBin` que calcula o nome correto do binário de cada variante (`nixGLIntel`, `nixGLMesa`, `nixGLNvidia`, `nixGL`).
    - `bspwm/packages.nix`: Criados arquivos `.desktop` para Alacritty (com nixGL no `Exec=`), Pavucontrol, Galculator, LXAppearance e Feh — necessário em Debian onde o menu gráfico não lê XDG_DATA_DIRS do Nix Store.
    - `bspwm/packages.nix`: Hook `home.activation.updateDesktopDatabase` — roda `update-desktop-database` a cada switch.
    - `hm-switch.nix`: Verificação pós-switch que testa o Alacritty e notifica via Dunst se GL falhar.
  - **Regra geral para laptops dual GPU não-NixOS**: sempre definir `nixGLType = "intel"` no `mkHome` quando o Intel gerencia o display (Optimus). A detecção automática (`auto.nixGLDefault`) só é segura quando o nixGL suporta a versão exata do driver NVIDIA presente no nixpkgs usado.
  - **Multimídia e Aceleração de Vídeo no MPV (Nitro 5)**:
    - O binário do `mpv` do Nix roda encapsulado pelo `nixGLIntel` com perfil `[hw-preset]` configurado para `vo=gpu`, `gpu-api=opengl` e `hwdec=vaapi` (Intel UHD 630 via driver `iHD` do `intel-media-driver`). Isso entrega decodificação 100% por hardware com baixíssimo consumo de CPU e bateria.
    - Tentativas de forçar o MPV do Nix a carregar bibliotecas do driver proprietário do Debian via injeção arbitrária de `LD_LIBRARY_PATH` geravam `Segmentation fault`.
    - Para integração limpa entre o Home Manager standalone e o stack NVIDIA do Debian:
      - Adicionado perfil `[nvidia]` no `mpv.conf` (`modules/.../mpv/default.nix`) com `hwdec=auto-safe` e shaders dedicados.
      - Criado o script executável `mpv-nvidia` em `home.packages` do host `nitro`: executa diretamente o pacote `mpv` do Nix (`${config.programs.mpv.package}/bin/mpv`) encapsulado com as flags do NVIDIA PRIME Offload (`__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia`). O `mpv` nativo do Debian (`/usr/bin/mpv`) falhava em sessões X11 devido a conflitos de provedor GLX (`update-glx`) ao inicializar EGL, enquanto o binário Nix gerenciado com nixGL lida perfeitamente com a alternância de contexto e preserva todos os plugins e scripts (`uosc`, `thumbfast`, `evafast`, `memo`).

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
- **Polybar & BSPWM — Rice Moderno, Cápsulas Dinâmicas & Otimizações**:
  - **Taskbar Interativa Polywins (`module/polywins`)**: Substituído o script de minimização estático pelo Polywins para BSPWM (`polywinsScript`). Exibe a lista reativa de janelas do workspace com ícones Nerd Font (Alacritty, Firefox, Code, Thunar, etc.), destacando a janela focada (Blue), janelas abertas e janelas minimizadas/ocultas (`󰖯` em tom atenuado).
  - **Controles Interativos Polywins**: Clique esquerdo foca ou minimiza a janela (e desoculta se estiver minimizada); clique do meio fecha a janela (`bspc node -c`); clique direito alterna modo flutuante (`bspc node -t ~floating`). Escuta eventos em tempo real via `bspc subscribe` (`tail = true`).
  - **Cápsulas Flutuantes Dinâmicas**: Os módulos `media` (playerctl) e `minimized` (janelas ocultas) agora encapsulam seus glifos de pílula (` ... `) internamente via script e retornam string vazia quando inativos, eliminando o bug de bolhas vazias órfãs na barra.
  - **Espaçamento e Topologia das Pílulas**: Agrupamento lógico e harmonioso dos módulos com separadores elegantes (`sep` com largura arejada e `dots` `` em `surface2`). Módulos auxiliares (`netspeed`, `keyboard`, `xwindow`, `minimized`) foram mantidos intactos e comentados para ativação imediata sob demanda.
  - **Data e Hora**: Novo design com ícone Sapphire `󰥔`, data em Blue, separador sutil e hora em Mauve (`23/09  00:30`), com alternância no clique para exibição completa do dia da semana e mês.
  - **Resolução de Conflito de Altura no BSPWM**: Corrigido `top_padding` de 20 para 36 em `bspwm.nix` para acomodar perfeitamente os 30px da Polybar mais 6px de respiro, evitando sobreposição das janelas lado a lado com a barra.
  - **Módulo Redshift / Filtro Noturno (`module/redshift`)**: Criado módulo e script dinâmico `polybar-redshift` com controle interativo de temperatura de cor (4500K noturno / 6500K diurno), alternância via clique esquerdo (`toggle`), reset via clique direito e ajuste fino de 500K via scroll (`increase`/`decrease`) com OSD via Dunst. O módulo está implementado e mantido desativado (comentado) na barra por padrão.
  - **Truncação Inteligente de Rede**: `networkScript` agora trunca SSIDs e conexões com mais de 14 caracteres, prevenindo estouro de layout horizontal.
- **Backlight e Iluminação (Passos de 2% no Anubis)**:
  - **Causa dos Saltos de 7%**: O kernel Linux no MacBook Air 4,1 registrava por padrão apenas a interface ACPI legada `acpi_video0` (`max_brightness = 15`), onde 1 passo representava 6.67% (~7%).
  - **Ativação PWM Nativa**: Injetado `acpi_backlight=native` nos parâmetros de boot do kernel via `grubby` e `/etc/default/grub` no Fedora, permitindo controle fino do backlight via `intel_backlight`.
  - **Scripts Unificados em 2%**: `mango-mon-brightness-osd`, `mango-kbd-brightness-osd`, `hypr-mon-brightness-osd` e o módulo `backlight` do Waybar atualizados para saltos de **2%** (`+2%` e `2%-`) com fallback para step unitário (`+1`/`1-`).
- **Antigravity IDE & Automação CDP / Auto Accept**:
  - **Wrapper FHS vs Nativo**: O wrapper `pkgs.unstable.antigravity-ide-fhs` utiliza Bubblewrap (`bwrap`) para isolar o ambiente simulando o FHS no NixOS. No Fedora standalone, isso isolava o `/usr/bin` do host (comandos `sudo`, `systemctl`, `ps`, `ip`, `hostname` e `dnf` sumiam no terminal) e quebrava o link `/etc/os-release`, causando crash do `nitch` com `IOError` a cada inicialização de terminal.
  - **Módulo `editors/antigravity`**: Ajustado pacote padrão para `if isNixOS then pkgs.unstable.antigravity-ide-fhs else pkgs.unstable.antigravity-ide;`, garantindo execução nativa sem sandbox no Fedora e mantendo `-fhs` no NixOS.
  - **Suporte a CDP (Chrome DevTools Protocol - Porta 9004)**: Para extensões de automação como `antigravity-auto-accept`:
    - Adicionada opção `system.programs.editors.antigravity.remoteDebuggingPort` (padrão `"9004"`).
    - Criado wrapper executável `antigravity` em `home.packages` que injeta `--remote-debugging-port=9004 "$@"`, garantindo compatibilidade com chamadas de terminal e scripts de reinício da extensão.
    - Provisionado arquivo `.desktop` unificado (`antigravity.desktop`) com o flag `--remote-debugging-port=9004` (eliminada duplicidade de `antigravity-ide.desktop` que gerava dois itens no Rofi).
    - Hook de ativação (`configureAntigravityCdp`) que injeta `"remote-debugging-port": "9004"` de forma persistente em `~/.antigravity-ide/argv.json`, garantindo que toda inicialização do Electron abra a porta CDP mesmo se disparada sem parâmetros de linha de comando.
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
- **Mango Layout Switcher e OSD no Noctalia Shell (`anubis` / Wayland)**:
  - **Widget `MangoLayout.qml`**: Criado componente de barra nativo em QML usando `BarPill` (`overlays/noctalia/MangoLayout.qml`), posicionado entre `Workspace` e `ActiveWindow`. Consulta o layout ativo em tempo real via IPC (`mmsg get layout`), exibindo `Tile`, `Scroll`, `Grid` ou `Mono`. Clique com botão esquerdo abre o `mango-layout-picker` (Rofi), e clique com botão direito alterna o layout (`switch_layout`).
  - **Prevenção de Janelas Aninhadas no Ajuste de Brilho**:
    - **Tela**: No Noctalia Shell, desativado o envio de notificações extras pelo script `mango-mon-brightness-osd`, delegando exclusivamente ao serviço nativo `OSD.qml` do Noctalia Shell que detecta alterações em `/sys/class/backlight` e exibe uma barra OSD única.
    - **Teclado**: O script `mango-kbd-brightness-osd` agora rastreia o ID da notificação em `/tmp/mango_kbd_notif_id` e atualiza a notificação existente no lugar via `notify-send -p -r "$last_id"`, impedindo o empilhamento de múltiplos cards na tela.
  - **Relógio e Calendário em Português**: Relógio configurado com data por extenso (`Segunda, 14 de setembro`) e segundos no horário (`HH:MM:SS`), com meses e dias traduzidos nativamente no calendário do Noctalia.
  - **Minimizar ao Clicar**: Clique esquerdo em `ActiveWindow`, `Taskbar` (se focada) e `DockContent` minimiza a janela em foco via `mmsg dispatch minimized`.
  - **Build Robusto via `postPatch`**: A injeção dos componentes no `noctalia-shell` foi migrada de um patch unificado estático para `postPatch` com script Python idempotente (`overlays/noctalia/patch-noctalia.py`) e cópia direta de `MangoLayout.qml`, garantindo compilações 100% determinísticas sem falhas de hunks.

  - **Desacoplamento dos Compositores**: `modules/home-manager/desktop/environments/hyprland/` e `modules/home-manager/desktop/environments/mangowm/` agora cuidam estritamente do gerenciador de janelas, monitores e regras de janelas, com seus blocos de inicialização (`exec-once`) e atalhos de launcher se adaptando dinamicamente ao shell selecionado (`traditional` ou `noctalia`). Eliminadas todas as duplicidades de arquivos entre compositores.

---

- **Noctalia Shell — Workspaces Dinâmicos no MangoWM (`ext-workspace-v1`)**:
  - **Causa da Ausência de Workspaces**: O Noctalia Shell detectava o MangoWM via `XDG_CURRENT_DESKTOP=mango` e forçava o `MangoService.qml`, que dependia do protocolo legado DWL IPC (`zdwl_ipc_manager_v2`). Como o MangoWM moderno/nightly utiliza o protocolo oficial Wayland `ext-workspace-v1` (`ext_workspace_manager_v1`), o `DwlIpc.available` falhava e a contagem de workspaces ficava em zero.
  - **Patch `noctalia-mangowm-workspaces.patch`**:
    - `CompositorService.qml`: chaveia o backend para `extWorkspaceComponent` ao detectar o MangoWM.
    - `ExtWorkspaceService.qml`: substitui o timer one-shot de 500ms por um timer de repetição com intervalo de 200ms para descoberta resiliente de `WindowManager.windowsets`, ordena os workspaces numericamente (1, 2, 3...) e calcula `isOccupied = (ws.shouldDisplay && !ws.active)` com base nas janelas relatadas pelo MangoWM.
  - **Comportamento Dinâmico Incrementável**: Configurado `hideUnoccupied = true` no widget `Workspace` em `modules/home-manager/desktop/display-servers/wayland/noctalia/default.nix`. Apenas workspaces ocupados (com janelas) e o workspace atualmente ativo são renderizados na barra superior ao lado do launcher. À medida que novos workspaces são navegados ou recebem janelas, eles surgem dinamicamente e se incrementam na barra.
  - **Idempotência no Overlay**: Injetado `final.lib.optional (!(builtins.elem ...))` em `overlays/default.nix` prevenindo duplicação de patches no encadeamento de overlays do Home Manager.
- **Noctalia Shell — Indicador de Tipo de Janela, Ocultar ao Clicar na Barra e Relógio/Calendário em pt-BR**:
  - **Indicador de Tipo de Janela (`ActiveWindow.qml`)**:
    - Adicionado badge visual (`Tiled`, `Floating`, `Fullscreen`, `Maximized`) ao lado do ícone e título da janela ativa no widget `ActiveWindow`.
    - Integrado listener nativo via `Process` executando `mmsg watch focusing-client` que atualiza o estado em tempo real no MangoWM.
    - O clique no badge de tipo de janela executa `mmsg dispatch togglefloating`, permitindo alternar instantaneamente entre modo flutuante e tiled.
  - **Ocultar / Minimizar Janela ao Clicar na Barra e Dock**:
    - **Barra Superior (`ActiveWindow.qml`)**: Clique com o botão esquerdo na janela ativa dispara `mmsg dispatch minimized`, minimizando a janela como em desktops convencionais.
    - **Taskbar Superior (`Taskbar.qml`)**: Se a aplicação clicada já estiver focada (`taskbarItem.isFocused`), dispara `mmsg dispatch minimized`; se não estiver focada, transfere o foco (`CompositorService.focusWindow`).
    - **Dock Inferior (`DockContent.qml`)**: Ao clicar em uma aplicação cujo toplevel primário já está ativo (`primaryToplevel.activated`), minimiza a aplicação (`mmsg dispatch minimized`), permitindo comportamento clássico de toggle focus/hide.
  - **Relógio com Segundos e pt-BR Exclusivo para Relógio e Calendário**:
    - **Relógio da Barra (`Clock.qml`)**: Exibe horas com segundos (`HH:mm:ss`) na linha superior e data formatada em Português do Brasil na linha inferior (`Segunda, 14 de setembro`), com tooltip no formato `Segunda, 14 de setembro - HH:mm:ss`. A formatação em pt-BR é scoped estritamente para o relógio e calendário, mantendo a linguagem do sistema e do restante do shell intacta.
    - **Cartões de Calendário (`CalendarHeaderCard.qml` & `CalendarMonthCard.qml`)**: Cabeçalhos de mês traduzidos para Português em maiúsculas (`SETEMBRO`, `SETEMBRO 2026`) e dias da semana abreviados como `DOM`, `SEG`, `TER`, `QUA`, `QUI`, `SEX`, `SÁB`.
- **Migração para Noctalia Desktop Shell v5+ (`pkgs.noctalia`)**:
  - **Arquitetura Unificada em C++/Wayland**: O Noctalia v5 é um desktop shell nativo e autocontido (sem dependência de Quickshell ou Qt), incorporando internamente barra, system tray (StatusNotifierItem), daemon de notificações, launcher, clipboard, control center, painel de sessão, wallpaper e sistema de OSD.
  - **Configuração Declarativa em TOML (`~/.config/noctalia/config.toml`)**:
    - Migrado de `settings.json`/`colors.json` do v4 para `config.toml` conforme a documentação oficial (`docs.noctalia.dev`).
    - **Tema**: Catppuccin Mocha Dark integrado nativamente (`source = "builtin"`, `builtin = "Catppuccin"`).
    - **Barra Superior**: Estruturada em `start` (`launcher`, `workspaces`, `mango_layout`, `active_window`), `center` (`clock`, `media`) e `end` (`tray`, `notifications`, `clipboard`, `network`, `bluetooth`, `volume`, `brightness`, `battery`, `control-center`, `session`).
    - **Configuração Declarativa Aberta (`desktop.wayland.noctalia.settings`)**:
      - Adicionada opção declarativa do tipo `(pkgs.formats.toml { }).type` em `modules/home-manager/desktop/display-servers/wayland/noctalia/default.nix`.
      - O arquivo `~/.config/noctalia/config.toml` é gerado mesclando as configurações base do rice Catppuccin Mocha (`defaultSettings`) com quaisquer atributos sobrescritos por hosts via `lib.recursiveUpdate defaultSettings cfg.settings`.
      - Permite que qualquer host (ex: `home-manager/hosts/anubis/default.nix`) defina facilmente parâmetros de `audio`, `location`, `brightness`, etc. diretamente em sintaxe Nix.
    - **Tiling Layout Switcher (`mango_layout`)**: Mapeado como widget `custom_button` (`glyph = "layout-dashboard"`, `tooltip = "MangoWM Tiling Layout"`). O clique esquerdo, botão do meio e scroll do mouse ciclam os layouts em tempo real via `exec mmsg dispatch switch_layout`, enquanto o clique com botão direito abre o seletor rápido `mango-layout-picker`.
    - **Integração Nativa com MangoWM**: O Noctalia v5 conecta-se diretamente ao socket IPC do MangoWM (`/run/user/<uid>/mango-*.sock`) através do seu backend dedicado `workspace_mango`, sincronizando workspaces, foco e estados de janelas em tempo real.
  - **Resolução de Notificações Duplicadas / "Shell Aninhada" e Dunst**:
    - Eliminados scripts e processos legados do Quickshell que rodavam instâncias sobrepostas.
    - Atalhos de brilho de tela (`brightness-up`/`down`), volume (`volume-up`/`down`/`mute`), iluminação do teclado (`keyboard-backlight-up`/`down`/`toggle`) e screenshots (`screenshot-fullscreen`/`region`) foram vinculados aos comandos IPC nativos (`noctalia msg <action>`).
    - O feedback visual de brilho e volume é processado exclusivamente pelo OSD nativo do Noctalia (`[osd.kinds] brightness = true`, `keyboard_backlight = true`), sem disparar `notify-send`, sem criar notificações de desktop e sem envolvimento do Dunst.
- **MangoWM — Seletor de Layouts Temático (`mango-layout-picker`) & Plugins do Noctalia Shell**:
  - **Seletor de Layouts Dinâmico**: O script `mango-layout-picker` detecta o socket do `noctalia dmenu` (`/run/user/<uid>/noctalia-dmenu-*.sock`). Quando ativo no Noctalia Shell, apresenta os 14 layouts de tiling diretamente no launcher nativo com a paleta Catppuccin Mocha. Em shells tradicionais ou fallback, invoca o Rofi com folha de estilo Catppuccin Mocha completa injetada inline via `-theme-str`.
  - **Widget `mango_layout` na Barra do Noctalia**: Clique com botão esquerdo abre o `mango-layout-picker`, enquanto clique com botão direito, botão do meio ou scroll do mouse ciclam os layouts via `mmsg dispatch switch_layout`.
  - **Adoção de Plugins Nativos do Noctalia v5**:
    - **`blackbartblues/keymap`**: Substituiu o cheatsheet manual e o plugin `kenn/keybind-cheatsheet`. Fornece visualização completa do mapa de teclado (ANSI 100%, 80%, etc.) e lista categorizada com suporte nativo a MangoWC (`mangowc_service.luau`). Atalhos `SUPER + F1`, `SUPER + ?` e `SUPER + /` vinculados diretamente a `noctalia msg panel-toggle blackbartblues/keymap:panel`. Widget `blackbartblues/keymap:widget` na barra superior.
    - **`prponkshe/mango-displays`**: Gerenciador de displays dedicado para MangoWM com suporte a resolução, escala e espelhamento (`wl-mirror`, `wdisplays`, `wlr-randr`). Widget `prponkshe/mango-displays:bar` integrado à barra superior.
    - **`gambled23/mangowm-keymode`**: Monitor do keymode ativo do MangoWM via `mmsg watch keymode`. Widget `gambled23/mangowm-keymode:mangowm-keymode` integrado à barra superior ao lado dos workspaces.
    - **Sintaxe de Identificadores de Plugins na Barra**: No Noctalia v5+, os widgets de plugins no `config.toml` são referenciados diretamente no formato `<autor>/<plugin>:<entry>` (ex: `yuuto/calculator:bar`), e **nunca** com prefixo `plugin:`, pois o resolver de C++ divide pelo primeiro `:` e repassa a primeira parte diretamente para `findPlugin()`.
    - **Widgets e Painéis Adicionais Instalados**:
      - **`yuki/lunar-workspaces`**: Indicador com fases da lua e estilos por estado (`yuki/lunar-workspaces:lunar_workspaces`), substituindo o widget padrão na barra. O bloco declarativo `[widget.workspaces]` foi mantido comentado para fácil reversão. Dependência `pkgs.socat` adicionada declarativamente.
      - **`yuuto/calculator`**: Widget na barra `yuuto/calculator:bar` com exibição de resultados e painel interativo `yuuto/calculator:panel`.
      - **`noctalia/timer`**: Widget na barra `noctalia/timer:bar` com contagem regressiva e painel interativo `noctalia/timer:panel`.
      - **`noctalia/notes`**: Widget na barra `noctalia/notes:notes` e painel lateral flutuante de notas markdown `noctalia/notes:panel`.
      - **`noctalia/wallhaven`**: Widget na barra `noctalia/wallhaven:wallhaven` e navegador de papéis de parede `noctalia/wallhaven:browser`.
      - Todos os painéis abrem diretamente ao clicar nos seus respectivos widgets da barra ou via comando IPC `noctalia msg panel-toggle <autor>/<plugin>:<panel>`.
  - **Atalhos de Recarregamento para Testes (`SUPER + R` e `SUPER + Shift + R`)**:
    - O script `mango-reload` foi aprimorado para recarregar simultaneamente as configurações do MangoWM (`mmsg dispatch reload_config`) e a shell Wayland ativa (`noctalia msg config-reload` no Noctalia ou sinal `SIGUSR2` na Waybar).
    - `SUPER + R`: Recarrega as configurações na hora sem fechar programas ou matar processos.
    - `SUPER + Shift + R`: Recarrega as configurações e reinicia completamente o serviço do shell (`mango-reload --restart`), acionando `systemctl --user restart noctalia`.
    - Atalhos idênticos propagados para o módulo Hyprland (`hyprctl reload`). Ambos com feedback visual via OSD / notificação desktop.
- **Catfish — Correção de Dependências de Runtime no Wrapper (`overlays/default.nix`)**:
  - O utilitário de busca `catfish` (usado nas Custom Actions do Thunar e XFCE4) executa `subprocess.call(['which', 'locate'])` no `CatfishSearchEngine.py` logo na importação para detectar a presença do comando `locate`.
  - Em sistemas mínimos onde `which` não existe nativamente, o Catfish quebrava imediatamente na inicialização com `FileNotFoundError: [Errno 2] No such file or directory: 'which'`.
  - Aplicado override no overlay `modifiedPackages` em `overlays/default.nix`, injetando `which`, `findutils` e `file` no `PATH` via `gappsWrapperArgs`.
- **Noctalia Shell — Localização e Clima Declarativos (`[location]` e `[weather]`)**:
  - A aba/widget de previsão do tempo do Noctalia v5 dependem das seções `[location]` e `[weather]` no `config.toml`. A ausência dessas seções, combinada a um arquivo de cache antigo em `~/.cache/noctalia/location.json` (do v4, onde a latitude era string e causava erro de parsing no C++), resultava em "No location set".
  - Configurado declarativamente em `modules/home-manager/desktop/display-servers/wayland/noctalia/default.nix` com `auto_locate = true`, coordenadas de São Paulo (`latitude = -23.6293`, `longitude = -46.6351`), `address = "São Paulo, Brazil"` e `[weather]` (`enabled = true`, `effects = true`, `refresh_minutes = 30`, `unit = "metric"`). O cache antigo foi limpo e os dados meteorológicos da Open-Meteo foram carregados com sucesso.
- **MPV & Suporte a Vídeos via SMB / Samba (`gvfs-smb.lua` e `gvfs-fuse.service`)**:
  - **Causa do Erro**: Ao tentar abrir uma URL `smb://` no MPV (`No protocol handler found to open URL ... The protocol is either unsupported, or was disabled at compile-time`), o carregamento falha porque o `ffmpeg` no Nixpkgs é compilado por omissão sem `libsmbclient` (`--disable-libsmbclient`). Além disso, ao passar uma URL terminada em barra (`/.../`), trata-se de um diretório remoto e não de um arquivo de vídeo direto.
  - **Daemon FUSE do GVfs (`systemd.user.services.gvfs-fuse`) e Wrapper `fusermount3`**:
    - Supervisiona `${pkgs.gvfs}/libexec/gvfsd-fuse -f %t/gvfs`, expondo compartilhamentos montados pelo GVfs em `/run/user/<uid>/gvfs/smb-share:server=...,share=.../` de forma persistente.
    - **Requisito em distros standalone (Debian)**: O `libfuse3` compilado pelo Nixpkgs busca o utilitário setuid em `/run/wrappers/bin/fusermount3`. Em sistemas standalone sem esse wrapper, o `gvfsd-fuse` falha ou deixa `/run/user/<uid>/gvfs` em estado desconectado (`Transport endpoint is not connected`). Requer symlink `/run/wrappers/bin/fusermount3 -> /usr/bin/fusermount3` mantido via `/etc/tmpfiles.d/nix-wrappers.conf`, além de `Environment = [ "PATH=/run/wrappers/bin:${pkgs.fuse3}/bin:/usr/bin:/bin" ]` e comandos de unmount seguros (`fusermount3 -u -z`) no `ExecStartPre` / `ExecStop`.
  - **Hook Lua no MPV (`gvfs-smb.lua`)**: Intercepta URLs `smb://`, realiza varredura dinâmica no diretório `/run/user/<uid>/gvfs/` para localizar o compartilhamento mesmo quando o GVfs inclui sufixos (`user=...`, variações de maiúsculas/minúsculas), e mapeia para o caminho FUSE local antes de entregar o fluxo ao MPV. Se o compartilhamento ainda não estiver montado, invoca automaticamente `gio mount --anonymous`.
  - **MIMEs de Vídeo e Áudio**: Mapeados declarativamente em `xdg.mimeApps.defaultApplications` no módulo `mpv/default.nix` (`video/mp4`, `video/x-matroska`, `video/mkv`, `video/webm`, etc.), garantindo que o Thunar direcione o clique duplo sempre ao `mpv.desktop`.
  - **Correção em Regras de `systemd.user.tmpfiles.rules`**: Substituído `${username} users` por `- - - -` em regras de usuário no Home Manager (`users/default.nix`, `users/juca/default.nix` e `mpv/default.nix`). Usuários não-root em distribuições standalone não possuem permissão (`CAP_CHOWN`) para alterar o grupo de arquivos para `users`, o que causava falha de ativação no `systemd-tmpfiles-setup` com `fchownat() failed: Operation not permitted`.

- **Polkit & Thunar — Resolução de Conflito de `pkexec` e Suporte Wayland (`admin://`)**:
  - **Problema de Binário SUID**: A presença de `pkgs.polkit` em `home.packages` instalava `~/.nix-profile/bin/pkexec` sem bit SUID (limitação de segurança do Nix Store `nosuid`), que sobrepunha o `/usr/bin/pkexec` nativo do host no `$PATH` e falhava com `pkexec must be setuid root`.
  - **Correção**: Removido `pkgs.polkit` de `home.packages` em `thunar/default.nix`, restaurando a resolução direta para `/usr/bin/pkexec` (`-rwsr-xr-x`).
  - **Ação "Abrir como root" no Thunar (Wayland)**: Atualizada a custom action para invocar `${thunar-wrapped}/bin/thunar admin://%f`. O protocolo `admin://` do GVfs delega operações de arquivos privilegiadas ao `gvfsd-admin` com autenticação Polkit nativa, eliminando a tentativa insegura e bloqueada pelo Wayland de rodar um processo gráfico GTK diretamente como root.
  - **Modelos do Thunar (`XDG_TEMPLATES_DIR`)**: Provisionados modelos declarativos em `~/.local/share/templates` (`Documento de Texto.txt` e `Arquivo Vazio`) e symlink `~/Templates`, garantindo que o submenu de clique direito "Criar documento" esteja sempre disponível em qualquer pasta (local ou compartilhamento de rede).

- **VA-API no Intel HD 3000 / Sandy Bridge (Wayland vs DRM Backend)**:
  - **Incompatibilidade do `vainfo` com Wayland Puro**: O driver `i965` (`intel-vaapi-driver`) para Sandy Bridge depende do protocolo legado `wl_drm` para inicialização na interface Wayland. Como compositores Wayland modernos (MangoWM, Hyprland) adotam exclusivamente `linux-dmabuf` e omitem `wl_drm`, rodar `vainfo` sem argumentos resultava em `init failed` (-1).
  - **Decodificação por Hardware Intacta**: A aceleração por hardware funciona plenamente via DRM direto (`/dev/dri/renderD128`) e EGL DMA-BUF, que é a arquitetura utilizada nativamente por players como o MPV (`hwdec=vaapi` + `vo=gpu`).
  - **Alias Declarativo**: Configurado `vainfo = "vainfo --display drm"` nos aliases de shell (`modules/home-manager/desktop/display-servers/wayland/default.nix` e `modules/home-manager/system/programs/shells/default.nix`), garantindo que o comando `vainfo` reporte imediatamente os codecs acelerados por hardware no terminal.

- **Noctalia Shell & MangoWM/Hyprland — Window Switcher, Bloqueio de Sessão, Suspensão, Screenshots e Controles de Sistema**:
  - **Window Switcher (Alt+Tab Overlay)**:
    - O Noctalia v5 possui um overlay nativo de troca de janelas acionado via IPC (`noctalia msg window-switcher`).
    - Configurado nos compositores Wayland (`mangowm` e `hyprland`): `Alt+Tab` e `Alt+Shift+Tab` invocam diretamente o `noctalia msg window-switcher`, exibindo uma grade centralizada e translúcida das janelas abertas com navegação fluida por teclado (Tab, setas, Enter, Escape) e mouse.
  - **Bloqueio de Sessão (Session Lock) e Suspensão (Suspend)**:
    - **Lock**: Mapeado `Super + L` para `noctalia msg session lock`. Em hardwares Apple (MacBook), mapeado também o atalho nativo do macOS `Super + Ctrl + Q` (`Ctrl + Cmd + Q`). O Noctalia gerencia a tela de bloqueio com autenticação PAM contra a stack `login` (integrada a `/run/wrappers/bin/unix_chkpwd`).
    - **Suspend**: Mapeado `Super + Alt + S` e a tecla `XF86Sleep` para `noctalia msg session suspend` (ou `systemctl suspend` em shells tradicionais).
  - **Captura de Tela (Screenshots) com Detecção Inteligente de Hardware Apple**:
    - Implementada detecção condicional de hardware: `isApple = (config.home.keyboard.model or "") == "apple" || hostname == "anubis" || hostname == "rocinante"`.
    - **No Hardware Apple (MacBook Air / MacBook Pro)**:
      - Como teclados Mac não possuem a tecla física `Print Screen`, foram mapeados os atalhos clássicos do macOS:
        - `Cmd + Shift + 3` (`Super + Shift + 3`): Captura a tela inteira (`noctalia msg screenshot-fullscreen`).
        - `Cmd + Shift + 4` (`Super + Shift + 4`): Captura uma região selecionada interativamente (`noctalia msg screenshot-region`).
        - `Cmd + Shift + 5` (`Super + Shift + 5`): Abre o menu/picker de captura (`noctalia msg screenshot-fullscreen pick`).
      - Para evitar conflitos com o envio de janelas para as tags 3, 4 e 5 no tiling manager, o envio de janelas para qualquer tag/workspace (1 a 9/10) foi mapeado também para `Super + Ctrl + <número>`, mantendo o controle total dos workspaces.
      - Mantidos `Print` e `Shift + Print` como fallbacks adicionais para o caso de teclados externos USB conectados ao Mac.
    - **Em PCs Padrão**:
      - `Print`: Tela inteira (`screenshot-fullscreen`).
      - `Shift + Print` e `Super + Shift + S`: Região (`screenshot-region`).
    - **Configuração TOML (`[shell.screenshot]`)**: Definido `save_to_file = true`, `copy_to_clipboard = true`, `freeze_screen = true` e diretório padrão em `~/Pictures/Screenshots`.
  - **Night Light (Luz Noturna) e Caffeine (Inibidor de Inatividade)**:
    - **Night Light**:
      - Seção declarativa `[nightlight]` configurada no `config.toml` (`temperature_day = 6500`, `temperature_night = 4000`), controlando a temperatura de cor via protocolo Wayland `wlr-gamma-control`.
      - Adicionado widget `"nightlight"` na barra superior (`bar.default.end`) e no Control Center.
      - Atalhos: `Super + Shift + N` para alternar o modo agendado (`noctalia msg nightlight-toggle`) e `Super + Ctrl + Shift + N` para forçar o modo noturno imediato (`noctalia msg nightlight-force-toggle`).
    - **Caffeine**:
      - Adicionado widget `"caffeine"` na barra superior (`bar.default.end`) e no Control Center, inibindo suspensão e bloqueio via protocolo `zwp_idle_inhibit_manager_v1`.
      - Atalho: `Super + Shift + C` para alternar o inibidor de inatividade (`noctalia msg caffeine-toggle`).
    - Ambos contam com feedback visual imediato na tela pelo serviço de OSD do Noctalia (`[osd.kinds] nightlight = true`, `caffeine = true`).
- **Wayland — Detecção de Desktop Managers Completos (`fullDesktopManagers`)**:
  - Em `modules/home-manager/desktop/display-servers/wayland/default.nix`, adicionada lista declarativa de DEs completos (`gnome`, `kde`, `plasma`, `pantheon`, `cosmic`, `cinnamon`, `mate`, `lxqt`, `xfce`, `xfce4`) com a flag `isFullDesktopManager = lib.elem desktop fullDesktopManagers;`.
  - Quando um DE completo está ativo, `options.desktop.wayland.shell` recebe `default = null` (tipo ampliado para `nullOr (enum [ "traditional" "noctalia" "none" ])`), prevenindo a inicialização acidental de sub-shells standalone (Waybar, Dunst, Rofi, Hypridle, Noctalia) que conflitariam com os painéis e daemons nativos do DE.
  - `WLR_NO_HARDWARE_CURSORS` e `services.gnome-keyring.enable` foram tornados condicionais a `!isFullDesktopManager`, evitando variáveis exclusivas de wlroots em Mutter/KWin e daemons de keyring redundantes.

- **Módulo Genérico de Monitores e Resoluções (`desktop.monitors`)**:
  - **Arquitetura Unificada**: Criado o módulo `modules/home-manager/desktop/monitors/default.nix`, importado em `modules/home-manager/desktop/environments/default.nix`. Permite que qualquer host configure suas telas declarativamente em `home-manager/hosts/<host>/default.nix` sob `desktop.monitors = [ { name = "..."; width = ...; height = ...; refresh = ...; primary = true; } ]`.
  - **Suporte Multi-Ambiente (DEs Completos e Window Managers)**:
    - **MangoWM (Wayland)**: Gera automaticamente regras `monitorrule=name:<name>,width:<w>,height:<h>,refresh:<r>,x:<x>,y:<y>,scale:<s>` no `~/.config/mango/config.conf` a partir de `desktop.mangowm.monitorRules`.
    - **Hyprland (Wayland)**: Alimenta declarativamente `desktop.hyprland.monitors` (`<name>, <w>x<h>@<r>, <x>x<y>, <s>`).
    - **Kanshi Daemon (Wayland)**: Provisiona serviço systemd de usuário e perfis dinâmicos em `services.kanshi` para saídas hotplug.
    - **X11 (BSPWM, XFCE4, etc.)**: Injeta comandos `xrandr --output <name> --mode <w>x<h> --rate <r> --pos <x>x<y> --primary` diretamente no `xsession.initExtra` e empacota `pkgs.xrandr`.
    - **Desktop Environments Completos (GNOME, KDE, XFCE4)**: Gera arquivo de inicialização de sessão `~/.config/autostart/setup-monitors.desktop` invocando o script universal `setup-monitors`.
    - **Script Universal `setup-monitors`**: Utilitário disponível no PATH (`home.packages`) que detecta o ambiente ativo (`WAYLAND_DISPLAY` via `wlr-randr` ou `DISPLAY` via `xrandr`) e reaplica as resoluções e orientações sob demanda.
  - **Otimização de Renderização de Fontes (`desktop.monitorsFontRendering`)**:
    - Ativado por padrão (`enable = true`).
    - Configura `fonts.fontconfig`: antialiasing ativo, hinting leve (`slight`) e renderização de subpixels (`subpixelRendering = "rgb"` via `10-hm-rendering.conf`).
    - Configura `dconf /org/gnome/desktop/interface`: `font-antialiasing = "rgba"`, `font-hinting = "slight"` e `font-rgba-order = "rgb"`, garantindo máxima nitidez tipográfica em telas de 135 DPI como a do MacBook Air 11.6".
  - **Hosts Adotados**:
    - `anubis`: Configurado com a resolução nativa do painel Apple Color LCD / LG Philips LP116WH4-TJA3 (`1366x768 @ 60Hz`, `eDP-1`).
    - `rocinante-hyperv`: Migrado do script manual do `xsession.initExtra` para o módulo declarativo (`1600x900 @ 60Hz`, `Virtual-1`).
- **Diagnóstico de Boot, Bloqueio, Suspensão e Hibernação no Host `anubis` (Fedora Standalone)**:
  - **Audit de Boot e Serviços**: 0 serviços falhados no systemd do sistema e do usuário (`systemctl --failed`). Logs do journalctl limpos de falhas críticas.
  - **Lock e Suspend**:
    - **Lock**: Integrado via Noctalia Shell (`noctalia msg session lock` via `ext-session-lock-v1` + PAM `login` + wrapper `/run/wrappers/bin/unix_chkpwd -> /usr/sbin/unix_chkpwd`).
    - **Suspend**: ACPI S3 profundo (`s2idle [deep]`) funcional nativamente no kernel e com suporte ao fechamento da tampa do MacBook Air (`HandleLidSwitch=suspend`).
  - **Configuração e Ativação de Hibernação (S4 / Hibernate to Disk)**:
    - **Arquitetura de Swap Híbrida**: `/dev/zram0` (1.8G, prioridade 100) para swap diário ultrarrápido em RAM, preservando o SSD; partição física `/dev/sda4` (5G, prioridade -1, UUID `ded62059-8b28-48a8-a251-38a7c3a7c26f`) dedicada como alvo de despejo de memória da hibernação.
    - **Dracut & Initramfs**: Criado `/etc/dracut.conf.d/resume.conf` com módulo `resume`, incorporando `systemd-hibernate-resume` e gerador no initramfs via `dracut -f`.
    - **Parâmetros do Kernel & GRUB**: Injetado `resume=UUID=ded62059-8b28-48a8-a251-38a7c3a7c26f` no `/etc/default/grub` e propagado para as entradas de kernel via `grubby --update-kernel=ALL`.
- **Avatar Universal de Usuário nos Display Managers (GDM, SDDM, LightDM, ReGreet)**:
  - **Módulo NixOS Central (`modules/nixos/desktop/display-managers/default.nix`)**:
    - Quando qualquer Display Manager é ativado (`cfg.name != null` ou `enable = true`), o módulo habilita automaticamente o `services.accounts-daemon.enable = true` e inclui `pkgs.juca-avatar` em `environment.systemPackages`.
    - Provisiona declarativamente o avatar no **AccountsService** via `systemd.tmpfiles.rules`: linka `/var/lib/AccountsService/icons/${username}` para `${pkgs.juca-avatar}/share/faces/juca.jpg` e inicializa `/var/lib/AccountsService/users/${username}` com `Icon=/var/lib/AccountsService/icons/${username}`. Isso garante a exibição do avatar no **GDM**, **ReGreet** e **LightDM** de forma transparente e segura (sem depender de permissões na home).
  - **Home Manager (`home-manager/users/juca/default.nix` e `nixos/default.nix`)**:
    - Expostos declarativamente ambos os arquivos na home do usuário: `~/.face` (JPEG) e `~/.face.icon` (PNG a partir de `${pkgs.juca-avatar}/share/sddm/faces/juca.face.icon`).
    - Permite que o **SDDM** (e scripts de ativação com `setfacl`) encontrem o arquivo PNG com permissão de leitura correta.
- **Noctalia Shell — Gestão de Ociosidade (Idle / `ext_idle_notifier_v1`)**:
  - **Estrutura e Schema Declarativo (`[idle]`)**: O Noctalia v5 implementa nativamente o protocolo Wayland `ext_idle_notifier_v1` via `IdleManager`. As diretivas devem residir sob `[idle.behavior.<nome>]` (e **nunca** com erros de grafia como `bahavior`), com lista de prioridade `behavior_order = [ ... ]` e tempo de esmaecimento `pre_action_fade_seconds`.
  - **Ações Nativas Suportadas**:
    - `"lock"`: Dispara tela de bloqueio nativa via `ext-session-lock-v1`.
    - `"screen_off"`: Desliga displays via backend do compositor (`compositors::mango::setOutputPower`).
    - `"suspend"`: Dispara suspensão via `logind` (com suporte opcional a `lock_before_suspend = true`).
  - **Correção de Flickering / Liga-Desliga Preto no Host `anubis` (Intel HD 3000 / Sandy Bridge)**:
    - **Causa**: O `pre_action_fade_seconds = 30.0` forçava animação contínua de transparência em overlay, e a ação `screen_off` via DPMS do compositor disparava erro no driver `i915` (`connector eDP-1: Atomic commit failed: Device or resource busy`), fazendo o driver reacender a tela repetidamente em loop. Além disso, a ação `custom` com `notify-send` acordava a sessão no exato momento em que entrava em repouso.
    - **Solução**: `pre_action_fade_seconds = 0.0`, remoção do `custom` de notificação, e migração do `screen-off` para controle direto do backlight por hardware via `brightnessctl` (`brightnessctl -s set 0%` com restauração transparente em `resume_command = "brightnessctl -r"`), eliminando a falha no DRM e apagando a tela sem ciclos de piscar.

- **Polybar — Módulo Genérico de Teclado & Customização por Host**:
  - **Módulo Compartilhado (`modules.nix` & `scripts.nix`)**: Criado `module/keyboard` de tipo `internal/xkeyboard` totalmente genérico. Alternância rápida de layout ao clicar com botão esquerdo (ação nativa C++ `#keyboard.switch`), menu Rofi dinâmico com botão direito (`rofiKeyboardMenu` via `xkb-switch -l`) sem nenhum layout ou idioma hardcoded no módulo, e valor padrão flexível `label-layout = lib.mkDefault "%layout%"`.
  - **BSPWM (`bspwm.nix`)**: Inicialização declarativa no `bspwmrc` executando `setxkbmap` a partir de `config.home.keyboard` (`model`, `layout`, `variant`, `options`), garantindo que distribuições não-NixOS apliquem o mapa de teclas correto no login.
  - **Host `nitro` (`home-manager/hosts/nitro/default.nix`)**: Configurado teclado com suporte aos layouts US Internacional e ABNT2 (`layout = "us,br"; variant = "intl,abnt2"; options = [ "grp:alt_shift_toggle" ];`) e customização visual na Polybar (`services.polybar.config."module/keyboard"` mapeando `layout-icon-0 = "us;INTL"`, `layout-icon-1 = "br;ABNT2"` e `label-layout = "%icon%"`).
- **Aceleração de Vídeo / VA-API no Host `nitro` (Debian Standalone - Intel UHD 630 / NVIDIA GTX 1050)**:
  - **Causa Raiz 1 (Variável Vazia)**: Em `modules/home-manager/desktop/display-servers/x11/default.nix`, a diretiva `LIBVA_DRIVER_NAME = if isNixOS then ... else "";` exportava uma string vazia `""` na sessão de distribuições não-NixOS. A biblioteca `libva` interpretava a string vazia como solicitação explícita do driver `_drv_video.so` (`User environment variable requested driver ''`), abortando o auto-detect de drivers com erro `vaInitialize failed with error code -1`.
  - **Causa Raiz 2 (Ordem de Detecção em Laptops Híbridos Optimus)**: O script `x11-vars.sh` checava `vga.*nvidia` antes de `vga.*intel`. Em notebooks dual GPU onde a Intel gerencia a tela (`eDP-1`), o script injetava `LIBVA_DRIVER_NAME="nvidia"` e `__GLX_VENDOR_LIBRARY_NAME="nvidia"`, quebrando o VA-API e a renderização do Mesa/X11. Corrigida a prioridade para checar a GPU integrada Intel primeiro.
  - **Causa Raiz 3 (Alias Global Não-Genérico `vainfo --display drm`)**: No módulo compartilhado `modules/home-manager/system/programs/shells/default.nix`, existia o alias rígido `vainfo = "vainfo --display drm"`. Em sistemas dual-GPU Optimus, o modo DRM direto consulta `/dev/dri/card0` por padrão. No Nitro 5, `card0` é a NVIDIA e `card1` é a Intel (`renderD129`). Como `LIBVA_DRIVER_NAME="iHD"` instrui o uso do driver Intel, carregar `iHD` contra a GPU NVIDIA causava `unsupported drm device by media driver: nvid` e erro `vaInitialize failed with error code 18`.
  - **Causa Raiz 4 (Firmware DMC Ausente no Debian Trixie)**: No Debian 13 (Trixie), o firmware da GPU Intel foi separado no pacote `firmware-intel-graphics`. Sem ele, o kernel gerava aviso `Failed to load DMC firmware i915/kbl_dmc_ver1_04.bin (-ENOENT)` e desativava o gerenciamento de energia em repouso da iGPU.
  - **Solução Implementada**:
    - Removido o alias não-genérico `vainfo` do módulo compartilhado `shells/default.nix`.
    - No host `nitro`, adicionado script wrapper `vainfo-intel` e alias transparente: conecta nativamente via X11/Wayland quando `$DISPLAY` estiver presente, ou faz fallback automático apontando para o render node da Intel (`/dev/dri/by-path/pci-0000:00:02.0-render` / `renderD129`) quando executado em TTY/headless.
    - Instalados `firmware-intel-graphics`, `firmware-intel-misc`, `firmware-intel-sound` e `firmware-sof-signed` no sistema e nos scripts de instalação (`nitro-dual-debian.sh` e `fix-debian.sh`).
    - Validados 100% dos perfis de aceleração por hardware (H.264, HEVC 8/10-bit, VP9, MPEG2, JPEG).
- **Rede Wi-Fi (Intel AC 9560 / iWD / NetworkManager) no Host `nitro` (Debian Standalone)**:
  - **Causa Raiz 1 (Pacote iWD Ausente)**: O script `nitro-dual-debian.sh` configurava `/etc/NetworkManager/conf.d/wifi_backend.conf` com `wifi.backend=iwd`, mas o pacote `iwd` estava comentado na linha de instalação (`apt install network-manager rfkill`), e `wpasupplicant` também não estava instalado. Sem um backend sem fio ativo no D-Bus, o NetworkManager marcava a placa `wlp0s20f3` em estado `unavailable`.
  - **Causa Raiz 2 (Conflito de Configuração de IP no iWD)**: O arquivo `/etc/iwd/main.conf` continha `EnableNetworkConfiguration=true`. Ao usar o iWD como backend do NetworkManager, essa opção deve ser estritamente `false`, pois o NetworkManager deve ser o único responsável pelo DHCP e DNS.
  - **Causa Raiz 3 (Conflito com systemd-networkd)**: O `systemd-networkd.service` estava habilitado e concorrendo com o NetworkManager pelo gerenciamento de links. Desativado e mascarado o socket em favor do NetworkManager.
  - **Causa Raiz 4 (Serviço Destrutivo `iwlwifi-reload.service` no Boot)**:
    - O script `nitro-dual-debian.sh` criava e habilitava um serviço `/etc/systemd/system/iwlwifi-reload.service` que executava `/sbin/modprobe -r iwlwifi && /sbin/modprobe iwlwifi` após o `network.target`.
    - Ao descarregar o módulo do kernel durante a inicialização com o `iwd` e o `NetworkManager` já em execução, a interface `wlan0` era destruída por baixo do daemon, invalidando os descritores netlink do `iwd` e deixando a placa permanentemente em estado `unavailable`.
    - Além disso, o `NetworkManager.service` não possuía dependência explícita de inicialização após o `iwd.service`.
  - **Correções Aplicadas nos Scripts**:
    - `nitro-dual-debian.sh`: Descomentado `firmware-iwlwifi`, adicionados `iwd` e `wireless-regdb` ao `apt install`, corrigido `EnableNetworkConfiguration=false` no `main.conf`, desativado `systemd-networkd`, removido o bloco `iwlwifi-reload.service`, e adicionado drop-in `/etc/systemd/system/NetworkManager.service.d/iwd.conf` com `After=iwd.service Wants=iwd.service`.
    - `fix-debian.sh`: Adicionados `iwd` e `wireless-regdb`, provisionamento declarativo do backend iwd e serviço habilitado, desativação/remoção de qualquer `iwlwifi-reload.service` existente e injeção do drop-in de dependência no NetworkManager.
    - Sistema ao vivo: `iwlwifi-reload.service` desativado e removido, drop-in `NetworkManager.service.d/iwd.conf` criado, pilha de rede validada e Wi-Fi reconectando automaticamente no boot.

- **zRAM, Otimizações de I/O Btrfs e Partições no Host `nitro` (Debian Standalone)**:
  - **Instalação e Configuração do zRAM**:
    - O zRAM não estava instalado nem configurado no script original `nitro-dual-debian.sh`.
    - Instalado `systemd-zram-generator` e configurado `/etc/systemd/zram-generator.conf` com dispositivo `zram0`, tamanho `min(ram / 2, 8192)` (8 GB), algoritmo `zstd` e prioridade 100.
    - Otimização do kernel via `/etc/sysctl.d/99-zram.conf`: `vm.swappiness = 100` e `vm.page-cluster = 0` (elimina leitura sequencial desnecessária para swap em RAM).
    - Topologia híbrida de Swap: `/dev/zram0` com prioridade 100 (RAM rápida com compressão) e `/var/swap/swapfile` (16 GB Btrfs) com prioridade 10 (disco de segurança em NVMe).
  - **Otimização de Compressão Btrfs**:
    - Flags legadas `compress-force=zstd:14` e `15` causavam travamentos e sobrecarga severa de CPU durante compilações e atualizações de pacotes.
    - Unificadas para `compress=zstd:3` (sistema/snapshots/opt) e `compress=zstd:1` (throughput em home/nix/dados), eliminando lentidão no NVMe.
    - Dracut: otimizado de `compress="zstd --ultra -14"` para `compress="zstd -3"`, reduzindo o tempo de geração de initramfs de minutos para segundos.
  - **Partição SharedData e Integridade do Nix Multi-usuário**:
    - Adicionada montagem persistente da partição exFAT `SharedData` no fstab (`LABEL=SharedData` / `UUID=FBF7-F8A5`).
    - Corrigidas permissões do Nix daemon (`root:root 0755` nas árvores `/nix/var/nix`) e `SocketMode=0666`, eliminando falha de `unsafe path transition` do `systemd-tmpfiles-setup.service`.
    - Mascarado `systemd-networkd-wait-online.service` para evitar atrasos de boot na rede.
- **BSPWM — Topologia de Monitores e Distribuição de Workspaces (Host `nitro`)**:
  - **Prioridade de Monitor**: Em `home-manager/hosts/nitro/default.nix`, as saídas HDMI externas (`HDMI-1-0` e `HDMI-1-1`) foram configuradas com `primary = true` e a tela interna do notebook (`eDP-1`) como `primary = false`. No módulo `modules/home-manager/desktop/monitors/default.nix`, foi adicionado fallback automático em `setup-monitors` e `xsession.initExtra` garantindo que se a tela externa for desconectada, a primeira saída ativa (`eDP-1`) é automaticamente promovida a primária na posição `0x0`.
  - **Distribuição de Workspaces (Ímpares no Principal, Pares no Secundário)**:
    - Em setup multi-monitor no `bspwm.nix`, os monitores são reordenados via `bspc wm -O` colocando o monitor primário como primeiro.
    - Monitor Principal: recebe os workspaces ímpares `1 3 5 7 9`.
    - Monitor Secundário: recebe os workspaces pares `2 4 6 8 0` (onde 0 equivale à 10ª workspace).
    - Em setup de monitor único (laptop desconectado): recebe todos os workspaces em sequência `1 2 3 4 5 6 7 8 9 0`.
  - **Polybar (`pin-workspaces = true`)**: A barra no monitor principal renderiza exclusivamente os pills `1 3 5 7 9`, e a barra no secundário renderiza exclusivamente os pills `2 4 6 8 0`.
  - **Atalhos SXHKD (`sxhkd.nix`)**:
    - O comando `bspc desktop -f '^{1-9,10}'` endereçava por índice numérico global de desktops. Com a divisão ímpar/par, o desktop `^2` correspondia ao 2º desktop do primeiro monitor (`3`), impedindo o foco no monitor secundário.
    - Corrigido para endereçamento direto por nome: `bspc desktop -f '{1-9,0}'` e `bspc node -d '{1-9,0}'`. Pressionar `Super + 2, 4, 6, 8, 0` alterna instantaneamente o foco e cursor para o workspace no monitor secundário, e `Super + 1, 3, 5, 7, 9` para o principal.

- **SSH & Git — Chave `~/.ssh/nitro` e Módulo de Serviços**:
  - **Módulo de Serviços (`modules/home-manager/system/services/`)**:
    - Reativado o import `./git` em `services/default.nix`.
    - Modernizado `services/git/default.nix` (removido `mdDoc`).
    - Adicionadas opções `signingKey` (padrão `"~/.ssh/nitro.pub"`), `signByDefault` (padrão `true`) e `signingFormat` (`"ssh"`).
    - Configurado `programs.git.signing` com `format = "ssh"`, ativando assinatura criptográfica automática de commits e tags (`commit.gpgsign = true`, `tag.gpgsign = true`) utilizando a chave SSH `~/.ssh/nitro.pub`.
    - No módulo `services/ssh/default.nix`, adicionada a opção `system.services.ssh.identityFiles` configurada por padrão com `[ "~/.ssh/nitro" "~/.ssh/id_ed25519" "~/.ssh/id_rsa" ]`.
    - Isso injeta automaticamente a chave privada `~/.ssh/nitro` no bloco `Host *` do `~/.config/ssh/config`, permitindo autenticação transparente via SSH para Git, GitHub, GitLab e conexões remotas.
- **Tema de Cursor Catppuccin Mocha no BSPWM, X11 e Wayland (`bspwm/default.nix`, `bspwm.nix`)**:
  - **Causa Raiz 1 (Case Mismatch)**: O pacote `pkgs.catppuccin-cursors.mochaDark` gera o diretório em caixa baixa: `catppuccin-mocha-dark-cursors`. Nos módulos de desktop (`bspwm`, `xfce4`, `hyprland`, `mangowm`), estava declarado em CamelCase (`Catppuccin-Mocha-Dark-Cursors`). No Linux, a busca por temas de cursor é sensível a maiúsculas/minúsculas, impedindo que GTK, Qt e X11 localizassem os cursores e caindo no cursor padrão do X11 (cruz preta) ou Adwaita.
  - **Causa Raiz 2 (Ausência de Symlinks e Variáveis X11)**: Em ambientes standalone, o Home Manager não criava os links simbólicos em `~/.icons` e `~/.local/share/icons`, nem exportava `XCURSOR_THEME`/`XCURSOR_SIZE` nem definia `xresources.properties` (`Xcursor.theme`, `Xcursor.size`).
  - **Causa Raiz 3 (Reset do cursor no `xsetroot`)**: No `bspwmrc`, `xsetroot -solid '#1e1e2e'` rodava após `xsetroot -cursor_name left_ptr`, o que no protocolo X11 reseta o cursor da janela raiz de volta para a cruz padrão ("X").
  - **Correção**:
    - Unificado o nome em todos os ambientes para `catppuccin-mocha-dark-cursors` (com symlinks retrocompatíveis em `~/.icons` e `~/.local/share/icons` para ambas as grafias e `~/.icons/default/index.theme`).
    - Declarado `xresources.properties` (`Xcursor.theme`, `Xcursor.size`), adicionado `pkgs.xorg.xrdb` em `packages.nix` e exportado `XCURSOR_THEME`/`XCURSOR_SIZE` nas variáveis de sessão e no `systemctl --user import-environment`.
    - No `bspwmrc`, adicionado `[ -f "$HOME/.Xresources" ] && xrdb -merge "$HOME/.Xresources"` e unificado `xsetroot -solid '#1e1e2e' -cursor_name left_ptr &`.

- **Bash — Autocompletion, Autosuggestions e Predição de Histórico Estilo Fish/Zsh (`bash/default.nix`)**:
  - **Bash Line Editor (`pkgs.blesh`)**: Adicionada opção `system.programs.shells.bash.blesh.enable` (padrão `true`). O `ble.sh` traz ao Bash recursos nativos que antes só existiam no Fish ou Zsh:
    - **Predição de Histórico (Ghost Text)**: Sugere comandos completos anteriores à medida que o usuário digita (`complete_auto_history=1`, latência de 50ms), aceitos com `Seta Direita` ou `End`.
    - **Menu de Completude Interativo**: Tab abre menu de completude navegável por setas/Tab com filtragem em tempo real (`complete_auto_menu=1`, `complete_menu_complete=1`, `complete_menu_filter=1`).
    - **Syntax Highlighting em Tempo Real**: Destaca comandos válidos, argumentos, erros de sintaxe e caminhos existentes de arquivos/diretórios em tempo real (`highlight_syntax=1`, `highlight_filename=1`).
  - **Integração sem Conflitos com Starship**:
    - O Starship injeta seu hook no `initExtra` com prioridade `mkOrder 1200`.
    - Para evitar quebras e flickering, o `ble.sh` é pré-carregado no início com `source ble.sh --attach=none` (`mkOrder 500`), permitindo que scripts e o Starship inicializem normalmente, e é acoplado ao final via `ble-attach` (`mkOrder 2000`).
  - **Fallback Robusto do Readline**:
    - Caso uma sessão não suporte `ble.sh` (ou em terminais legados), foram configurados `history-search-backward` e `history-search-forward` nas setas Cima/Baixo (busca no histórico filtrando pelo prefixo já digitado) e `menu-complete` no Tab.

- **Shells e Alacritty — Integração Dinâmica e Fix do Zsh (`zsh/default.nix` e `alacritty/default.nix`)**:
  - **Zsh `dotDir`**: Substituído `$HOME/.config/zsh` por `"${config.xdg.configHome}/zsh"`, atendendo às asserções do Home Manager moderno sem emitir avisos de caminhos relativos ou variáveis não avaliadas em tempo de build. Corrigido typo em `bindkey '^p' history-search-backward`.
  - **Alacritty Shell Automático**: Configurado `programs.alacritty.settings.terminal.shell.program` apontando dinamicamente para o binário do shell ativo em `system.programs.shells.default` (`zsh`, `fish` ou `bash`). Isso garante que o Alacritty abra imediatamente o shell correto, mesmo que o display manager ou a sessão X11/BSPWM em andamento ainda possua `SHELL=/bin/bash` herdado no ambiente antes do logoff.

- **Suporte ao Nushell (`shells/nushell/default.nix`)**:
  - **Módulo Dedicado**: Adicionado suporte ao Nushell via `programs.nushell` quando `system.programs.shells.default` for `"nu"` ou `"nushell"`.
  - **Customizações Declarativas**: Tabelas estilizadas em modo arredondado (`rounded`), banner padrão desativado (`show_banner = false`), autocompletion fuzzy insensível a maiúsculas/minúsculas, histórico sincronizado de até 100k entradas e banner `nitch` na inicialização interativa.
  - **Integração Total**: Conectado ao Starship prompt (`enableNushellIntegration = true`), Direnv (`enableNushellIntegration = true`), Eza (`enableNushellIntegration = true`) e Alacritty (`terminal.shell.program = "${pkgs.nushell}/bin/nu"`).

- **Janelas Flutuantes para Scrcpy em Todos os WMs (`bspwm`, `hyprland`, `mangowm`)**:
  - **Identificadores Suportados**: Adicionado suporte abrangente a qualquer variante de nome de classe, app_id e wrappers do Nix/Linux (`scrcpy`, `Scrcpy`, `.scrcpywrap`, `scrcpy-wrapped`, `.scrcpy-wrapped` e wildcards `*scrcpy*`).
  - **BSPWM**: Regras adicionadas em `services.bspwm.rules`, comandos `bspc rule -a` e interceptadas no `externalRulesScript` (`*scrcpy*|*Scrcpy*` em `$class` e `$instance`).
  - **Hyprland**: Regras atualizadas com expressões regulares `match:class ^(.*[sS]crcpy.*)$` e `match:initialTitle ^(.*[sS]crcpy.*)$` para `float 1` e `center 1`.
  - **MangoWM**: Declaradas regras `windowrule=isfloating:1,appid:.*[sS]crcpy.*`, `appid:.scrcpywrap`, `appid:scrcpy-wrapped` e `title:.*[sS]crcpy.*`.

- **Módulo Discord com Vencord, OpenASAR e Temas Customizados (`chat/discord/default.nix`)**:
  - **Opção Central**: `system.programs.chat.discord.enable` com seleção de cliente via `client` (`"discord"`, `"vesktop"` ou `"both"`).
  - **Otimizações**: `openasar.enable = true` (substitui o app.asar para boot mais rápido e menor consumo de RAM) e `vencord.enable = true` (injeta Vencord para plugins e áudio no compartilhamento de tela em Linux).
  - **Temas Disponíveis**: `theme.scheme` com suporte a `"catppuccin-frappe"` (padrão), `"catppuccin-mocha"`, `"doom"` (Doom One Dark com as cores exatas da paleta) e `"dracula"` (paleta Dracula oficial).
  - **Deploy Automático**: Gera todos os arquivos `.theme.css` em `~/.config/Vencord/themes/`, `~/.config/vesktop/themes/` e `~/.config/BetterDiscord/themes/`, aponta `current.theme.css` para o selecionado e inicializa o `settings.json` com o tema ativado e plugins essenciais habilitados (zoom de imagem, plataformas, duplo clique em canais de voz, etc.).

- **Suporte a Binários Nativos da Distro vs Compilação Nix (`useSystemPackage` / `installPackage`)**:
  - Em ambientes standalone (Debian, Fedora, etc.), o usuário pode optar por não instalar o binário via Nix/Home Manager e utilizar o binário nativo da distribuição (`/usr/bin/*`) com integração de drivers de vídeo nativos, aproveitando 100% das configurações, dotfiles, atalhos, scripts e temas gerenciados pelo Home Manager.
  - Implementadas as opções `installPackage = bool` (padrão `true`) e atalho `useSystemPackage = bool` (padrão `false`):
    - **MPV (`multimedia/mpv`)**:
      - Quando `useSystemPackage = true`, não inclui o pacote Nix no profile, mas implanta `~/.config/mpv/mpv.conf`, `input.conf`, regras de janela e copia os scripts comunitários (`modernz`, `memo`, `evafast`, `thumbfast`, `sponsorblock`) diretamente para `~/.config/mpv/scripts/`.
      - **Modo Universal / Compatibilidade Total (`!shouldInstall`)**: O `[hw-preset]` detecta automaticamente quando o binário nativo da distro é utilizado e aplica um perfil universal seguro (`vo = gpu,x11`, `gpu-api = auto`, `hwdec = vaapi-copy,vaapi,no`, `video-sync = audio`), prevenindo deadlocks no driver Vulkan experimental do Intel Gen 9 e garantindo reprodução fluida.
      - **Estilização e Fontes do ModernZ**: Injetado `modernz-icons.ttf` em `~/.config/mpv/fonts/` diretamente do source do script, tipografia configurada com a fonte `Dubai` e paleta completa Catppuccin Mocha aplicada (Mauve `#cba6f7`, Lavender `#b4befe`, Crust `#11111b`, Text `#cdd6f4`), eliminando ícones quebrados e botões laranjas.
      - **Integração GLX/EGL e Dual GPU no Nitro 5 (`!isNixOS`) & `mpv-nvidia`**:
        - **NVIDIA (`mpv-nvidia`) & Dual GPU no Nitro 5 (`!isNixOS`)**:
          - O binário do MPV empacotado pelo Nix é compilado contra a glibc do Nixpkgs (2.42). Em distros standalone como o Debian (glibc 2.36), injetar `/usr/lib/x86_64-linux-gnu` diretamente em `LD_LIBRARY_PATH` expõe a `libc.so.6` do Debian para binários do Nix, causando conflito de símbolos e falhas (`GLIBC_2.42 not found` / Segmentation fault 139).
          - O Debian organiza as bibliotecas proprietárias da GPU NVIDIA em um diretório isolado: `/usr/lib/x86_64-linux-gnu/nvidia/current/` (contendo exclusivamente `libcuda.so.1`, `libnvcuvid.so.1`, `libGLX_nvidia.so.0`, sem nenhuma biblioteca C padrão do sistema).
          - O wrapper `mpv-nvidia` detecta automaticamente o binário do MPV (dando preferência ao do Nix quando instalado):
            - **Quando usa o MPV do Nix**: Injeta unicamente `/usr/lib/x86_64-linux-gnu/nvidia/current` em `LD_LIBRARY_PATH`, permitindo que o ffmpeg/MPV do Nix carregue `libnvcuvid.so.1` e execute aceleração por hardware direta via **NVDEC** (`hwdec=nvdec-copy`, `VO: [gpu] 1280x720 nv12`) com estabilidade absoluta e sem risco de conflito de glibc.
            - **Quando usa o MPV nativo (`/usr/bin/mpv`)**: Limpa as variáveis injetadas pelo Nix (`LIBVA_DRIVERS_PATH`, `LIBVA_DRIVER_NAME`, `LIBGL_DRIVERS_PATH`, `GBM_BACKENDS_PATH`, `__EGL_VENDOR_LIBRARY_FILENAMES`, `LD_LIBRARY_PATH`) para evitar erros de ABI (`__vaDriverInit_1_0`).
          - O script executa via PRIME Offload com `__NV_PRIME_RENDER_OFFLOAD=1` e `__VK_LAYER_NV_optimus=NVIDIA_only` utilizando o perfil dedicado `--profile=nvidia`.
    - **Discord (`chat/discord`)**: Quando `useSystemPackage = true`, não instala o binário Nix, mas gerencia todos os temas CSS (`catppuccin-frappe`, `doom`, `dracula`) e configurações do Vencord/BetterDiscord para o Discord nativo (.deb ou flatpak).
    - **yt-dlp (`tools/yt-dlp`)**: Quando `useSystemPackage = true`, gera `~/.config/yt-dlp/config` completo sem instalar o binário do Nix Store.

- **Deduplicação de Entradas Desktop no Rofi (Antigravity IDE & Alacritty)**:
  - **Antigravity IDE**:
    - O pacote upstream `pkgs.unstable.antigravity-ide` gera o arquivo `share/applications/antigravity-ide.desktop` no Nix Store (`~/.nix-profile/share/applications/antigravity-ide.desktop`).
    - O módulo `editors/antigravity` declarava `xdg.desktopEntries.antigravity`, gerando `~/.local/share/applications/antigravity.desktop`.
    - Como os nomes de arquivo eram divergentes (`antigravity.desktop` vs `antigravity-ide.desktop`), o Rofi não aplicava o mecanismo de *shadowing* do padrão XDG e exibia ambas as entradas como "Antigravity IDE".
    - Corrigido declarando `xdg.desktopEntries.antigravity-ide` (que substitui/sobrepõe perfeitamente o `.desktop` do Nix Store no escopo do usuário com as flags de CDP) e definindo `xdg.desktopEntries.antigravity = { settings.NoDisplay = "true"; }` para ocultar qualquer entrada legada remanescente.
  - **Alacritty**:
    - Padronizado o arquivo em `bspwm/packages.nix` como `Alacritty.desktop` (em maiúsculo, idêntico ao upstream) para sobrepor o `.desktop` do Nix Store e removido qualquer `alacritty.desktop` residual via hook de ativação.
- **Gerenciador de Arquivos Agnóstico, Nautilus, Nemo e PCManFM (`file-manager/`)**:
  - **Arquitetura Agnóstica nos WMs e Atalhos (`system.programs.file-manager`)**:
    - **Opções Centrais**: `system.programs.file-manager` atua como orquestrador central com `default` (`"auto"`, `"thunar"`, `"nautilus"`, `"nemo"`, `"pcmanfm"`), `activeCommand` (caminho do binário ativo), `activeName` (`"Nautilus"`, `"Nemo"`, `"PCManFM"` ou `"Thunar"`) e `activeDesktopFile` (associação no `xdg.mimeApps.defaultApplications."inode/directory"`).
    - **Despachante Agnóstico CLI (`file-manager`)**: Binário no PATH do usuário que detecta o gerenciador ativo (`nautilus`, `nemo`, `pcmanfm` ou `thunar`) e executa com `$TARGET`, com fallback para `xdg-open`.
    - **Teclas de Atalho Dinâmicas**: Todos os WMs (`hyprland`, `mangowm`, `bspwm`/`sxhkd`, `xfce4`) foram atualizados para invocar `${config.system.programs.file-manager.activeCommand}`:
      - **Hyprland**: `$mainMod, E` executa o comando ativo; regras flutuantes para `org.gnome.NautilusPreviewer` (Sushi) e `org.gnome.FileRoller`.
      - **BSPWM (`sxhkd`)**: `Super + E` e `Super + Shift + E` executam o comando ativo; manual de atalhos e menu Rofi Quick Settings exibem o nome dinâmico (`󰉋 Gerenciador de Arquivos (${fmName})`).
      - **MangoWM**: `SUPER + E` executa o comando ativo; regras flutuantes para `appid:thunar`, `appid:nemo`, `appid:pcmanfm`, `appid:org.gnome.NautilusPreviewer` e `appid:org.gnome.FileRoller`.
      - **XFCE4**: `<Super>e` e `<Super>f` executam o comando ativo.
      - **Polybar & Waybar**: Regex de detecção de ícones de janela configurada para `*thunar*|*nemo*|*pcmanfm*|*nautilus*)` exibindo o ícone de pasta (`󰉋` / `󰝰`).
    - **Módulos Desktop Flexíveis**: Ambientes utilizam `file-manager.thunar.enable = lib.mkDefault true;`. Qualquer host pode ativar outro gerenciador simplesmente definindo `file-manager.thunar.enable = false; file-manager.<nautilus|nemo|pcmanfm>.enable = true;` ou `file-manager.default = "<nome>";`.
  - **Módulos Disponíveis**:
    - **Nemo (`file-manager/nemo/default.nix`)**: Suporte a GVfs, extensões, configurações dconf e Nemo Actions (`open-terminal`, `open-vscode`, `open-antigravity`, `open-as-root`, `compare-meld`, `checksum`).
    - **PCManFM (`file-manager/pcmanfm/default.nix`)**: Gerenciador ultra-leve com suporte a GVfs, abas, dotfile declarativo `~/.config/pcmanfm/default/pcmanfm.conf` e thumbnails.
  - **Módulo Nautilus de Alta Performance (`file-manager/nautilus/default.nix`)**:
    - **Opções Padrão**: Suporte completo a `installPackage`, `useSystemPackage` (e `useSystemPackages`), `package`, `openAnyTerminal`, `sushi`, `defaultFileManager` e configurações de visualização (`view`).
    - **Wrapper com GVfs e Extensões (`nautilus-wrapped`)**:
      - Injeta `GIO_EXTRA_MODULES` (`${pkgs.gvfs}/lib/gio/modules:/usr/lib64/gio/modules:/usr/lib/gio/modules`) para suporte completo a Samba/SMB, SFTP, MTP, Lixeira e montagem de redes em distribuições standalone (Debian/Fedora).
      - Injeta `XDG_DATA_DIRS` com os schemas e metadados de `gvfs`, `gsettings-desktop-schemas`, `nautilus`, `sushi` e `nautilus-open-any-terminal`.
      - Injeta `NAUTILUS_4_EXTENSION_DIR` apontando para `${pkgs.nautilus-python}/lib/nautilus/extensions-4`.
    - **GNOME Sushi (`pkgs.sushi`)**: Pré-visualização rápida instantânea ao pressionar a Barra de Espaço para vídeos, áudios, imagens, documentos de escritório e PDFs.
    - **Open Any Terminal (`pkgs.nautilus-open-any-terminal`)**: Integração do terminal preferido (`alacritty` ou configurado) no menu de contexto e atalho `<Ctrl><Alt>T`.
    - **Suite de Thumbnailers**: `ffmpegthumbnailer` (vídeos), `webp-pixbuf-loader` (WebP), `poppler` (PDFs), `libgsf` (documentos), `freetype` (fontes).
    - **Configurações Dconf Otimizadas**:
      - Modo árvore ativado no modo lista (`use-tree-view = true`).
      - Ordenar pastas antes dos arquivos (`sort-directories-first = true`).
      - Excluir permanentemente no menu de contexto (`show-delete-permanently = true`).
      - Criar link simbólico no menu de contexto (`show-create-link = true`).
      - Relógio em formato 24h.
    - **Scripts Customizados no Menu de Contexto (`~/.local/share/nautilus/scripts/`)**:
      - `Abrir no VSCode` / `Abrir no Antigravity`.
      - `Abrir como Administrador` (via `pkexec` com preservação de display Wayland/X11).
      - `Comparar com Meld` (diff visual).
      - `Copiar Caminho Completo` (com suporte automático a `wl-copy` e `xclip` + notificação OSD).
      - `Verificar Checksum (SHA256)` (cálculo de hash com exibição gráfica via `zenity`).
      - `Converter Imagem para WebP` (conversão com 85% de qualidade via `imagemagick`).
      - `Definir como Papel de Parede` (com suporte automático a `hyprpaper`, `feh` e `gsettings`).
      - `Gerar QR Code` (via `qrencode` e exibição gráfica com `feh` ou `zenity`).
    - **Modelos para "Novo Documento"**: Texto vazio, Markdown, Script Shell e Arquivo em Branco criados em `~/.local/share/templates/`.
- **Limpeza Automática de Aplicações Desativadas e Órfãs (`system.cleanup`)**:
  - **Problema Resolvido**: No NixOS / Home Manager, a desativação de módulos ou remoção de pacotes desvincula apenas os links simbólicos gerenciados pelo Nix store. Aplicações em execução (Thunar, SpaceFM, Nautilus, Nemo, PCManFM, Discord, Alacritty, VSCode, etc.) geram arquivos mutáveis e não-gerenciados em tempo de execução (`~/.config/<app>`, `~/.cache/<app>`, `~/.local/share/<app>`, atalhos residuais em `~/.local/share/applications/` e caches drun do Rofi), que permaneciam órfãos no sistema indefinidamente.
  - **Módulo Centralizado (`modules/home-manager/system/cleanup/default.nix`)**:
    - Importado universalmente em `modules/home-manager/system/default.nix` para todos os hosts e ambientes desktop.
    - **Registro Declarativo**: Mapeamento estruturado de todas as aplicações conhecidas do Nixfiles (`thunar`, `nautilus`, `nemo`, `pcmanfm`, `spacefm`, `catfish`, `discord`, `vscode`, `alacritty`, `kitty`, `sonixd`, `rhythmbox`, `audio-recorder`, `ncmpcpp`, `bleachbit`, `flameshot`, `meld`, `zathura`, `libreoffice`). Quando qualquer módulo correspondente estiver inativo (`!app.enabled`), seus caminhos de configuração, cache e dados são limpos automaticamente.
    - **Comparação Dinâmica Entre Gerações (`oldGenPath` vs `newGenPath`)**: Identifica atalhos desktop (`*.desktop`) e binários presentes na geração anterior do Home Manager que foram removidos na nova geração. Extrai os identificadores das aplicações e purga suas pastas mutáveis não gerenciadas, garantindo que qualquer pacote retirado de `home.packages` ou da configuração tenha seus rastros removidos.
    - **Proteção de Pastas Críticas (`PROTECTED_CONFIGS`)**: Lista estrita de exclusão (dconf, gtk, fontconfig, systemd, environment.d, pulse, nix, home-manager, sops, autostart, git, bspwm, sxhkd, polybar, picom, rofi, dunst, hypr, mango, waybar, zsh, bash, starship, etc.) impedindo qualquer deleção acidental de diretórios essenciais do sistema.
    - **Links Simbólicos Quebrados & Dead Store Paths**: Detecta e remove links corrompidos (`-xtype l`) e arquivos `.desktop` em `~/.local/share/applications` cujas diretivas `Exec=` apontem para caminhos inexistentes do Nix store.
    - **Invalidação de Cache de Launchers**: Purgamento imediato de caches do Rofi (`~/.cache/rofi*`, `~/.cache/rofi3.druncache`) e execução de `update-desktop-database` e `gtk-update-icon-cache`, garantindo que aplicativos removidos desapareçam instantaneamente dos menus de aplicativos.
  - **Hook de Ativação Automático**: Injetado em `home.activation.cleanupOrphanedConfigs` (`entryAfter [ "writeBoundary" ]`), disparado automaticamente a cada switch (`hm-switch`, `home-manager switch` ou `nixos-rebuild switch`).
  - **Comando CLI Dedicado**: Utilitário `clean-orphaned-configs` (com alias `hm-clean-apps`) disponibilizado no PATH do usuário, com flags `--dry-run` e `--verbose` para auditoria manual a qualquer momento.

- **Tecla Modificadora Universal e Customizável nos Window Managers (`desktop.modifierKey`)**:
  - **Opção Central**: `desktop.modifierKey` disponível para todos os ambientes (`bspwm`, `hyprland`, `mangowm`, `xfce4`), aceitando `"Super"` (padrão), `"Alt"`, `"Ctrl"` (com suporte a variantes e aliases como `"Mod4"`, `"Mod1"`).
  - **Sobrescrita por Ambiente / Window Manager**:
    - `desktop.hyprland.modifierKey`
    - `desktop.mangowm.modifierKey`
    - `desktop.bspwm.modifierKey` (e granular em `desktop.bspwm.sxhkd.modifierKey`)
    - `desktop.xfce4.modifierKey`
  - **Mapeamento e Tradução Automática**:
    - **Hyprland**: Variável `$mainMod` configurada para `SUPER`, `ALT` ou `CTRL`, adaptando todos os `bind`, `bindm` e `bindl`.
    - **MangoWM**: Diretivas `bind=`, `axisbind=` e `mousebind=` geradas dinamicamente com `${mod}` (`SUPER`, `ALT` ou `CTRL`).
    - **BSPWM & SXHKD**: Atalhos do `sxhkd.nix` compilados com `${mod}` (`super`, `alt` ou `ctrl`) e `bspc config pointer_modifier` com `${pointerMod}` (`mod4`, `mod1` ou `control`).
    - **XFCE4**: Entradas de atalho em `xfconf.settings.xfce4-keyboard-shortcuts` compiladas com `${xfceMod}` (`<Super>`, `<Alt>` ou `<Primary>`).
  - **Prevenção Inteligente de Conflitos (Inversão Secundária)**:
    - Quando a tecla principal selecionada for `Alt`, atalhos secundários combinados (ex: `Super + Alt + Setas` para redimensionar) invertem o modificador secundário para `Super`, evitando combinações redundantes como `Alt + Alt`.
    - Quando a tecla principal for `Ctrl`, atalhos secundários combinados (ex: `Super + Ctrl + Return` para terminal flutuante) invertem o secundário para `Super`, prevenindo `Ctrl + Ctrl`.
  - **Estados de Janelas Unificados nos Tiling WMs**:
    - `Modifier + F`: Alterna janela flutuante (`floating` / `togglefloating`) em todos os gerenciadores (`bspwm`, `hyprland`, `mangowm`), mantendo `Modifier + S` como atalho alternativo.
    - `Alt + A`: Alterna tela cheia (`fullscreen` / `togglefullscreen`) em todos os gerenciadores, eliminando qualquer conflito de atalhos em editores/terminais com `Shift + F`.
  - **Documentação e Menus Dinâmicos**: O menu Rofi de Quick Settings do BSPWM e o cheat-sheet de atalhos renderizam dinamicamente o nome da tecla ativa (`Super + ...`, `Alt + ...` ou `Ctrl + ...`).

- **Suporte a Iluminação de Teclado Logitech MX Keys & Laptops (`kbdBrightnessOsd`)**:
  - **Teclas F3 e F4 no MX Keys**:
    - No Logitech MX Keys, os botões físicos de brilho do teclado ficam localizados em **F3** (diminuir) e **F4** (aumentar).
    - O comportamento de alternância de teclas de função e multimídia pode ser alternado fisicamente no teclado via **`Fn + Esc`** (Fn-Lock). Em modo multimídia, o teclado emite `XF86KbdBrightnessDown` (F3) e `XF86KbdBrightnessUp` (F4).
    - Sensor de Luz Ambiente do MX Keys: O teclado possui um sensor de luz ambiente de hardware que desativa a iluminação automaticamente em ambientes claros (>100 lux).
  - **Mapeamentos em BSPWM (`sxhkd.nix`), Hyprland e MangoWM**:
    - Teclas multimídia globais: `XF86KbdBrightnessUp`, `XF86KbdBrightnessDown` e `XF86KbdLightOnOff`.
    - Atalhos diretos do MX Keys: `${mod} + F4` (aumentar), `${mod} + F3` (diminuir), `${mod} + Shift + F4/F3` (alternar/toggle).
    - No BSPWM com `mod != "super"`, também foram mapeados atalhos com `Super` (`super + F4`, `super + F3`, etc.).
    - Atalhos legados do MacBook (`F5` e `F6`) mantidos para retrocompatibilidade.
  - **Fallback Dinâmico e Integração com Solaar (`kbdBrightnessOsd`)**:
    - Dispositivos de kernel padrão (`smc::kbd_backlight`, `asus::kbd_backlight`, etc.) são controlados via `brightnessctl`.
    - Para teclados externos sem interface em `/sys/class/leds` (como o Logitech MX Keys), o script detecta o binário do `solaar` (no PATH ou Nix Store), aplica a configuração via CLI (`solaar config "MX Keys" backlight true/false`) e emite feedback visual OSD via Dunst (`Luz do Teclado (MX Keys): ...`).
  - **Host `nitro` (Debian Standalone)**:
    - Adicionado pacote `pkgs.solaar` em `home.packages`.
    - Configurado serviço systemd do usuário (`systemd.user.services.solaar`) iniciando em segundo plano no tray (`solaar --window=hide`) atrelado a `graphical-session.target`.

- **Virtualização com QEMU/KVM e Virt-Manager (NixOS vs. Standalone / Debian)**:
  - **Diretriz de Instalação (NixOS vs. Home Manager / Distros Nativas)**:
    - O `virt-manager` é exclusivamente o cliente gráfico e depende de componentes em nível de sistema (`libvirtd`, módulos de kernel `kvm_intel`/`kvm_amd`, pontes de rede `virbr0`, iptables/nftables e Polkit).
    - **NixOS**: Habilitar a nível de SO usando o módulo dedicado do repositório em `modules/nixos/system/services/virt-manager/default.nix` (`nixos.services.virt-manager.enable = true;`), que já configura QEMU, libvirtd, OVMF (UEFI/Secure Boot), TPM (`swtpm`), DConf e grupos (`libvirtd`, `qemu-libvirtd`). Não instalar isoladamente via Home Manager.
    - **Hosts Standalone (Debian `nitro`, Fedora `anubis`)**: Sempre instalar pelos gerenciadores nativos do sistema (`sudo apt install virt-manager qemu-system libvirt-daemon-system ovmf swtpm swtpm-tools` ou `sudo dnf install @virtualization virt-manager edk2-ovmf swtpm`) para evitar incompatibilidades de Polkit e de sockets `/var/run/libvirt/libvirt-sock` entre o Nixpkgs e o host.
    - **Exceção Home Manager**: Instalar `pkgs.virt-manager` no Home Manager apenas para gerenciamento puramente remoto de VMs (`qemu+ssh://...`).
  - **Suporte a Firmware UEFI (OVMF) e TPM no Debian ("Apenas BIOS aparece no Virt-Manager")**:
    - **Causa Raiz**: No Debian, os binários de firmware UEFI EDK2 não acompanham o pacote base do QEMU. Sem o pacote `ovmf`, o `libvirtd` não localiza os descritores em `/usr/share/qemu/firmware/` e o virt-manager exibe apenas `BIOS (SeaBIOS)` nas opções de firmware.
    - **Solução**:
      1. Instalar os pacotes de firmware UEFI e emulador de TPM 2.0:
         ```bash
         sudo apt install ovmf swtpm swtpm-tools
         ```
      2. Reiniciar o serviço do libvirt para registrar os descritores:
         ```bash
         sudo systemctl restart libvirtd
         ```
      3. Reabrir o virt-manager. Ao criar uma VM, marcar *"Personalizar a configuração antes de instalar"*, ir em **Visão Geral** (*Overview*) e selecionar o firmware `UEFI x86_64: /usr/share/OVMF/OVMF_CODE_4M.fd` (ou variante Secure Boot).
  - **Criação de Discos `.qcow2` no Debian (`creation of non-raw file images is not supported without qemu-img`)**:
    - **Causa Raiz**: O pacote `qemu-system` no Debian não inclui o utilitário `/usr/bin/qemu-img` (pertencente ao pacote `qemu-utils`). Sem ele, o libvirt só consegue criar discos em formato `.raw`, falhando com `RuntimeError: Couldn't create storage volume ... internal error: creation of non-raw file images is not supported without qemu-img` ao gerar volumes `.qcow2`.
    - **Solução**:
      1. Instalar o pacote `qemu-utils`:
         ```bash
         sudo apt install qemu-utils
         ```
      2. Reiniciar o serviço do libvirt:
         ```bash
         sudo systemctl restart libvirtd
         ```
  - **Permissões de Acesso a ISOs e Armazenamento Externo no Debian (`Permission denied`)**:
    - **Causa Raiz**: No Debian, o QEMU executa VMs sob o usuário de sistema `libvirt-qemu`. Dispositivos externos montados via desktop ficam em `/media/$USER/...` com permissão restrita `0700` (`rwx------`), impedindo que o `libvirt-qemu` atravesse as pastas até o arquivo `.iso`. O AppArmor também pode restringir caminhos fora de `/var/lib/libvirt/images`.
    - **Solução Recomendada (Desktop Pessoal)**: Fazer o QEMU rodar sob o próprio usuário local editando `/etc/libvirt/qemu.conf`:
      ```ini
      user = "juca"
      group = "juca"
      ```
      e reiniciando o daemon (`sudo systemctl restart libvirtd`).
    - **Solução via ACLs (Sem alterar usuário do daemon)**:
      ```bash
      sudo setfacl -m u:libvirt-qemu:rx /media/$USER
      sudo setfacl -R -m u:libvirt-qemu:rx /caminho/do/hd_externo
      ```
    - **Discos NTFS/exFAT**: Em sistemas de arquivos sem suporte a permissões POSIX, garantir montagem com `umask=022`.
    - **AppArmor**: Caso continue bloqueando após ajustar permissões, definir `security_driver = "none"` em `/etc/libvirt/qemu.conf` e reiniciar o `libvirtd`.

- **Sincronização do Script de Instalação `nitro-dual-debian.sh`**:
  - **Virtualização Nativa**: Adicionada instalação e provisionamento completo do Virt-Manager, QEMU/KVM, OVMF, `swtpm`, `qemu-utils`, configuração de `user = "juca"` / `group = "juca"` em `/etc/libvirt/qemu.conf`, regra de Polkit `80-libvirt.rules` e ativação do serviço `libvirtd.service`.
  - **Xorg, LightDM e Sessão BSPWM**: Substituídos blocos comentados pela instalação completa do servidor Xorg, drivers Intel e libinput, LightDM, GTK Greeter, wrapper `/usr/local/bin/start-bspwm-session` com carregamento de perfis do Nix e fallback amigável, `/usr/share/xsessions/bspwm.desktop`, `~/.dmrc` e ativação do `lightdm.service`.
  - **Logitech MX Keys & Solaar**: Inclusão de regra de udev `/etc/udev/rules.d/42-logitech-unify-permissions.rules` para acesso aos receptores Bolt e Unifying sem root e adição do grupo `plugdev` ao usuário `juca`.
  - **Grupos do Usuário**: Atualizado `usermod` para incluir `plugdev`, `libvirt`, `kvm` além dos grupos de sistema e Nix.
  - **NVIDIA & Multimídia**: Inclusão de `libnvcuvid1` para aceleração NVDEC no `mpv-nvidia`, além de `intel-media-va-driver-non-free`, `vainfo` e `mesa-va-drivers` para a GPU integrada Intel UHD 630.
  - **Nix Multi-usuário**: Configuração declarativa do canal `nixpkgs-unstable` para o usuário `juca` e `root`, `nix.conf` com `@nix-users`, `max-jobs = auto` e `cores = 0`, além de export de `NIX_PATH` apontando para o canal unstable.
  - **PAM Lockers**: Inclusão de `i3lock` junto a `hyprlock`, `swaylock` e `noctalia`.

- **Scripts de Instalação e Reparo para Máquina Virtual (`nitro-dual-debian_vm.sh` & `fix-debian_vm.sh` / `virtualvm` com DWM)**:
  - **Alvo**: Instalação automatizada e script de correção/finalização pós-instalação para Debian Trixie em VM Virt-Manager (`/dev/vda`), testando **Home Manager standalone com DWM** (`flake.nix` -> `juca@virtualvm`).
  - **Eliminação de Artefatos de Hardware Físico**:
    - Removidos drivers proprietários NVIDIA (`nvidia-driver`, CUDA, NVDEC, DKMS), Intel Microcode e parâmetros de kernel de GPU/IOMMU (`intel_iommu`, `nvidia-drm.modeset=1`, `i915.enable_psr=0`, `nowatchdog`, `split_lock_detect=off`).
    - Removidos `thermald`, `powertop --auto-tune` no `rc.local`, e utilitários de periféricos físicos (`solaar`).
    - Removidos requisitos e scripts de verificação manual de Secure Boot / MOK (`mokutil`, `sbsigntool`, `shim-signed`).
  - **Otimização para QEMU/KVM**:
    - **Dracut**: Adicionados drivers de VM em `add_drivers+=" virtio_pci virtio_scsi virtio_blk virtio_net virtio_balloon virtio_console qxl bochs_drm "` e compressão rápida `compress="zstd -3"`.
    - **Vídeo & Integração**: Instalados `xserver-xorg-video-qxl`, `xserver-xorg-video-all`, `libgl1-mesa-dri`, `mesa-vulkan-drivers`, `qemu-guest-agent` e `spice-vdagent` (auto-redimensionamento de tela e clipboard bidirecional).
    - **Serviços**: Ativados `qemu-guest-agent.service` e `spice-vdagent.service`.
  - **Sessão DWM no LightDM**:
    - LightDM configurado com `user-session=dwm`.
    - Wrapper `/usr/local/bin/start-dwm-session` carregando os perfis do daemon do Nix (`/etc/profile.d/nix.sh`, `nix-daemon.sh` e `~/.nix-profile/etc/profile.d/nix.sh`), priorizando `$HOME/.local/bin/start-dwm` gerado pelo módulo DWM do Home Manager, com fallback via xterm indicando a execução de `home-manager switch --flake .#juca@virtualvm -b backup`.
    - Arquivo de sessão `/usr/share/xsessions/dwm.desktop`, `.dmrc` do usuário com `Session=dwm` e symlink provisionado via `systemd-tmpfiles` em `/etc/tmpfiles.d/nix-desktop-sessions.conf`.
  - **Script de Validação**: Substituído o validador de MOK pelo `/usr/local/bin/check-vm-setup.sh` que afere EFI bootloader, initramfs gerado, arquivos de sessão DWM, agentes QEMU/SPICE e integridade do Nix Daemon.

- **Migração de Depreciações Nixpkgs 26.05 (`xorg.*`) & Resolução de Clobber no Home Manager**:
  - **Depreciação de `xorg.*`**: No Nixpkgs 26.05, o attrset `pkgs.xorg.*` foi depreciado e substituído por pacotes de primeiro nível (`libx11`, `libxft`, `libxinerama`, `libxrender`, `libxcursor`, `libxcb`, `setxkbmap`, `xrdb`, `xrandr`, `xsetroot`, `xinput`). Todos os módulos (`dwm.nix`, `dwm/packages.nix`, `bspwm.nix`, `bspwm/packages.nix`, `sxhkd.nix`, `polybar/default.nix`, `externalMonitor.nix` e `pkgs/desktop/thorium/default.nix`) foram migrados. No Thorium, o argumento de função `xorg` foi substituído por `libxcb`.
  - **Conflito de Arquivos no Primeiro Switch do Home Manager Standalone (`.bashrc` / `.profile`)**:
    - Ao instalar distribuições como Debian ou Fedora, `useradd -m` copia arquivos de `/etc/skel` (`.bashrc`, `.profile`) para a home do usuário.
    - O Home Manager standalone se recusa a sobrescrever arquivos regulares que não sejam links do Nix store (`Existing file would be clobbered`).
    - **Solução Imediata**: Usar a flag `-b backup` na chamada:
      ```bash
      home-manager switch --flake .#juca@virtualvm -b backup
      ```
      Isso move os arquivos conflitantes para `.bashrc.backup` e `.profile.backup` e cria os links do Home Manager sem erros.
    - **Prevenção nos Scripts de Instalação**: Nos scripts de VM/instalação, remover preventivamente `~/.bashrc` e `~/.profile` após o `useradd` ou instruir o switch sempre com a flag `-b backup`.
  - **Permissões de Diretórios de Perfil (`per-user/<user>`)**:
    - Ao finalizar a geração, o Home Manager e o Nix registram symlinks em `/nix/var/nix/profiles/per-user/<user>` e gcroots em `/nix/var/nix/gcroots/per-user/<user>`.
    - Se `/nix/var/nix/profiles/per-user` e `/nix/var/nix/gcroots/per-user` não tiverem permissão `1777` (sticky bit) ou a pasta do usuário não for criada com `chown <user>:<user>`, o switch falha com `Permission denied`.
    - **Correção**:
      ```bash
      sudo chmod 1777 /nix/var/nix/profiles/per-user /nix/var/nix/gcroots/per-user
      sudo mkdir -p /nix/var/nix/profiles/per-user/$USER /nix/var/nix/gcroots/per-user/$USER
      sudo chown -R $USER:$USER /nix/var/nix/profiles/per-user/$USER /nix/var/nix/gcroots/per-user/$USER
      ```

- **Módulo DWM Simples para NixOS (`modules/nixos/desktop/environments/dwm/default.nix`)**:
  - Implementado suporte declarativo e enxuto a DWM no nível do sistema (`services.xserver.windowManager.dwm.enable = true;`).
  - Configura backend X11, Display Manager (`lightdm` via `mkDefault`), sessão padrão `none+dwm`, Polkit, DConf e pacotes essenciais de fallback (`dwm`, `dmenu`, `slstatus`, `picom`, `feh`).
  - Arquitetura subordinada: todas as opções usam `lib.mkDefault`, permitindo que o ecossistema avançado do Home Manager (`dwm-titus`, `quickshell`, `hotkeys.toml`, etc.) atue como o configurador principal e prioritário da experiência do usuário.
  - Adicionado `iso-dwm = helper.mkIso { desktop = "dwm"; };` no `flake.nix`.

- **Migração do Host `rocinante` para DWM (MacBook Pro 4,1)**:
- **Estabilização do DWM (Titus) — NVIDIA 340 Legacy, Temas Mutáveis (QML) e Keyboard Backlight**:
  - **Problema 1: Barra Quickshell Não Aparecia no NVIDIA 340 Legacy (`rocinante`)**:
    - *Causa*: Quickshell (baseado em Qt 6.8+ / QML) usa Vulkan por padrão para seu Qt Quick Scene Graph (RHI) no Linux X11 e busca EGL através do plugin xcb. A GPU GeForce 8600M GT (driver proprietário 340.108 monolítico pré-libglvnd) não possui suporte a Vulkan nem EGL no X11 (apenas GLX nativo em `libGL.so.1`). Sem configuração explícita, o Quickshell falhava e encerrava sem exibir a barra superior nem gerar logs.
    - *Correção*:
      - Exportadas variáveis de ambiente no `xsession`: `QT_QPA_PLATFORM=xcb`, `QT_XCB_GL_INTEGRATION=glx` e `QSG_RHI_BACKEND=opengl`.
      - Adicionadas flags estáveis para NVIDIA 340: `__GL_VRR_ALLOWED=0` e `LIBGL_ALWAYS_INDIRECT=0`.
      - Redirecionamento da saída do Quickshell para `~/.local/state/dwm-titus/quickshell.log`.
      - Watchdog leve em background: se o Quickshell falhar na inicialização da GPU, aciona automaticamente o script nativo `dwm-status` como barra de fallback sem deixar a tela vazia.
      - `dwm-quickshell-version-check`: Atualizado para aceitar o pacote Quickshell empacotado no Nixpkgs sem rejeitar snapshots de compilação.
  - **Problema 2: Temas Ficavam "Read Only" e Não Mudavam via QML**:
    - *Causa*:
      1. No Home Manager, `xdg.configFile."dwm-titus".source = ./configs/config;` gerava `~/.config/dwm-titus` como um symlink apontando diretamente para o `/nix/store/...` (sistema de arquivos somente-leitura).
      2. Os scripts `dwm-settings-theme` e `theme-apply.sh` implementam validações estritas de segurança: exigem que `${themes_file%/*}` (`~/.config/dwm-titus`), `themes.toml` e os arquivos de integração sejam arquivos/diretórios reais e graváveis (`! -L` e `-w`). Com o symlink do nix store, a função `mutation_ready` retornava 1 (falso), desativando o painel de temas do Quickshell.
      3. `gtk.enable = true` no módulo DWM gerava `~/.config/gtk-3.0/settings.ini` como link do nix store, bloqueando os journals de transação do `theme-apply.sh`.
    - *Correção*:
      - Removido `xdg.configFile."dwm-titus"`.
      - Implementado hook de ativação `home.activation.setupDwmConfig`: desfaz symlinks do nix store em `~/.config/dwm-titus`, cria o diretório real editável pertencente ao usuário (`$UID`), sincroniza fallbacks em `~/.local/share/dwm-titus/config` e `scripts`, e inicializa `themes.toml`, `hotkeys.toml`, `window-rules.toml` e arquivos de estado com permissões `u+w`.
      - Definido `gtk.enable = lib.mkForce false` no DWM, gerenciando temas via `home.packages` e inicializando arquivos GTK reais graváveis.
      - Atualizado `dwm-settings-theme` para ser tolerante a symlinks do Nix store em `validate_integration_file` e `mutation_ready`, evitando travamentos por arquivos de outras ferramentas.
  - **Problema 3: Falta de Controle de Iluminação do Teclado (Keyboard Backlight) com Verificação de Hardware**:
    - Criado o script `dwm-kbd-brightness-osd` em `modules/home-manager/desktop/environments/dwm/configs/scripts/dwm-kbd-brightness-osd`.
    - *Verificação Inteligente de Hardware*: testa `DWM_KBD_BACKLIGHT_DEVICE`, depois candidatos padrão (`smc::kbd_backlight`, `apple::kbd_backlight`, `dell::kbd_backlight`, `asus::kbd_backlight`, `tpacpi::kbd_backlight`), busca em `/sys/class/leds` e integra fallback a `solaar`. Se o host não tiver hardware de backlight (ex: Desktop, VM), encerra com status 0 sem travar a sessão.
    - Notificação OSD gráfica via Dunst/libnotify com ícone de teclado e porcentagem.
    - Atalhos integrados em `configs/config/hotkeys.toml`: teclas de hardware `XF86KbdBrightnessUp`, `XF86KbdBrightnessDown`, `XF86KbdLightOnOff`, além dos atalhos de laptop `SUPER + F6` (aumentar), `SUPER + F5` (diminuir) e `SUPER + Shift + F5` (liga/desliga).
  - **Arquitetura Agnóstica Declarativa por Host (`desktop.dwm.*`)**:
    - Configurações disponíveis para qualquer host no Home Manager:
      - `desktop.dwm.bar`: `"quickshell"` (padrão), `"dwm-status"`, `"slstatus"`, `"polybar"`, `"none"`.
      - `desktop.dwm.quickshell.qsgBackend`: `"opengl"` (padrão estável para GPUs legadas), `"software"`, `"vulkan"`, `"auto"`.
      - `desktop.dwm.quickshell.glIntegration`: `"glx"` (padrão para X11/NVIDIA), `"egl"`, `"auto"`.
      - `desktop.dwm.keyboard.brightness.enable`: booleano (padrão `true`).
      - `desktop.dwm.keyboard.brightness.device`: string com nome do dispositivo ou `null` para auto-detecção.
      - `desktop.dwm.keyboard.brightness.step`: porcentagem de incremento (padrão `5`).
    - Configurado em `home-manager/hosts/rocinante/default.nix`:
      ```nix
      desktop.dwm = {
        bar = "quickshell";
        quickshell = {
          qsgBackend = "opengl";
          glIntegration = "glx";
        };
        keyboard.brightness = {
          enable = true;
          device = "smc::kbd_backlight";
          step = 5;
        };
        picom = {
          enable = true;
          backend = "xrender";
        };
      };
      ```
    - **Detecção Declarativa NVIDIA 340 Legacy vs Nouveau (NixOS Module & osConfig)**:
      - Como o Home Manager é integrado diretamente como módulo do NixOS no host `rocinante` (`inputs.home-manager.nixosModules.home-manager`), todos os módulos do Home Manager recebem `osConfig`.
      - **Agnóstico e Automático via `osConfig`**: Em `modules/home-manager/desktop/environments/dwm/dwm.nix`, `isNvidiaLegacy` avalia `(osConfig.hardware.graphics.cards.gpu or null) == "nvidia-legacy"`, configurando `glIntegration = "glx"` dinamicamente.
      - **Especializações no NixOS (`specialisation.nvidia`)**:
        - No boot padrão (Kernel Zen + Nouveau): `hardware.graphics.cards.gpu = null`, Mesa/Gallium é usado com `glIntegration = "auto"`.
        - Na especialização `nvidia` (Kernel 6.6 LTS + NVIDIA 340 Legacy): `hardware.graphics.cards.gpu = mkForce "nvidia-legacy"`, e o bloco `home-manager.users.juca` ajusta `desktop.dwm.quickshell.glIntegration = "glx"` e `GPU_DRIVER_PROFILE = "nvidia-legacy"`.
      - **Variáveis de Sessão Globais do NixOS**: No módulo `modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix`, foram exportadas globalmente `QT_XCB_GL_INTEGRATION = "glx"`, `QSG_RHI_BACKEND = "opengl"`, `__GL_VRR_ALLOWED = "0"` e `LIBGL_ALWAYS_INDIRECT = "0"`.
      - **Permissões Udev de Backlight do Teclado**: Configurado `services.udev.packages = [ pkgs.brightnessctl ]` e grupo `video` nos usuários do NixOS (`nixos/users/default.nix`), garantindo controle do `/sys/class/leds/smc::kbd_backlight` sem necessidade de privilégios de root.
      - **Specialisation do Home Manager (`specialisation.nvidia`)**: Em `home-manager/hosts/rocinante/default.nix`, eliminadas checagens condicionais `isNvidiaLegacy`. A configuração padrão atua limpa com Nouveau/Mesa (`glIntegration = "auto"`, `GPU_DRIVER_PROFILE = "nouveau"`), e o bloco `specialisation.nvidia` encapsula a variação para o driver proprietário NVIDIA 340 Legacy (`glIntegration = "glx"`, `GPU_DRIVER_PROFILE = "nvidia-legacy"`), em sintonia com a especialização do NixOS.
    - **Fix `home.file.".profile".source` sem valor definido (NixOS)**:
      - Em `modules/home-manager/desktop/display-servers/x11/default.nix` e `wayland/default.nix`, a diretiva `file = { ".profile".text = mkIf (!isNixOS) ...; };` instanciava o submódulo `".profile"` mesmo em hosts NixOS (`!isNixOS == false`). Sem `.text` e sem `.source`, o gerador de links do Home Manager falhava avaliando `sourceStorePath` (`The option ...source was accessed but has no value defined`).
      - Corrigido movendo a condicional para o nível do atributo pai: `file = mkIf (!isNixOS) { ".profile".text = ...; };`.
    - **Compatibilidade do `antigravity-cli` no Intel Core 2 Duo (`agy` via QEMU)**:
      - O binário `agy` distribuído pelo Google é pré-compilado (`storage.googleapis.com`) exigindo a instrução `PCLMULQDQ` (ausente fisicamente no Core 2 Duo de 2008), o que causava `SIGILL` via `go/sigill-fail-fast`.
      - Resolvido encapsulando `antigravity-cli` com `qemu-x86_64 -cpu Haswell` via `makeWrapper` no [home-manager/hosts/rocinante/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/home-manager/hosts/rocinante/default.nix), permitindo que o `agy` execute normalmente no processador legado com emulação pontual das instruções ausentes.
    - **Correção de Erros de Sintaxe no Fish Shell (`gitpfolders`, `search` e integração NixOS)**:
      - **Problema 1 (`gitpfolders`)**: O alias continha sintaxe POSIX sh (`for i in */.git; do (echo $i; cd $i/..; git pull); done`). No Fish shell, `do` e `done` não existem e geravam o erro fatal `Missing end to balance this function definition` durante o startup do shell.
      - **Solução 1**: Convertido `gitpfolders` em um script executável autônomo via `pkgs.writeShellScriptBin` adicionado a `home.packages` em [modules/home-manager/system/programs/shells/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/system/programs/shells/default.nix), tornando o comando universal e agnóstico ao shell sem poluir o `alias.fish`.
      - **Problema 2 (`search`)**: O alias continha `"$@"`. O wrapper de alias do Fish no Home Manager já anexa `$argv`, e no Fish `$@` é sintaxe inválida, gerando o erro `$@ is not supported. In fish, please use $argv.`.
      - **Solução 2**: Removido `"$@"` da definição do alias `search`, permitindo que tanto Fish (via `$argv`) quanto Bash/Zsh (via expansão natural de aliases) recebam argumentos de forma limpa.
      - **Ajuste `pci`**: Corrigido comando para `sudo --preserve-env=PATH ${pkgs.inxi}/bin/inxi --slots` eliminando a tentativa incorreta de executar `'PATH=$PATH'` como binário.
    - **Correção da Sessão do DWM no LightDM / NixOS (Causa da Barra e Hotkeys Ausentes)**:
      - **Causa Raiz**: Em `modules/nixos/desktop/environments/dwm/default.nix`, a configuração declarava `windowManager.dwm.enable = true` e `displayManager.defaultSession = "none+dwm"`. No NixOS, isso gerava `/run/current-system/sw/share/xsessions/none+dwm.desktop` executando diretamente `pkgs.dwm` (versão pura/vanilla do Nixpkgs). O LightDM iniciava esse binário padrão, ignorando completamente o `start-dwm`, `~/.xsession`, `quickshell`, `dwm-status`, `picom`, `feh`, `setxkbmap` e a leitura de `hotkeys.toml` (deixando a tela sem barra e sem controle de brilho do teclado).
      - **Solução**:
        - No NixOS, a assertion de `services.displayManager.defaultSession` exige uma sessão registrada na lista de desktop files válidos (que para o módulo DWM é obrigatoriamente `none+dwm`).
        - Em [modules/nixos/desktop/environments/dwm/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/nixos/desktop/environments/dwm/default.nix), configurado `services.xserver.windowManager.dwm.package` com um wrapper gerado via `pkgs.writeShellScriptBin "dwm"`. Esse wrapper intercepta a chamada do desktop file `none+dwm.desktop` e executa `$HOME/.local/bin/start-dwm` (com fallback para `$HOME/.xsession` e `${pkgs.dwm}/bin/dwm`).
        - Mantido `services.displayManager.defaultSession = mkDefault "none+dwm"` (satisfazendo 100% a validação de assertions do NixOS), e removida a duplicação do pacote `dwm` em `systemPackages`.
      - **Correção da Falha do Quickshell (`symbol lookup error: undefined symbol: eglDestroyImage`)**:
        - **Causa Raiz**: No script de inicialização do DWM (`~/.xsession`), a condicional `if [ -d /run/opengl-driver/lib ] && [ -f /run/opengl-driver/lib/libGL.so.1 ]` avaliava como verdadeira em **qualquer** sistema NixOS com gráficos habilitados, exportando `LD_LIBRARY_PATH="/run/opengl-driver/lib..."` incondicionalmente no boot padrão Nouveau/Mesa. Isso sobrepunha as bibliotecas `libglvnd` (`libEGL.so.1`) do Nix store e forçava o Quickshell (aplicativo moderno Qt 6.8+ esperando EGL 1.5) a carregar a biblioteca do driver legado ou direta do Mesa, onde `eglDestroyImage` não era encontrada, resultando em encerramento imediato.
        - **Solução**:
          1. Em [modules/home-manager/desktop/environments/dwm/dwm.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/dwm/dwm.nix), restrito o export de `LD_LIBRARY_PATH` para ser executado **exclusivamente** quando o driver proprietário NVIDIA 340 Legacy for detectado (`/proc/driver/nvidia` ou `/run/opengl-driver/lib/libGL.so.340.108`).
          2. Na inicialização do Quickshell, encapsulado com `env -u LD_LIBRARY_PATH` para assegurar que a barra execute utilizando seus links limpos e versionados do Nix Store (com suporte completo a EGL 1.5).
      - **Correção da Falha do Quickshell (`FATAL: Could not initialize GLX` / FBConfig mismatch)**:
        - **Causa Raiz**: O driver proprietário NVIDIA 340 Legacy (2014) não disponibiliza FBConfigs GLX compatíveis com os requisitos estritos de `QSurfaceFormat` do Qt 6.11 (`qglx_findConfig: Failed to finding matching FBConfig`). Ao forçar `QT_XCB_GL_INTEGRATION=glx`, o plugin XCB do Qt abortava a execução imediatamente. Além disso, a função `drawbar` do `dwm.c` possui um `return;` explícito no início, tornando o Quickshell o único responsável pela renderização da barra no `dwm-titus`.
        - **Solução**:
          1. Configurado o Quickshell no host `rocinante` (e por padrão no `dwm.nix` para GPUs legadas) para utilizar o rasterizador por software via CPU (`qsgBackend = "software"`, `QT_QUICK_BACKEND = "software"`) e desativada a inicialização GLX/EGL no plugin X11 (`glIntegration = "none"`, `QT_XCB_GL_INTEGRATION = "none"`).
          2. Removidas as injeções globais de `QT_XCB_GL_INTEGRATION = "glx"` em [modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/nixos/hardware/graphics/cards/nvidia-legacy/default.nix) e no script `~/.xsession`.
          3. Com o backend de software, a barra Quickshell renderiza com altíssima fluidez via CPU no Intel Core 2 Duo, com zero consumo desnecessário de memória e 100% de estabilidade imune a limitações de FBConfigs do driver gráfico legado.
      - **Ativação e Estabilização do Plymouth (Boot Splash em Nouveau e NVIDIA 340)**:
        - **Causa Raiz 1 (Nouveau)**: O driver DRM `nouveau` não estava em `boot.initrd.kernelModules`. Sem driver KMS no estágio 1, o Plymouth não conseguia inicializar o framebuffer gráfico durante o carregamento do initrd.
        - **Causa Raiz 2 (NVIDIA 340 Legacy)**: Na especialização `specialisation.nvidia`, a diretiva `kernelParams = mkForce [ ... ]` sobrescreveu e eliminou os parâmetros de splash (`splash`, `quiet`, `fbcon=nodefer`). Como o driver proprietário NVIDIA 340 é pré-KMS, o kernel depende do framebuffer VESA/simpledrm configurado pelo bootloader.
        - **Causa Raiz 3 (GRUB BIOS / Legacy)**: O GRUB operando em modo BIOS (`bootType = "legacy"`) desativava a saída de vídeo gráfica e retornava ao modo texto VGA (80x25) antes de transferir o controle ao kernel Linux por ausência de `gfxpayload=keep`.
        - **Solução**:
          1. Em [modules/nixos/system/boot/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/nixos/system/boot/default.nix), adicionados `gfxmodeBios = "auto";` e `set gfxpayload=keep` no GRUB.
          2. Em [nixos/hosts/rocinante/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/default.nix), incluídos `"nouveau"` em `boot.initrd.kernelModules`, e `"simpledrm"`, `"vesafb"` em `availableKernelModules`.
          3. Em `specialisation.nvidia`, adicionados `"splash" "quiet" "fbcon=nodefer" "nomodeset"` aos parâmetros de boot.
      - **Organização de Atalhos no DWM (`hotkeys.toml`)**:
        - **Diretriz do Usuário**: Manter as keybinds originais nativas do `dwm-titus` como ativas por padrão e deixar todas as keybinds modificadas/alternativas documentadas e comentadas no arquivo (`hotkeys.toml`), permitindo fácil consulta ou ativação sem perda das opções.
        - **Atalhos Nativos Mantidos Ativos**:
          - `SUPER + Return`: Promover para Master (`zoom`).
          - `SUPER + x`: Terminal (`$terminal` / Alacritty).
          - `SUPER + r`: Lançador Quickshell (`quickshell ipc call launcher toggle`).
          - `SUPER + d`: Lançador Rofi (`rofi -show drun`).
          - `SUPER + space`: Alternar Janela Flutuante (`togglefloating`).
          - `SUPER + d`: Reduzir número de janelas no Master (`incnmaster -1`).
          - `SUPER + b`: Abrir Navegador padrão (`dwm-default-apps open https://`).
          - `SUPER + e`: Abrir Gerenciador de Arquivos (`xdg-open .`).
          - `SUPER + q`: Fechar janela em foco (`killclient`).
          - Multimídia e Iluminação de Teclado nativas ativas (`XF86Audio...`, `XF86MonBrightness...`, `XF86KbdBrightness...`, `SUPER + F5`/`F6`).
        - **Atalhos Modificados/Alternativos (Disponíveis e Comentados)**:
          - `# SUPER + Return` / `# SUPER + t`: Abrir Terminal diretamente.
          - `# SUPER + space`: Lançador Rofi.
          - `# SUPER + Shift + Return`: Promover para Master (`zoom`).
          - `# SUPER + Shift + space`: Alternar Flutuante.
          - `# SUPER + u`: Reduzir número de janelas no Master.
          - `# Volume via PipeWire (wpctl)` e atalhos Apple (`SUPER + F10`/`F11`/`F12`).
          - `# Brilho Apple` (`SUPER + F1`/`F2` e `F1`/`F2` diretos).
          - `# Menu de Energia` (`SUPER + Escape` e `SUPER + Shift + e`).
          - `# Bloqueio alternativo` (`SUPER + l`).
      - **Bloqueador de Tela (Lockscreen) no DWM (Betterlockscreen / i3lock-color)**:
        - **Diagnóstico**: O DWM utiliza o helper `dwm-lock` (e o daemon `dwm-lock-watch` que intercepta chamadas D-Bus `loginctl lock-session`). No entanto, nenhum pacote de bloqueio de tela estava instalado no sistema nem declarado nas dependências do DWM, fazendo `dwm-lock` falhar silenciosamente (`no usable screen locker found`).
        - **Solução Arquitetural**:
          1. **Pacotes & PAM**: Em [modules/nixos/desktop/environments/dwm/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/nixos/desktop/environments/dwm/default.nix), adicionada a regra declarativa `security.pam.services.i3lock = { };` (obrigatória no NixOS para autenticação segura com PAM sem setuid root) e incluídos os pacotes `betterlockscreen` e `i3lock-color` no sistema e no Home Manager (`packages.nix`).
          2. **Segurança de Vídeo no Rocinante (Nouveau & NVIDIA 340 Legacy)**: Ao contrário do `light-locker` (que força chaveamento de console virtual/VT e pode gerar travamentos ou corrupção de framebuffer na GeForce 8600M GT), o `betterlockscreen` roda diretamente sobre o display X11 ativo com zero alternância de VT, garantindo 100% de estabilidade e reatividade instantânea.
          3. **Script `dwm-lock` Modernizado**: Configurado com tema Catppuccin Mocha, pré-caching inteligente e fallbacks para `i3lock-color`, `i3lock` e `light-locker`.
          4. **Atalho e Integração**: Vinculado a `SUPER + Shift + x` no `hotkeys.toml` e integrado nativamente ao `dwm-lock-watch`, permitindo bloqueio via atalho físico, menu de energia do Rofi/Quickshell, ou `loginctl lock-session`.
      - **Feedback Visual OSD de Brilho da Tela no DWM (`dwm-mon-brightness-osd`)**:
        - **Script Dedicado**: Criado `modules/home-manager/desktop/environments/dwm/configs/scripts/dwm-mon-brightness-osd`, espelhando a arquitetura robusta do `dwm-kbd-brightness-osd`:
          - Detecta automaticamente a controladora de tela física em `/sys/class/backlight` (`intel_backlight`, `nv_backlight`, `apple_backlight`, `acpi_video0`).
          - Ajusta o nível com incremento suave (passo configurável, padrão 5%).
      - **Wi-Fi — Seleção de Driver Broadcom e Correção de Conexão em Repetidores (`rocinante`)**:
        - **Diagnóstico de Driver no MacBook Pro 4,1 (BCM4321 - `14e4:4328`)**:
          - **`broadcom-sta` (módulo `wl`)**: Veredito: **Driver recomendado e prioritário**. Suporta dual-band e taxas 802.11n (130-300 Mbps) com baixo overhead de CPU.
          - **`b43` (open-source)**: Não recomendado para este chip. O suporte a BCM4321 é experimental no `b43`, limitado a 802.11g (máx. 54 Mbps / ~20 Mbps reais), e gera alta carga de interrupções de hardware (IRQ) na CPU Core 2 Duo.
          - **`brcmsmac` / `brcmfmac`**: Incompatíveis com o chip BCM4321.
        - **Causas Raízes de Falha de Internet ao Conectar no Repetidor Wi-Fi**:
          1. *Timeout de DNS Estático Local (`10.10.10.25` / `10.10.10.26`)*: Se o repetidor tiver AP/Client Isolation ou subnet separada, requisições UDP 53 para o DNS local não chegam. Com timeout padrão do glibc (5s por servidor x 2 tentativas), o sistema congela por 20s em cada resolução de nome, fazendo o navegador acusar "Sem Conexão".
          2. *PMF (802.11w - Protected Management Frames)*: Repetidores modernos ativam PMF por padrão. O driver `broadcom-sta` (`wl`) não possui suporte a PMF e a negociação resulta em descarte de pacotes de dados pelo repetidor após o handshake.
          3. *MTU Black Hole*: O encapsulamento WDS/3-Address de repetidores pode exigir MTU inferior ao padrão de 1500 bytes.
        - **Solução Arquitetural Aplicada**:
          1. Em [nixos/hosts/rocinante/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/nixos/hosts/rocinante/default.nix), adicionado `resolvconf.extraConfig = "options timeout:1 attempts:2 rotate";`, reduzindo o timeout de DNS para 1 segundo e alternando entre servidores com rotação automática para recorrer imediatamente a `1.1.1.1` e `8.8.8.8` caso o DNS local esteja inacessível.
          2. No NetworkManager, injetado no `networking.networkmanager.settings.connection` estruturado: `"wifi-sec.pmf" = 1;` (desativa PMF nas conexões Wi-Fi prevenindo descarte de pacotes no repetidor) e `"802-11-wireless.mtu" = 1460;` (previne descarte de pacotes TCP por fragmentação).
          3. Documentados comandos `nmcli` pontuais para perfil específico de repetidores.

- **DWM — Gerenciador de Arquivos 100% Agnóstico com Thunar como Padrão (`SUPER + e` via `$filemanager`)**:
  - **Arquitetura Agnóstica**: O ecossistema Nixfiles possui um despachante CLI unificado (`modules/home-manager/system/programs/file-manager/default.nix`) chamado `file-manager`. Ao habilitar qualquer gerenciador no host (`thunar.enable`, `nautilus.enable`, `nemo.enable` ou `pcmanfm.enable`), o script `file-manager` embute o caminho absoluto do binário escolhido no Nix store.
  - **Thunar como Padrão do DWM**:
    1. No [dwm/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/dwm/default.nix), configurado `system.programs.file-manager.default = lib.mkDefault "thunar";` e `thunar.enable = lib.mkDefault (!nautilus && !nemo && !pcmanfm);`.
    2. Em [file-manager/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/system/programs/file-manager/default.nix), atualizada a seleção de fallback de `chosenFM` no modo `auto` para priorizar `thunar`.
    3. Ao selecionar 1 para instalar no host (ex: `nautilus.enable = true;`), o Thunar é desativado via `lib.mkDefault` e o Nautilus se torna o ativo automaticamente.
  - **Integração de Atalhos**:
    1. *Variável em `[vars]`*: Adicionado `filemanager = "file-manager"` em `hotkeys.toml`.
    2. *Atalho Simétrico*: Vinculado `{ mod="SUPER", key="e", desc="File manager", func="spawn", exec=["$filemanager"] }`.
    3. *Migração em Ativação (`dwm.nix`)*: No hook `activation.setupDwmConfig`, adicionada migração com `sed` que assegura `filemanager = "file-manager"` em `[vars]` e migra qualquer atalho antigo para `exec=["$filemanager"]` em `~/.config/dwm-titus/hotkeys.toml` existentes.
- **DWM — Arquivos QML do Quickshell e Configurações 100% Graváveis (`Writable` / Live Mode)**:
  - **Problema de Read-Only em Live Mode**: O Quickshell era importado via `xdg.configFile."quickshell".source = ...`, o que gerava um symlink de `~/.config/quickshell` apontando para o Nix store (`/nix/store/...`). Como a Nix store é imutável, qualquer edição em arquivos `.qml` para testes em Live Mode / Hot Reload falhava com erro de somente leitura. Além disso, modelos QML que persistiam configurações (Wallpaper, Fontes, Acessibilidade, Notificações, Painel, Picom e Telas) falhavam por ausência ou bloqueio de escrita nos arquivos de estado.
  - **Solução Arquitetural Aplicada**:
    1. *Eliminação do Symlink do Store*: Removido `xdg.configFile."quickshell"` em [dwm.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/desktop/environments/dwm/dwm.nix).
    2. *Provisionamento Físico de QML Gravável*: No hook `activation.setupDwmConfig`, o diretório `~/.config/quickshell` é desfeito de symlinks, criado como diretório real e sincronizado com `chmod -R u+w`, permitindo salvar alterações em qualquer arquivo `.qml` e ver o recarregamento ao vivo na tela.
    3. *Cobertura Total de Funções QML*: Inicializados com permissão `u+w` todos os arquivos de configuração manipulados pelos modelos QML em `~/.config/dwm-titus/` (`wallpaper.conf`, `font.conf`, `accessibility.conf`, `panel-widgets.conf`, `notification-settings.json`, `picom.conf`, `display-profiles.json`, `personalization.conf`, `theme-env.sh`, `cursor.Xresources`, `xsettingsd.conf`, `themes.toml`, `hotkeys.toml` e `window-rules.toml`).
    4. *Desvinculação de Symlinks em Integrações Externas*: GTK (`settings.ini`), Picom (`picom.conf`), Alacritty (`active-theme.toml`), Kitty (`active-theme.conf`) e Qtct (`qt5ct`/`qt6ct`) convertidos para arquivos e pastas graváveis.

- **DWM & Quickshell — Correção da Troca e Indicação de Workspaces (`continua na 1`)**:
  - **Sintoma**: Ao alternar de workspace (seja via atalho de teclado `SUPER + 2..9` ou clicando nos botões de workspace da barra do Quickshell), o indicador visual continuava travado no workspace 1.
  - **Diagnóstico das Causas Raiz**:
    1. *Omissão de Átomos no `xprop -spy`*: Em `dwm-quickshell-state` (`watch_state`), havia uma ramificação condicional `if xprop -root _DWM_MONITOR_DESKTOPS` que, ao ser executada, omitia o átomo `_NET_CURRENT_DESKTOP` do monitoramento do `xprop -spy`. Como o DWM atualiza `_NET_CURRENT_DESKTOP` em toda mudança de tag (`updatecurrentdesktop`), o script nunca recebia a notificação do X11 ao mudar de workspace sem janelas ativas.
    2. *Full Buffering no Pipeline Unix (4KB Buffer Block)*: O comando `xprop -root -spy ... | while IFS= read -r _event; do show_state; done` utilizava um pipe em modo não-interativo (`isatty(1) == false`). O runtime `glibc` por padrão adota buffering em blocos de 4096 bytes quando a saída é um pipe. Como cada evento impresso pelo `xprop` possui ~35 bytes e o `xprop` não chama `fflush(stdout)`, os eventos ficavam retidos na memória do buffer e o loop `while read` nunca era acionado.
    3. *Falta de Atualização Otimista no QML*: Em `DwmState.qml`, a função `switchWorkspace(index)` disparava o processo em background e aguardava passivamente pelo evento do spy. Se houvesse atraso ou se o processo anterior ainda estivesse ativo, o estado ficava defasado.
    4. *Cálculo e Fallback de Workspaces por Tela*: Em `currentWorkspaceForScreen(screen)`, se o índice do workspace reportado não estivesse no conjunto fatiado da tela (`indexes.indexOf(reported) === -1`), o código caía cegamente no fallback `indexes[0]` (workspace 0 / "1").
  - **Correções Aplicadas**:
    1. *`dwm-quickshell-state`*:
       - Unificado o `xprop -root -spy` para escutar incondicionalmente `_NET_CURRENT_DESKTOP`, `_DWM_MONITOR_DESKTOPS`, `_DWM_SELECTED_MONITOR`, `DWM_TAG_UPDATE` e demais propriedades EWMH.
       - Envelopado com `stdbuf -oL -eL` (GNU Coreutils) para forçar line-buffering imediato no pipe, liberando cada evento no milissegundo em que ocorre.
       - Adicionado fallback para `xdotool set_desktop` e `xdotool windowactivate` caso o `wmctrl` falhe ou não esteja disponível.
    2. *`DwmState.qml`*:
       - Adicionada atualização otimista instantânea de `root.currentWorkspace` e `root.monitorWorkspaceRows[logicalIndex].desktop` ao clicar no workspace, eliminando latência na interface.
       - Tratado o ciclo de vida do `switchWorkspaceProcess` (rearmando `running = false` antes de atribuir novo comando).
       - Atualizado `workspaceIndexes` para exibir todos os 9 workspaces em telas únicas (`screenCount <= 1`).
       - Robustecido o retorno de `currentWorkspaceForScreen` para validar tipos numéricos e evitar fallback falso para 0.
    3. *`dwm.c`*: Em `updatecurrentdesktop()`, adicionada a emissão de `DWM_TAG_UPDATE` (`dwmtagupdateatom`) e chamada explícita de `XFlush(dpy)` para garantir que as alterações no servidor X11 sejam propagadas imediatamente para os clientes sem reter buffers no Xlib.
    4. *`packages.nix`*: Declarado `xorg.xprop` explicitamente em `home.packages`.

- **DWM & Quickshell — Validação da Barra, Geometria Tiled, Window Rules e Hotkeys**:
  - **Diagnóstico do Sintoma Temporário (Barra encoberta em tiled pré-reboot)**:
    - Ocorreu devido a um descompasso de processos em tempo de execução: o diretório `~/.config/quickshell` possui hot reload ativo e recarregou `DwmState.qml` e `dwm-quickshell-state` imediatamente após as edições; porém, o processo `dwm` ainda era a instância antiga em execução na memória RAM (que não tinha os novos átomos e o handler compilado sincronizado).
    - Após o reinício (`reiniciei e voltou`), o binário recém-compilado do `dwm` subiu em conjunto com o `quickshell`, reativando perfeitamente o ciclo de descoberta de altbar (`scanaltbars` e `updatealtbar`), a reserva de altura do painel (`m->bh` e `m->wy = m->my + m->bh`) e a regra de restack onde janelas tiled são sempre alocadas abaixo da barra (`wc.stack_mode = Below`, `wc.sibling = m->barwin`).
  - **Correção em `window-rules.toml` (`isfloating`)**:
    - Identificada incompatibilidade na regra `{ class="RAIL", float=1 }`. O parser TOML do `dwm.c` (linha 3869) busca estritamente o atributo `isfloating` (`toml_table_get(&doc, "rules", i, "isfloating")`). O atributo `float` era silenciosamente ignorado, fazendo com que janelas com classe `RAIL` abrissem em modo tiled em vez de floating.
    - Corrigido para `{ class="RAIL", isfloating=1 }`.
  - **Correção de Colisão em `hotkeys.toml` (`SUPER + d` vs `SUPER + u`)**:
    - O atalho `SUPER + d` estava atribuído em dois pontos distintos: na linha 65 para abrir o Rofi (`rofi -show drun`) e na linha 161 para remover janelas do master (`incnmaster`, `i=-1`).
    - Devido à ordem de captura no X11 (`XGrabKey`), a função de `incnmaster -1` ficava inacessível via teclado. Reatribuído para `SUPER + u` (par harmônico e adjacente a `SUPER + i` para incremento do master).
  - **Validação de Fullscreen e Altbar**:
    - Em `dwm.c`, `updatefullscreenmonitors()` emite o átomo `_DWM_FULLSCREEN_MONITORS`. Em ausência de janelas em tela cheia, envia 0 elementos, fazendo o script `dwm-quickshell-state` enviar `fullscreen_monitors=` vazio.
    - No QML (`DwmPanel.qml`), `aboveWindows: root.state.fullscreenMonitorIndexes.indexOf(root.state.screenIndex(root.screen)) === -1` é avaliado como `true`, mantendo a barra do Quickshell no topo em janelas normais (tiled ou flutuantes) e ocultando-a apenas sob tela cheia real ou ao acionar o atalho `SUPER + m` (que alterna o layout para monocle e aciona `togglebar`, transladando a barra para fora da tela com `selmon->by = -selmon->bh`).

- **DWM & Quickshell — Desbloqueio e Correção dos Bar Widgets, Auto Lock e Painéis Read-Only no Control Center / Settings**:
  - **Sintomas Reportados**:
    1. No Control Center, os widgets da barra (Workspaces, Volume, Bluetooth, Network, Power) não eram clicáveis para habilitar ou desabilitar.
    2. A opção de Auto Lock no Control Center também não era clicável (mostrava "Unknown" ou ficava desabilitada).
    3. No Control Center Settings, muitas opções de configuração apareciam desabilitadas ou marcadas como somente leitura ("Theme changes are read-only", personalização sem permissão de escrita, notificações desvinculadas, etc.).
  - **Causas Raízes Identificadas**:
    1. *Verificação Estrita de Permissões Unix (`umask 002`)*:
       - Em `dwm-panel-settings` e `dwm-accessibility-settings`, as funções `config_dir_safe()` e `state_file_safe()` exigiam `(((8#$mode & 022) == 0))`.
       - Em distros com umask padrão de usuário (002/022), pastas e arquivos criados com escrita para grupo (modos `775` e `664`) falhavam no teste de segurança `022`.
       - Isso fazia com que `dwm-panel-settings status` retornasse `state unavailable`, levando `PanelSettingsModel.qml` a definir `mutationReady = false`. Consequentemente, no `ControlCenterWindow.qml`, a expressão `enabled: root.controlCenterModel.panelSettingsModel.mutationReady` desabilitava os cliques de todos os 5 widgets.
    2. *Arquivos de Configuração Vazios (0 Bytes)*:
       - No hook anterior `activation.setupDwmConfig` do `dwm.nix`, os arquivos de estado eram criados com `touch` quando ausentes.
       - Arquivos de 0 bytes como `panel-widgets.conf`, `font.conf`, `accessibility.conf` ou `notification-settings.json` faziam com que os parsers de estado (como `dwm-settings-font` e `dwm-panel-settings`) acusassem arquivo incompleto ou corrompido (`state partial` / `invalid`), travando a reatividade dos modelos QML.
    3. *Falta de Pacotes Essenciais para Bloqueio de Tela (Auto Lock)*:
       - `dwm-quickshell-controlcenter` exigia `xset`, `light-locker` e esquemas do GSettings.
       - Os pacotes `xorg.xset`, `lightlocker`, `xss-lock`, `glib` (`gsettings`) e `dconf` não estavam declarados no `packages.nix`.
       - Sem `xset`, `power_xset_available=0` e `power_lock_available=0`, deixando o Auto Lock com status `Unknown` e `enabled: false`.
    4. *Colisão do Daemon D-Bus de Notificações (Dunst vs Quickshell)*:
       - O módulo `dunst.nix` ativava o serviço systemd do Dunst incondicionalmente em `desktop.dwm.enable`.
       - O Dunst assumia a interface D-Bus `org.freedesktop.Notifications`, impedindo o `NotificationServer` embutido do Quickshell de inicializar.
       - Como consequência, o `dwm-settings-provider` detectava um proprietário estranho no D-Bus e emitia a capacidade como `accessibility-notifications partial read-only`.
    5. *Dependências Ausentes de Configurações*:
       - `dwm-settings-personalization`: Exigia `gsettings` e `dconf` para testar escrita nas chaves de interface do GNOME (`org.gnome.desktop.interface`). Sem `dconf`, reportava opções como `read-only`.
       - Text Scaling / XSettings: Exigia `xsettingsd` e `dump_xsettings` para ajuste dinâmico de DPI.
       - Autostart: Exigia `inotifywait` (`inotify-tools`) para monitoramento ao vivo, caindo em estado `partial`.
       - Acessibilidade do Teclado: Exigia `xkbset` para controles de acessibilidade XKB.
  - **Correções Aplicadas**:
    1. *Templates Completos Pré-Provisionados*:
       - Criados e consolidados todos os arquivos de configuração modelo em `modules/home-manager/desktop/environments/dwm/configs/config/` (`panel-widgets.conf`, `accessibility.conf`, `notification-settings.json`, `wallpaper.conf`, `font.conf`, `personalization.conf`, `theme-env.sh`, `cursor.Xresources`, `xsettingsd.conf`).
    2. *Auto-Cura de Permissões (`Self-Healing`)*:
       - Em `dwm-panel-settings` e `dwm-accessibility-settings`, `config_dir_safe()` e `state_file_safe()` agora executam `chmod go-w` automaticamente caso o diretório/arquivo pertença ao usuário corrente e possua o bit de grupo ativo, eliminando falsos negativos de permissão.
    3. *Provisionamento no `dwm.nix`*:
       - Em `setupDwmConfig`, a verificação de arquivos foi aprimorada: caso o arquivo não exista ou esteja vazio (`[ ! -s ... ]`), o template válido correspondente é copiado de `${./configs/config}/$cfg_file`.
       - Aplicadas permissões `chmod 700` no diretório e `chmod 600` / `go-w` em todos os arquivos de configuração.
       - Removida a referência espúria a `display-profiles.json`.
    4. *Resolução do Auto Lock*:
       - Adicionado fallback em `dwm-quickshell-controlcenter` (`power_status`, `start_configured_light_locker`, `stop_configured_light_locker`, `power_apply_lock_settings`): se `light-locker` não estiver presente ou seus esquemas GSettings não estiverem instalados, o sistema utiliza transparentemente `xset` + `xss-lock` com `dwm-lock` / `betterlockscreen` / `i3lock-color`.
       - Adicionada detecção de screen lockers em `dwm-settings-provider`.
    5. *Isolamento de Notificações*:
       - Atualizado o padrão de `desktop.dwm.dunst.enable` em `dunst.nix` para ativar o Dunst apenas se `bar != "quickshell"`.
       - Removido `pkgs.dunst` incondicional do `packages` do `dwm.nix`.
    6. *Pacotes de Suporte Injetados em `packages.nix`*:
       - Adicionados `xorg.xset`, `lightlocker`, `xss-lock`, `glib`, `dconf`, `xkbset`, `inotify-tools` e `xsettingsd`.
    7. *Wiki Completa de Customização do DWM-Titus*:
       - Criada documentação extensiva em [modules/home-manager/desktop/environments/dwm/README.md](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/dwm/README.md) detalhando os três níveis de customização (TOML em tempo de execução, QML em Live Mode com Hot Reload e patches nativos em C), catálogo completo de arquivos, regras de janelas (`window-rules.toml`), paletas de cores (`themes.toml`), atalhos de teclado (`hotkeys.toml`), modelo de segurança/auto-cura de permissões e comandos de diagnóstico, catalogada também no [WIKI.md](file:///home/juca/.dotfiles/nixfiles/WIKI.md).

- **Ativação dos Botões de Aplicar e Preview de Temas, Wallpapers, Fontes e Personalização (Quickshell / DWM)**:
  - **Diagnóstico e Causa Raiz**:
    - No painel `Settings -> Appearance` ([AppearanceSettingsPane.qml](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/dwm/configs/config/quickshell/settings/AppearanceSettingsPane.qml)), os botões de **Preview** e **Apply** de temas dependem de `root.appearanceModel.mutationReady`, de papéis de parede dependem de `root.appearanceModel.wallpaperMutationReady`, e de fontes e personalizações do desktop (cursor, ícones, tema GTK/Qt, escala) dependem de `root.personalizationActionsReady`.
    - Nos modelos QML ([AppearanceModel.qml](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/dwm/configs/config/quickshell/appearance/AppearanceModel.qml)), essas variáveis são alimentadas pelas verificações `dwm-settings-theme mutation-ready`, `dwm-settings-wallpaper status --read-only` (checando `mutation.state === "available"`) e `dwm-settings-personalization status` (que chama `dwm-settings-theme personalization-ready`).
    - Os scripts originais continham travas excessivamente estritas para atualizações atômicas:
      1. Exigência obrigatória de flags GNU coreutils 9.5+ no comando `mv` (`--exchange`, `--no-copy`, `--backup=none-fail` / `--update=none-fail`). Em sistemas Linux com coreutils < 9.5 ou onde o `mv` padrão não expõe tais flags, a verificação acionava `die 'required GNU mv options are unavailable'` ou retornava `restricted`.
      2. No `dwm-settings-theme`, a checagem de dispositivo `stat -c %d -- "$path"` comparava os IDs de filesystem seguindo symlinks. Qualquer link simbólico apontando para `/nix/store` gerava ID de filesystem divergente do diretório `$HOME`, falhando com `integration file is on a different filesystem from its parent`.
      3. No `dwm-settings-wallpaper` e `dwm-settings-font`, a função `exchange_supported` falhava silenciosamente se `mv --exchange` não estivesse disponível no binário ou no sistema de arquivos subjacente.
  - **Correções Aplicadas**:
    1. *`dwm-settings-theme`*:
       - Removida a exigência estrita de coreutils 9.5 no `validate_atomic_mv_support`.
       - Implementadas funções auxiliares `atomic_file_swap` e `atomic_file_install` com auto-detecção de suporte a `mv --exchange` e fallback automático para renomeação atômica POSIX via arquivo de backup temporário no mesmo diretório (`cp` + `mv -f -T`).
       - Ignorados links simbólicos (`[[ -L $path ]]`) na comparação cruzada de `stat -c %d`, prevenindo falsos positivos causados por arquivos do Nix store.
       - Atualizados todos os pontos de publicação e rollback (`install_prepared_theme`, `publish_integration_outputs`, `restore_integration_file`, `restore_source_file`) para usar `atomic_file_swap` e `atomic_file_install`.
       - Adicionado fallback em PATH para os helpers `dwm-settings-appearance` e `theme-apply.sh` e detecção de `themes.toml` gerenciado.
    2. *`dwm-settings-wallpaper`*:
       - Em `exchange_supported`, adicionado fallback de teste de movimentação atômica (`mv -f -T` / `mv -f`) caso `mv --exchange` não esteja disponível, marcando `result=available`.
       - Em `publish_staged_config`, adicionado fallback atômico com preservação de integridade caso `mv --exchange` falhe, e flexibilizadas as flags de rollback para aceitar `-n -T` ou `--no-clobber`.
    3. *`dwm-settings-font`*:
       - Em `exchange_supported`, flexibilizada a checagem para permitir teste atômico via `mv -f -T` quando `mv --exchange` não estiver presente.
       - Em `publish_config_if_hash` e `remove_config`, implementado fallback seguro de troca atômica e rollback compatível com todas as versões do GNU coreutils.
    4. *`dwm-settings-wallpaper` (Correção de `DISPLAY` e `cached_exchange_supported`)*:
       - **Auto-detecção de `DISPLAY`**: Quando testado via SSH (como `ssh juca@192.168.122.106`), a variável `$DISPLAY` não está definida por padrão. O script falhava na checagem `valid_display "${DISPLAY:-}"`, resultando em `mutation restricted Wallpaper changes are unavailable in this session`. Adicionada auto-detecção de sockets em `/tmp/.X11-unix/X*` com fallback para `:0` e `$HOME/.Xauthority`.
       - **Auto-população do Cache (`cached_exchange_supported`)**: O Quickshell executa `dwm-settings-wallpaper status --read-only`, que invoca `mutation_ready true` -> `cached_exchange_supported`. Caso o cache em `$runtime_dir/exchange-support` ainda não tivesse sido gerado por um comando de escrita prévio, a função falhava e nunca criava o arquivo, mantendo o status `restricted` permanentemente. Corrigido adicionando execução e criação imediata via `exchange_supported` como fallback.
    5. *`dwm-settings-personalization`*:
       - Adicionado fallback dinâmico de localização para `dwm-settings-theme` e `dwm-xsettings` em `~/.local/share/dwm-titus/scripts/` e no `$PATH`.
    6. *`dwm-accessibility-settings` e `dwm-panel-settings` (Remoção da Trava Coreutils 9.5)*:
       - Ambos os scripts continham `mv_exchange_options_supported()` exigindo `--exchange` e `--no-copy`, disparando `GNU mv atomic exchange support is unavailable` em acessibilidade e `GNU mv with --exchange and --no-copy is required` em painéis.
       - Implementado fallback atômico POSIX seguro (`mv -f -T` / `mv -f`) em `mutation_exchange_ready()` e `publish_config()`.
    7. *`dwm-settings-appearance` (Limpeza dos Erros em "Unresolved Details")*:
       - **Cursor**: O upstream exigia `Capitaine-Cursors-White`. Adicionada busca/fallback dinâmico para `catppuccin-mocha-dark-cursors` e `Adwaita` no `dwm-settings-appearance` e `theme-apply.sh`.
       - **Terminal Kitty**: Não emite mais erro de aplicação ausente se o terminal preferencial (`alacritty`) estiver instalado e funcional.
       - **Alacritty Theme Import**: Adicionado `"~/.config/alacritty/active-theme.toml"` em `programs.alacritty.settings.general.import` no `alacritty/default.nix`, satisfazendo `alacritty_imports_active_theme`.
       - **GTK Theme**: Adicionado suporte ao nome de diretório gerado pelo Nixpkgs `catppuccin-mocha-blue-standard+rimless`.
    8. *Procedimento de Ativação no Host `virtualvm` (192.168.122.106)*:
       - No NixOS / Home Manager, apenas reiniciar o sistema não transfere alterações feitas em arquivos da árvore Git local (`~/.dotfiles/nixfiles`) para as pastas de execução do usuário (`~/.local/share/dwm-titus/scripts/` e `~/.config/quickshell/`).
       - É necessário aplicar a configuração com o Home Manager:
         ```bash
         home-manager switch --flake .#juca@virtualvm
         ```
         (ou via NixOS: `sudo nixos-rebuild switch --flake .#virtualvm`)
       - Em seguida, reiniciar o Quickshell com `pkill -x quickshell` para carregar o novo estado com botões 100% ativos e sem erros.

- **DWM & Quickshell — Resolução Definitiva dos Erros de Appearance (Themes, Wallpapers e Fontes no VirtualVM)**:
  - **Problema 1: "Theme changes are read-only" (Protected) & Botões Apply/Preview Desabilitados**:
    - *Causa*: `dwm-settings-theme integration_path_list_for` executava `readlink -f` nos arquivos GTK (`~/.config/gtk-3.0/settings.ini`, `~/.config/gtk-4.0/settings.ini`, `~/.gtkrc-2.0`). No Home Manager, caso ainda fossem symlinks para o Nix store, o caminho resolvia para `/nix/store/...`. A checagem `validate_integration_file` falhava em `stat -c %u == $UID` (pois arquivos no store pertencem ao root, UID 0 != 1000) e o teste de escrita `-w` falhava (`0444`). Isso fazia `mutation_ready` retornar falso, acionando a mensagem *"Inventory and active colors remain available, but a theme source or integration path failed ownership, link, or atomic-update safety checks"* e desabilitando os botões de Preview e Apply de temas.
    - *Correção*:
      - Em `dwm-settings-theme`: `integration_path_list_for` converte dinamicamente qualquer symlink apontando para `/nix/store` em cópia local editável pertencente ao usuário (`cp --remove-destination` + `chmod u+w`) e impede que os caminhos sejam canonicamente substituídos por `/nix/store/*`.
      - Em `validate_integration_file` e `mutation_ready`: caminhos ou symlinks apontando para o Nix store são aceitos como seguros se legíveis, ignorando falhas de ownership do root.
      - Em `theme-apply.sh`: `gtk_ini_edit_path` e `gtk2_edit_path` desvinculam do store e criam arquivos graváveis antes de invocar `mktemp`.
  - **Problema 2: "Wallpaper apply and preview unavailable" & "Wallpaper folder is unavailable: /home/juca/Pictures/backgrounds"**:
    - *Causa*:
      1. Numa instalação limpa ou na VM, a pasta `~/Pictures/backgrounds` não existia por padrão, gerando a mensagem de pasta indisponível.
      2. `dwm-settings-wallpaper status` executava `probe_status_assets`. Com a pasta ausente ou vazia e sem wallpaper pré-configurado, `status_rollback_available` ficava como `false`, acionando a condição `mutation_state=restricted` com a mensagem *"Wallpaper changes require a recoverable current or default wallpaper"*.
    - *Correção*:
      - Em `dwm-settings-wallpaper`: `probe_status_assets` e `apply_default_candidate_paths` criam automaticamente `~/Pictures/backgrounds` caso ausente (`mkdir -p`), incluem na busca diretórios de wallpapers do sistema (`/run/current-system/sw/share/backgrounds`, `/usr/share/backgrounds`, `/etc/backgrounds`) e estabelecem `status_rollback_available=true` como fallback de primeira inicialização quando o utilitário `feh` estiver disponível.
      - Em `dwm-settings-appearance`: `emit_wallpaper_inventory` cria `~/Pictures/backgrounds` e busca wallpapers de sistema se a pasta de usuário estiver vazia.
      - Em `dwm.nix` (`setupDwmConfig`): criado o diretório de estado `~/.local/state/dwm-titus/appearance/wallpaper` e provisionado automaticamente o papel de parede padrão do NixOS (`nixos-artwork.wallpapers.nineish-dark-gray`) em `~/Pictures/backgrounds/nixos-wallpaper.png` se a pasta estiver vazia.
  - **Problema 3: Cartão de Fonte Vermelho ("Cantarell 11 not installed") e Botão "Apply font" Bloqueado**:
    - *Causa*:
      1. O botão "Apply font" depende de `root.personalizationActionsReady`, que requer `personalizationMutationState === "available"`. O status de personalização (`dwm-settings-personalization status`) invocava `dwm-settings-theme personalization-ready` -> `mutation_ready`. Como `mutation_ready` falhava (problema 1), o estado caía em `restricted`, desabilitando o botão de aplicar fonte.
      2. O GSettings vinha com o padrão do GNOME `font-name = "Cantarell 11"`. A família Cantarell não vinha instalada no Nixpkgs básico da VM, levando `dwm-settings-appearance` a emitir *"Configured desktop font family is not installed"* em vermelho.
    - *Correção*:
      - Com a correção de `mutation_ready` no `dwm-settings-theme`, `personalizationMutationState` atinge `available`, desbloqueando os botões **Apply font** e **Follow system font**.
      - Adicionado pacote `cantarell-fonts` em `modules/home-manager/desktop/environments/dwm/packages.nix` e `default.nix`.
      - Em `dwm-settings-appearance`: adicionado fallback gracioso via Fontconfig (`fc-match`) caso uma fonte configurada não esteja instalada no sistema, exibindo *"Following system font (<substituto>)"* com status `available` (verde) sem quebrar o painel.
      - Corrigido fechamento de bloco condicional `fi` em `emit_wallpaper_inventory` (linha 780) que causava `syntax error near unexpected token '}'` ao fechar a função.

- **DWM & Quickshell — Desbloqueio dos Botões de Ação em Fontes ("Apply font", "Follow system font") e Temas ("Apply", "Preview")**:
  - **Sintoma**: No painel `Appearance`, mesmo após a fonte Cantarell estar instalada e o cartão de fontes estar verde, os botões **Apply font** e **Follow system font**, assim como os botões de ação de temas (**Apply** e **Preview for 30 seconds**), permaneciam desabilitados (cinza / não clicáveis).
  - **Causa Raiz Identificada (Efeito Dominó de Validação)**:
    1. **Botões de Tema**: No `AppearanceSettingsPane.qml`, dependem de `root.appearanceModel.mutationReady`, que executa `dwm-settings-theme mutation-ready`.
    2. **Botões de Fonte**: Dependem de `root.personalizationActionsReady`, que verifica `root.appearanceModel.personalizationMutationState === "available"`. O script `dwm-settings-personalization status` consulta `dwm-settings-theme personalization-ready`, que por sua vez invoca `mutation_ready`.
    3. **Falhas em Cadeia no `dwm-settings-theme mutation_ready`**:
       - `existing_path_chain_is_safe`: Rejeitava qualquer caminho cujo diretório pai fosse um symlink (`[[ -d $probe && ! -L $probe ]]`), quebrando pastas gerenciadas pelo Home Manager (ex: `~/.config/kitty`, `~/.config/alacritty`).
       - `directory_path_ready`: Rejeitava symlinks e caminhos com dono `root` (`/nix/store`), falhando a validação de diretórios de integração.
       - `validate_atomic_mv_support`: Iterava sobre todas as 13 ferramentas externas de integração (`kitty`, `alacritty`, `qt6ct`, etc.) executando `mktemp -d` e testes de `mv --exchange` / `mv -T`. Se qualquer uma delas estivesse no store ou em outro ponto de montagem, executava `die`, derrubando `mutation_ready`.
       - `snapshot_for`: Executava `"$appearance_helper" snapshot` e chamava `die` se o status de saída fosse diferente de 0, descartando a listagem de temas mesmo quando válida.
    4. **Validação do GSettings em Sessão X11 (`gsettings_key_ready`)**:
       - `gsettings writable "$schema" "$key" | grep -Fqx true` falhava em sessões X11 sem o daemon de bloqueio do dconf ativo no D-Bus, gerando `apply_state=restricted` e `reset_state=restricted`.
  - **Correções Aplicadas**:
    - Em `dwm-settings-theme`:
      - `existing_path_chain_is_safe`: Permite symlinks desde que resolvam para diretórios válidos (`[[ -d $probe ]]`).
      - `directory_path_ready`: Aceita diretórios symlinked e caminhos em `/nix/store/*` se forem legíveis/executáveis.
      - `mutation_ready`: Validações de arquivos de integração opcionais utilizam `continue` em vez de abortar todo o motor de temas; chamada a `validate_atomic_mv_support` protegida com `|| true`.
      - `validate_atomic_mv_support`: Escopo enxuto testando exclusivamente o diretório de temas e de personalização (`~/.config/dwm-titus`), sem probes invasivos nas pastas de outros aplicativos.
      - `snapshot_for`: Captura a saída e, se contiver registros de tema (`theme\t`), aceita com sucesso sem morrer por status auxiliar do snapshot.
    - Em `dwm-settings-personalization`:
      - `gsettings_key_ready`: Verifica se o valor é legível e NÃO está restrito por política administrativa (`! grep -Fqx false`), eliminando falsos restritos.
      - `status`: Garante `mutation_state=available` quando o diretório do usuário `~/.config/dwm-titus` for gravável.

- **Fontes Locais em `pkgs/fonts` (`abel`, `bebasNeue`, `fantezy-font`) & `Makefile`**:
  - **Problema**: A instalação de `pkgs.abel` (ou outras fontes locais) falhava com `nom-build: command not found` durante `switch-home`.
  - **Causa Raiz**: Esses pacotes utilizam `src = ./.`, copiando os arquivos locais para a sandbox. Pela presença de um `Makefile` de desenvolvimento (`nom-build -E ...`) na pasta e a ausência de `dontBuild = true;`, o `stdenv.mkDerivation` executava automaticamente a fase de build (`make`), acionando o target do Makefile que não existe no sandbox.
  - **Correção**: Adicionado `dontBuild = true;` nas derivações `pkgs/fonts/abel/default.nix`, `pkgs/fonts/bebasNeue/default.nix` e `pkgs/fonts/fantezy-font/default.nix`.
- **Módulo `programs.git` (Home Manager 24.11+)**:
  - As opções `userName`, `userEmail`, `aliases` e `extraConfig` foram consolidadas sob `programs.git.settings` (`settings.user.name`, `settings.user.email`, `settings.alias` e configurações diretas de INI), eliminando avisos de depreciação durante o switch do Home Manager.

- **Módulo `system.programs.browsers` (Seleção de Navegador Padrão e XDG MIME)**:
  - **Arquitetura**: O módulo centralizador `modules/home-manager/system/programs/browsers/default.nix` agora gerencia declarativamente a seleção do navegador padrão e sua associação a tipos MIME e variáveis de ambiente:
    - **Opções Adicionadas**:
      - `system.programs.browsers.enable`: Habilita o ecossistema (instalando fontes auxiliares e codecs `ffmpeg` apenas se algum navegador estiver ativo).
      - `system.programs.browsers.default`: Enum `[ "auto" "firefox" "chrome" "chromium" "none" ]` (default `"auto"`).
      - Flags booleanas `default` individuais em `system.programs.browsers.firefox` e `system.programs.browsers.chromium`.
    - **Associação XDG MIME**: Quando um navegador padrão é determinado (`activeDesktopFile != null`), associa automaticamente via `xdg.mimeApps.defaultApplications`: `text/html`, `text/xml`, `application/xhtml+xml`, `application/xml`, `application/x-xpinstall`, `x-scheme-handler/http`, `x-scheme-handler/https`, `x-scheme-handler/about`, `x-scheme-handler/unknown` e `x-scheme-handler/chrome` (para Chromium).
    - **Variáveis de Sessão**: Exporta `BROWSER` e `DEFAULT_BROWSER` com o binário executável correspondente (`firefox`, `brave`, `vivaldi`, `google-chrome-stable`, etc.), integrando-se aos atalhos do sxhkd e scripts de sistema.

- **Módulo `system.programs.editors.gedit` (Substituição do ZITEXT pelo Gedit)**:
  - **Motivação**: ZITEXT apresentava instabilidade gráfica em VMs (Tauri/WebKitGTK). Foi removido e substituído pelo **gedit** (`pkgs.gedit`), que é nativo em GTK, ultraleve e 100% estável em qualquer ambiente (físico ou virtual).
  - **Módulo Home Manager (`modules/home-manager/system/programs/editors/gedit/default.nix`)**:
    - `system.programs.editors.gedit.enable`: Habilita o editor nos pacotes do usuário (`pkgs.gedit`). Ativado por padrão em estações de trabalho (`isWorkstation`) em [modules/home-manager/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/default.nix).
    - `system.programs.editors.gedit.default` (booleano, default `true`): Associa `org.gnome.gedit.desktop` como handler padrão de `text/plain` em `xdg.mimeApps.defaultApplications` e `xdg.mimeApps.associations.added`, além de exportar `EDITOR = "gedit"`.
    - Totalmente declarativo e limpo, sem scripts imperativos de ativação ou cópia de arquivos.
  - **DWM Quickshell — Resolução de Symlinks no `dwm-default-apps` ("Not configured" / "Configured desktop entry is missing")**:
    - *Causa Raiz*: O script do Quickshell `dwm-default-apps` rejeitava qualquer diretório que contivesse links simbólicos no caminho (`! path_has_no_symlink_components "$applications"`) e qualquer arquivo `.desktop` que fosse um link simbólico (`[[ -f $file && ! -L $file ]]` e `find` sem `-L`). No ecossistema NixOS / Home Manager, todos os perfis (`/run/current-system/sw`, `~/.nix-profile`, `~/.local/state/nix/profiles/home-manager`) são symlinks, o que fazia com que Firefox, Alacritty, Thunar e todos os handlers MIME fossem rejeitados e exibidos como "Not configured".
    - *Correção*: Em `modules/home-manager/desktop/environments/dwm/configs/scripts/dwm-default-apps`, as verificações estritas que impediam symlinks em diretórios de leitura de `.desktop` foram removidas em `desktop_file_for_id`, `emit_candidates` e `parse_desktop_file`, e a busca foi atualizada para seguir links (`find -L`). Com isso, todos os pacotes gerenciados pelo NixOS e Home Manager são imediatamente reconhecidos e associados no painel Defaults do Quickshell.
  - **Limpeza Centralizada no `system.cleanup` (`modules/home-manager/system/cleanup/default.nix`)**:
    - Remoção de qualquer lógica ad-hoc de deleção dentro de módulos específicos de aplicativos.
    - O aplicativo `zitext` foi registrado na lista `knownApps` com `enabled = false`, fazendo com que o utilitário `clean-orphaned-configs` (executado a cada switch) purgue automaticamente `.desktop` residuais (`~/.local/share/applications/zitext*.desktop`), configurações, caches e dados locais.
  - **Live ISOs & NixOS Users (`users.users.<name>.shell`)**:
    - *Problema*: Na compilação e avaliação de Live ISOs (`iso-xfce4`, `iso-gnome`), ocorria `error: The option users.users.nixos.shell is defined multiple times while it's expected to be unique.`
    - *Causa*: O módulo upstream do NixOS `users-groups.nix` atribui `shell = mkDefault (if u.isNormalUser then config.users.defaultUserShell else ...)` (prioridade 1000). Em `nixos/users/default.nix`, havia `shell = lib.mkDefault pkgs.bash;` (também prioridade 1000). Em perfis onde o usuário não sobrescreve com prioridade normal (como o usuário `nixos` nas ISOs), a colisão de dois `mkDefault` gerava o erro de unicidade da opção.
    - *Correção*: Removida a atribuição redundante `shell = lib.mkDefault pkgs.bash;` em `nixos/users/default.nix`, permitindo que o NixOS defina naturalmente a shell a partir de `config.users.defaultUserShell` (`pkgs.bashInteractive`), eliminando a colisão.

- **Módulo `system.services.podman` (Home Manager - Containers Rootless & Docker Compat)**:
  - **Localização**: [modules/home-manager/system/services/podman/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/system/services/podman/default.nix) e documentação em [modules/home-manager/system/services/podman/README.md](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/system/services/podman/README.md).
  - **Design & Boas Práticas**:
    - **Integração com `services.podman` Upstream do Home Manager**:
      - Habilita diretamente o módulo nativo `services.podman.enable = true` e repassa `package`, `containers`, `networks`, `volumes` e o timer `autoUpdate.onCalendar`.
      - Qualquer container declarado em `system.services.podman.containers` ou diretamente em `services.podman.containers` é processado pelo gerador Quadlet oficial do Home Manager.
    - **Rootless & Portabilidade**: Configurado em espaço de usuário com isolamento via subuid/subgid. Funciona tanto no NixOS quanto em distros standalone (Fedora, Debian, Ubuntu).
    - **Injeção de Helpers OCI no Nix Store**: `helper_binaries_dir` no `containers.conf` injeta `${pkgs.crun}/bin`, `${pkgs.conmon}/bin`, `${pkgs.passt}/bin`, `${pkgs.slirp4netns}/bin` e `${pkgs.fuse-overlayfs}/bin`, garantindo que o Podman sempre encontre suas ferramentas auxiliares independentemente de variações do `$PATH` do host.
    - **Performance & Modernidade**: Runtime `crun`, pilha de rede `pasta` (alta velocidade), logging `k8s-file` (evita poluir o journald), compressão de imagens `zstd`, `cgroup_manager = "systemd"`.
    - **Emulação Docker 100% Transparente (`dockerCompat = true`)**:
      - Socket systemd do usuário ativado sob demanda (`podman.socket` -> `%t/podman/podman.sock`).
      - Symlink automático `%t/docker.sock -> %t/podman/podman.sock` gerenciado via `systemd.user.tmpfiles.rules` e hook de ativação.
      - Variável `DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock"` exportada na sessão do usuário e no systemd.
      - Wrapper executável `docker` que despacha para `podman`, garantindo compatibilidade com DevContainers do VSCode, JetBrains, DBeaver e scripts CI/locais.
    - **Registries & Política de Imagens**: Busca em `docker.io`, `quay.io`, `ghcr.io` e `registry.fedoraproject.org` com `short-name-mode = "permissive"` e `policy.json` permissivo em `~/.config/containers/`, prevenindo erros de bloqueio de assinatura ao puxar imagens públicas.
    - **Ferramental Completo Incluso**: `podman-compose`, `docker-compose`, `lazydocker` (TUI interativa rica), `podman-tui`, `buildah`, `skopeo` e `dive`.
    - **Diagnóstico Embutido**: Utilitário executável `podman-doctor` para testar rapidamente subuids, socket ativo, DOCKER_HOST e execução de container alpine.
    - **Requisito Host no Debian/Ubuntu Standalone (`newuidmap` / `uidmap`)**:
      - Em distros standalone (como Debian no host `nitro`), o Podman rootless necessita de `newuidmap` e `newgidmap` com bit **setuid** (`4755 root:root`) para alocar intervalos de `subuid` e `subgid`. Binários do Nix Store não possuem privilégios setuid no Home Manager do usuário.
      - Resolução no host: `sudo apt install -y uidmap` e configuração de subuids: `sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER && podman system migrate`.
    - Ativado por padrão para o usuário `juca` via `system.services.podman.enable = lib.mkDefault true;` em [home-manager/users/juca/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/home-manager/users/juca/default.nix).

- **BSPWM e SXHKD — Correções de Navegador, Scratchpad (tdrop), Screenshots por Máquina e Workspaces**:
  - **Navegador Padrão (`${mod} + b`)**: Vinculado declarativamente ao `config.system.programs.browsers.activeBin` configurado no ecossistema (Firefox, Brave, Vivaldi, Google Chrome, etc.), eliminando checagens desnecessárias e garantindo execução direta do navegador padrão escolhido.
  - **Terminal Scratchpad Flutuante (`${mod} + u`)**:
    - *Problema*: `tdrop` sem classe específica e sem flag de nome capturava janelas normais do Alacritty ou falhava ao alternar.
    - *Correção*: Configurado `tdrop -am -w 80% -h 50% -x 10% -y 5% -s dropdown -n bspwm-scratch alacritty --class bspwm-scratch,bspwm-scratch`.
    - Adicionada regra `bspc rule -a bspwm-scratch state=floating sticky=on` no `bspwm.nix` e no script `bspwm-external-rules`, isolando completamente o scratchpad dos terminais normais de trabalho.
  - **Atalhos de Captura de Tela (Flameshot) Configuráveis por Máquina (`desktop.bspwm.sxhkd.screenshotProfile`)**:
    - *Problema*: Os atalhos hardcoded estilo macOS (`Super + Shift + 3 / 4 / 5`) colidiam com o envio de janelas para as áreas de trabalho 3, 4 e 5 em PCs normais (Acer Nitro, VMs, etc.). Além disso, a pasta de salvamento divergia da padronizada no módulo Flameshot (`~/Pictures/Screenshots`).
    - *Correção*:
      - Criada opção `desktop.bspwm.sxhkd.screenshotProfile` (`"auto"`, `"standard"`, `"mac"`, `"custom"`, `"none"`).
      - Perfil `"standard"` (Acer Nitro, VMs, Fedora, Debian): utiliza exclusivamente `Print` (GUI), `Shift + Print` (tela cheia direta para `savePath`), `Ctrl + Print` (clipboard) e `Super + Print`, deixando `Super + Shift + 1..0` 100% livres para gerenciamento de janelas.
      - Perfil `"mac"` (MacBooks como Rocinante e teclados Apple sem tecla Print dedicada): mantém `Super + Shift + 3/4/5`.
      - Perfil `"auto"`: detecta se o teclado é Apple/Macbook ou PC e ativa o perfil correto automaticamente.
      - Padronizado o salvamento em tela cheia com `config.services.flameshot.settings.General.savePath` (`~/Pictures/Screenshots`).
    - **Diagnóstico e Suporte a Teclados Externos (Logitech MX Keys no Nitro 5)**:
      - *Causa Raiz*:
        1. O teclado **Logitech MX Keys** não possui uma tecla física rotulada como `PrtSc`/`Print`. Ele possui um botão dedicado com ícone de câmera (acima do `Insert`), que o firmware/hardware transmite nativamente em sistemas PC/Linux como a combinação `Super + Shift + S` (atalho da ferramenta de captura do Windows) ou `XF86SelectiveScreenshot` (via driver HID++ do kernel/Solaar). No modo Mac (`Fn + O`), transmite `Super + Shift + 4`.
        2. No host `nitro`, a tecla modificadora principal (`desktop.modifierKey`) é configurada como `"Alt"`, fazendo com que `${mod} + Print` resolvesse para `alt + Print`. Além disso, no Linux X11, segurar Alt ao pressionar Print Screen no teclado do notebook gera o keysym especial `Sys_Req`.
        3. O sxhkd escutava apenas `Print`, `shift + Print`, `ctrl + Print` e `${mod} + Print`, ignorando silenciosamente qualquer acionamento do botão do MX Keys.
      - *Solução*:
        - Expandido o perfil `"standard"` no `sxhkd.nix` para incluir explicitamente:
          - `super + shift + s` e `alt + shift + s`: acionamento universal do botão de câmera do MX Keys e atalho padrão Windows/GNOME Snipping Tool para `flameshot gui`.
          - `XF86SelectiveScreenshot`: mapeamento direto de eventos multimídia/HID++ emitidos pelo Solaar/kernel.
          - `Sys_Req` e `alt + Sys_Req`: captura física no teclado embutido do laptop quando Alt é pressionado.
          - `super + Print` e `alt + Print`: garantia de disparo com qualquer tecla modificadora.
          - Em hosts onde `mod != "super"` (como o Nitro onde `mod` é `Alt`), adicionados também `super + shift + 3/4/5` como fallback adicional caso o MX Keys esteja alternado para modo Mac (`Fn + O`), sem gerar colisão com a troca de áreas de trabalho (que no Nitro usam `Alt + Shift + 1..0`).
  - **Mover e Enviar Janelas para Outra Workspace (`bspc node -d`)**:
    - *Causa Raiz da Falha*:
      1. Os atalhos `${mod} + shift + 3/4/5` eram sequestrados pelo Flameshot hardcoded.
      2. No BSPWM, seletores de desktop sem prefixo de monitor (`bspc node -d 'X'`) limitam a busca ao monitor focado atual; em setups multi-monitor (onde a tela primária possui 1, 3, 5, 7, 9 e a secundária possui 2, 4, 6, 8, 0), tentar enviar uma janela para o outro monitor falhava com `No such desktop: X`.
    - *Correções*:
      - Criado script `bspwm-desktop-focus`: tenta focar diretamente no monitor atual; caso o workspace esteja em outro monitor, localiza o monitor correspondente via `bspc query -M` e foca o monitor e o workspace com sucesso (`${mod} + {1-9,0}`). Substitui a sintaxe inválida `any:{1-9,0}` que causava falha silenciosa no `bspc`.
      - Criado script `bspwm-node-to-desktop`: resolve o ID global do desktop em qualquer monitor via `bspc query -D` e transfere a janela com foco (`--follow`) para `${mod} + shift + {1-9,0}` ou em segundo plano para `${mod} + ctrl + {1-9,0}`.

- **Polybar do BSPWM — Modernização Visual e Estética Inspirada no Waybar (Hyprland / MangoWM)**:
  - *Problema*: A configuração anterior tentava emular cápsulas (*gh0stzk style*) usando glifos de fonte Powerline `` (`bi`) e `` (`bd`). Como a renderização de fontes varia conforme DPI e tamanho da barra (30px vs glifo de 17pt), isso gerava recortes serrilhados, artefatos circulares escuros, blocos retangulares conflitantes nas workspaces (ex: Pacman `󰮯` e fantasmas `󰊠`) e 6 ilhas desconectadas na direita sobre um fundo transparente.
  - *Solução & Nova Arquitetura*:
    - **Barra Flutuante Unificada (`bar/main`)**: Redesenhada como um card flutuante moderno (`width = 99.2%`, `offset-x = 0.4%`, `offset-y = 6`, `height = 32`, `radius = 10`), com fundo Catppuccin Mocha Base (`#1e1e2e`), texto suave (`#cdd6f4`) e borda sutil de 1px em `surface0` (`#313244`). O `top_padding` do BSPWM foi atualizado para `42px` para acomodar o respiro ideal.
    - **Workspaces em Kanji (一 a 九 e 〇)**: Mapeamento declarativo via `ws-icon-*` de 1 a 9 em numerais Kanji (`一 二 三 四 五 六 七 八 九`) e o workspace 0 representado pelo Kanji de zero `〇` (`ws-icon-9 = "0;〇"` e `ws-icon-10 = "10;〇"`). O workspace focado recebe um badge limpo em Azul Catppuccin (`#89b4fa`) com texto escuro e negrito; os ocupados usam texto claro sobre o fundo da barra sem caixas escuras artificiais, e os vazios ficam em tom atenuado discreto (`surface1`). Adicionados os pacotes de fontes `pkgs.noto-fonts-cjk-sans` e `pkgs.ipafont` em `packages.nix` e declaradas `Noto Sans CJK JP / SC` e `IPAGothic` na lista de fontes da Polybar para renderização nítida. Mantida compatibilidade total com os atalhos `${mod} + {1-9,0}` e clique do mouse.
    - **Separação Coesa com Divisores Finos (`sep`)**: Adicionados divisores elegantes `│` (`#45475a`) sem `label-background = transparent` e com `pseudo-transparency = false`, eliminando os recortes pretos de transparência em compositores X11/Picom.
    - **Distribuição Balanceada dos Módulos**:
      - *Esquerda*: `launcher` (logo NixOS `󱄅` azul) + `bspwm` (workspaces limpas) + `sep` + `polywins` (taskbar interativa com ícone `` para terminal e status das janelas).
      - *Centro*: `media` (widget dinâmico do playerctl com prefixo de nota musical `󰎈` e cor lavanda, sem cápsulas duras).
      - *Direita*: Grupo de Hardware (`cpu` celeste, `memory` verde, `temperature` dinâmico com cores por faixa térmica) + `sep` + Conectividade (`network` com Wi-Fi/Ethernet e `bluetooth`) + `sep` + Áudio/Bateria (`pulseaudio` e `battery`) + `sep` + Status e Energia (`keyboard`, `date` e `powermenu`).
    - **Compatibilidade Preservada**: Todos os módulos e scripts legados (`bi`, `bd`, `dots`, `minimized`, `netspeed`, `redshift`) foram mantidos intactos no código para quem desejar alternar no futuro.

- **Módulo Fcitx5 e Entrada Multilíngue (Japonês / CJK / Mozc)**:
  - **Localização**: [modules/home-manager/system/services/fcitx5/default.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/system/services/fcitx5/default.nix), ativado via `system.services.fcitx5.enable = true`.
  - **Integração Home Manager**: Configurado via `i18n.inputMethod.type = "fcitx5"`, instalando automaticamente `fcitx5-with-addons` com:
    - `fcitx5-gtk`: Integração com aplicações GTK2, GTK3 e GTK4.
    - `fcitx5-mozc`: Motor japonês Google Mozc (conversão fonética de Romaji para Hiragana, Katakana e Kanji).
    - `fcitx5-hangul`: Motor para Coreano.
    - `qt6Packages.fcitx5-chinese-addons`: Motor para Chinês Pinyin (migrado de `fcitx5-chinese-addons` para `qt6Packages`).
    - `qt6Packages.fcitx5-configtool`: Interface gráfica de ajustes (`fcitx5-config-qt`, migrado de `fcitx5-configtool` para `qt6Packages`).
    - Fontes essenciais incluídas: `noto-fonts-cjk-sans` e `ipafont`.
    - **Overlay de Compatibilidade (`overlays/default.nix`)**: O Nixpkgs converteu `fcitx5-with-addons`, `fcitx5-configtool` e `fcitx5-chinese-addons` para `throw` no `aliases.nix` ao migrá-los para o Qt6. Foi adicionado overlay de compatibilidade mapeando esses atributos para seus equivalentes em `qt6Packages`, prevenindo quebras internas no módulo de `inputMethod` do Home Manager.
    - **Prevenção de Colisão no `buildEnv`**: O wrapper `fcitx5-with-addons` já extrai e empacota automaticamente os binários e arquivos `.desktop` de todos os seus addons (incluindo `/bin/fcitx5-config-qt`). Portanto, `fcitx5-configtool` não deve ser incluído diretamente em `home.packages` para evitar colisão de caminhos (`two given paths contain a conflicting subpath: /bin/fcitx5-config-qt`).
  - **Variáveis de Ambiente Automáticas**: Exportados `GTK_IM_MODULE = "fcitx"`, `QT_IM_MODULE = "fcitx"`, `XMODIFIERS = "@im=fcitx"`, `SDL_IM_MODULE = "fcitx"` e `GLFW_IM_MODULE = "ibus"`.
  - **Configuração Declarativa Pronta para Uso**:
    - `~/.config/fcitx5/profile`: Configura grupo padrão combinando layout do teclado principal (`keyboard-us` ou nativo) com o motor `mozc`.
    - `~/.config/fcitx5/config`: Configura as teclas de alternância rápida:
      - `Control + Space`: Alterna instantaneamente entre o teclado normal e o modo japonês Mozc.
      - `Super + Space`: Alterna entre grupos de entrada.
      - `Zenkaku_Hankaku` / `Hangul`: Suporte a teclas físicas de teclados CJK.
  - **Bluetooth no Debian (Nitro 5) — Pareamento de Teclados (Logitech MX Keys) e Mouses**:
  - **Causa Raiz da Senha Ausente**:
    - O teclado Logitech MX Keys (e dispositivos BLE) opera em modo de segurança `KeyboardOnly`. O teclado **não gera o PIN**; o **computador (BlueZ)** gera uma Passkey de 6 dígitos e aguarda um agente Bluetooth (`org.bluez.Agent1`) exibi-la na tela para ser digitada no teclado físico seguido de `<Enter>`.
    - Ao tentar parear via scripts da barra (como o menu Rofi anterior) ou sem um agente gráfico ativo no BSPWM, o `bluetoothctl pair` rodava em background sem terminal e sem agente D-Bus registrado, fazendo a senha ser descartada silenciosamente e resultando em timeout de pareamento.
  - **Ajustes Implementados**:
    - Adicionado `pkgs.blueman` em [modules/home-manager/desktop/environments/bspwm/packages.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/packages.nix).
    - Inicialização do `blueman-applet` incluída no startup do [bspwm.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/bspwm.nix): o applet roda residente na sessão do usuário e atua como Bluetooth Authentication Agent permanente, abrindo caixas de diálogo modais com o PIN de pareamento sempre que requisitado.
    - Adicionada opção *"Gerenciador Bluetooth (Blueman)"* no menu Rofi da Polybar ([scripts.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/polybar/scripts.nix)), abrindo a interface completa do `blueman-manager`.
  - **Pareamento Imediato via Terminal**:
    - Para parear o MX Keys de forma garantida e instantânea pelo terminal:
      ```bash
      bluetoothctl
      power on
      agent KeyboardOnly
      default-agent
      scan on
      pair <MAC_DO_MX_KEYS>       # Digitar no MX Keys a Passkey de 6 dígitos exibida no terminal + Enter
      trust <MAC_DO_MX_KEYS>      # Essencial para reconectar no boot/wake automaticamente
      connect <MAC_DO_MX_KEYS>
      ```
  - **Pareamento de Mouse (MX Master / Pebble / etc.)**:
    - O mouse utiliza pareamento BLE "Just Works" (sem senha). Deve ser colocado em modo de descoberta (segurar o botão Easy-Switch por 3s até piscar rápido) e pareado com:
      ```bash
      pair <MAC_DO_MOUSE>
      trust <MAC_DO_MOUSE>
      connect <MAC_DO_MOUSE>
      ```
  - **Requisitos de Sistema no Debian Host**:
    - Pacotes Debian: `sudo apt install bluez blueman`
    - Serviço BlueZ ativo: `sudo systemctl enable --now bluetooth`
    - Desbloqueio de rádio: `rfkill unblock bluetooth`
    - Em `/etc/bluetooth/main.conf`, certificar-se de que `ControllerMode = dual` (nunca `bredr`, pois desativa o Bluetooth Low Energy).

- **Nemo Actions Condicionais (VSCode e Antigravity IDE)**:
  - **Localização**: [modules/home-manager/system/programs/file-manager/nemo/default.nix](file:///mnt/d/workspace/MyRepos/nixfiles/modules/home-manager/system/programs/file-manager/nemo/default.nix).
  - **Comportamento Anterior**: As ações de contexto de clique direito `open-vscode.nemo_action` e `open-antigravity.nemo_action` eram inseridas incondicionalmente em `~/.local/share/nemo/actions/`.
  - **Correção**:
    - Adicionadas verificações booleanas de ativação dos módulos:
      - VSCode: `isVscodeEnabled = (config.system.programs.editors.vscode.enable or false) || (config.programs.vscode.enable or false);`.
      - Antigravity IDE: `isAntigravityEnabled = config.system.programs.editors.antigravity.enable or false;`.
    - O bloco `home.file` foi estruturado com `mkMerge` + `mkIf` para renderizar as ações apenas quando os módulos correspondentes estiverem ativos.
    - Removidos bindings não utilizados do `inherit (lib)` (`mkDefault`, `optionalString`), em conformidade com as diretrizes do repositório.

- **BSPWM SXHKD — Correções no Clique Direito (~button3) e Alternar Mostrar Desktop (${mod} + shift + m)**:
  - **Localização**: [modules/home-manager/desktop/environments/bspwm/sxhkd.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/sxhkd.nix).
  - **Problema 1: `${mod} + shift + m` (Mostrar Desktop / Toggle Minimizar Todas) não funcionava**:
    - *Causa*: O comando estava escrito inline com lógica condicional shell complexa (`if [ $(bspc query ...) -gt 0 ]; then ... fi`). No SXHKD, comandos inline são invocados pelo `$SHELL` do usuário. Em ambientes com `fish` ou shells estritos, substituições `$(...)` e pipelines inline quebram ou falham silenciosamente. Além disso, ao restaurar as janelas (`hidden=off`), o foco ficava perdido na janela raiz.
    - *Correção*: Criado o script `toggleDesktopScript` (`bspwm-toggle-desktop`) via `pkgs.writeShellScript`:
      - Utiliza `/bin/sh` estrito e chamadas diretas a `${pkgs.bspwm}/bin/bspc`.
      - Detecta nós visíveis (`.window.!hidden`) no workspace focado; se houver, oculta todos (`hidden=on`).
      - Se todos já estiverem ocultos, desoculta todas as janelas do workspace (`.window.hidden`) e restaura o foco automaticamente na última janela reexibida com `bspc node "$last_node" -f`.
  - **Problema 2: `~button3` (Clique Direito no Desktop) conflitava com o Thunar e menus de contexto**:
    - *Causa*: O atalho `~button3` utilizava a verificação `if [ -z "$(bspc query -N -n pointed.window)" ]`. Menus de contexto do Thunar (e janelas popups GTK `override-redirect`) não são nós gerenciados pela árvore do BSPWM. Ao clicar com o botão direito no Thunar para abrir o menu de contexto, `bspc query -N -n pointed.window` retornava vazio, fazendo a condição avaliar como verdadeira e abrindo o `quickSettings` (Rofi/Control Center) sobreposto ao menu de opções do Thunar.
    - *Correção*: Criado o script `desktopRightClickScript` (`bspwm-desktop-right-click`) via `pkgs.writeShellScript`:
      - Utiliza `${pkgs.xdotool}/bin/xdotool getmouselocation --shell` e compara o ID da janela sob o cursor (`WINDOW`) diretamente com a Root Window real do X11 (`xdotool getrootwindow`) ou janelas com `_NET_WM_WINDOW_TYPE_DESKTOP`.
      - Se o cursor estiver sobre o Thunar, menus de contexto, Polybar ou qualquer aplicação (`WINDOW != root_win`), o script sai silenciosamente com status 0, permitindo que a aplicação receba o clique com botão direito sem nenhuma interferência.

- **Alacritty — Seleção Fácil com Auto-Copy e Atalhos Condicionais (macOS)**:
  - **Localização**: [modules/home-manager/system/programs/terminal/alacritty/default.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/system/programs/terminal/alacritty/default.nix).
  - **Auto-Copy ao Selecionar (`save_to_clipboard = true`)**: Ao arrastar o mouse ou dar duplo/triplo clique no terminal, o texto selecionado é copiado automaticamente para a área de transferência principal (`CLIPBOARD`), permitindo colar diretamente com `Ctrl+V` em qualquer aplicação.
  - **Atalhos Estilo macOS Condicionais (`isDarwin`)**: Os atalhos com a tecla `Command` (`Command + C` para copiar e `Command + V` para colar) são ativados via `lib.optionals pkgs.stdenv.isDarwin` **exclusivamente em sistemas macOS**. Em sistemas Linux (PC / desktops tradicionais), evita-se conflito com a tecla `Super` utilizada por Window Managers (como `Super + C` para abrir o Control Center no BSPWM).
  - **Atalhos Globais de Terminal e Vi Mode**: Configurados para todas as plataformas: `Control + Shift + C` (Copy), `Control + Shift + V` (Paste) e `Control + Shift + Space` (ToggleViMode para navegação e seleção por teclado com `v`/`y`).

- **Janelas de Login e Autenticação em Modo Flutuante (OAuth, Google, GitHub, SSO)**:
  - **Localizações**:
    - BSPWM: [modules/home-manager/desktop/environments/bspwm/bspwm.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/bspwm.nix).
    - Hyprland: [modules/home-manager/desktop/environments/hyprland/hyprland.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/hyprland/hyprland.nix).
    - MangoWM: [modules/home-manager/desktop/environments/mangowm/mango.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/mangowm/mango.nix).
  - **Comportamento Anterior**: Janelas popup criadas ao clicar em "Fazer login com o Google", confirmações OAuth de navegadores (Chrome, Brave, Firefox) e diálogos de senha eram tratadas como clientes normais no tiling manager, dividindo a tela principal ao meio (tiling).
  - **Solução Implementada**:
    - *BSPWM*:
      - No `externalRulesScript` (`bspwm-external-rules`), adicionada detecção de `WM_WINDOW_ROLE.*pop-up` e regex case-insensitive bilíngue em `WM_NAME`/`_NET_WM_NAME` para padrões como `Sign in`, `Fazer login`, `Log in`, `Contas do Google`, `Google Accounts`, `OAuth`, `Authorize`, `Autorizar`, `Bitwarden`, etc., forçando `state=floating center=on follow=on` respeitando as dimensões nativas solicitadas pelo site.
      - Adicionadas regras estáticas `bspc rule -a "*:pop-up"` e para títulos de login/OAuth.
    - *Hyprland*: Adicionada `windowrule` com correspondência regex no título para `float 1` e `center 1`.
    - *MangoWM*: Adicionada `windowrule` correspondente para `isfloating:1`.

- **BSPWM SXHKD — Correção no Envio de Janelas para Workspaces (`bspwm-node-to-desktop`)**:
  - **Localização**: [modules/home-manager/desktop/environments/bspwm/sxhkd.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/sxhkd.nix) e [home-manager/hosts/nitro/default.nix](file:///home/juca/.dotfiles/nixfiles/home-manager/hosts/nitro/default.nix).
  - **Causas Raiz**:
    1. *Interceptação do `Alt + Shift` pelo XKB (`grp:alt_shift_toggle`)*: A opção `options = [ "grp:alt_shift_toggle" ]` no host `nitro` interceptava `Alt + Shift` no nível do servidor X11 para alternância de layout de teclado (US/ABNT2), consumindo o evento de `Shift`. Ao pressionar `Alt + Shift + {1-9,0}`, o SXHKD recebia apenas `Alt + {1-9,0}`, disparando o `bspwm-desktop-focus` em vez do envio de nó (sintoma: *"não envia a janela, somente vai para a área de trabalho"*).
    2. *Ausência de Mapeamento com `Super` (`${altMod}`)*: Como o `nitro` utiliza `modifierKey = "Alt"`, o envio de janelas estava mapeado apenas para `alt + shift + ...`. Usuários tentando usar a tecla `Super` (Windows) tinham o envio ignorado ou colidindo com screenshots.
    3. *Foco de Monitor em Setups Multi-Monitor*: Em setups com múltiplos monitores (`HDMI-1-0` com 1, 3, 5, 7, 9 e `eDP-1` com 2, 4, 6, 8, 0), ao enviar a janela para um workspace situado no outro monitor com `--follow`, o `bspc node -d "$d"` transferia o nó, mas o foco do monitor de destino precisava ser ativado explicitamente.
  - **Correções Aplicadas**:
    - **Host `nitro`**: Alterada a opção de teclado para `options = [ "grp:caps_toggle" ]`, liberando `Alt + Shift` completamente para o gerenciamento de janelas e atribuindo a alternância US/ABNT2 ao Caps Lock.
    - **`sxhkd.nix`**: Mapeamento duplo para workspaces adicionando `${altMod} + shift + {1-9,0}` e `${altMod} + ctrl + {1-9,0}`, permitindo alternar e enviar janelas usando **tanto `Super` quanto `Alt`**.
    - **`desktopNodeScript`**: Atualizado para localizar o monitor de destino via `bspc query -M` e focar explicitamente o monitor (`bspc monitor -f "$m"`), o desktop (`bspc desktop -f "$d"`) e o nó transferido (`bspc node "$cur_node" -f`).
    - **Remoção de Colisão em Screenshots**: Removido o override condicional de `super + shift + {3,4,5}` que capturava workspaces 3, 4 e 5 no perfil PC standard.

- **BSPWM Scratchpad — Migração de `tdrop` para Script Nativo Dinâmico (gh0stzk/dotfiles)**:
  - **Localizações**:
    - [modules/home-manager/desktop/environments/bspwm/sxhkd.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/sxhkd.nix).
    - [modules/home-manager/desktop/environments/bspwm/bspwm.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/bspwm.nix).
  - **Componentes Removidos (Não mais necessários)**:
    - O pacote externo `pkgs.tdrop` foi removido de `home.packages` e da linha de comando do atalho de scratchpad.
  - **Implementação do Novo Script Nativo (`bspwm-scratchpad`)**:
    - Inspirado na arquitetura do rice [gh0stzk/dotfiles](https://github.com/gh0stzk/dotfiles), utilizando ferramentas nativas do ecossistema BSPWM (`bspc`, `jq`, `xdo`, `xprop`).
    - *Monitor-Aware*: Interroga a geometria do monitor atualmente em foco via `bspc query -T -m focused` e calcula largura proporcional (75%) e altura (48%), centralizando a janela horizontalmente e posicionando-a 44px abaixo do topo do monitor (perfeitamente alinhada logo abaixo da Polybar flutuante sem cobri-la).
    - *Alternância Suave (`Toggle`)*: Consulta o estado da janela `bspwm-scratch` via `bspc query -T -n "$WINDOW_ID"`. Se visível, esconde com `bspc node -g hidden`. Se oculta, move para o monitor em foco (`-m focused`), reposiciona/redimensiona via `xdo` para a resolução do monitor atual e exibe com foco imediato (`-g hidden=off -f`).
    - *Inicialização com Regra `--one-shot`*: Cria regra temporária no BSPWM com `state=floating sticky=on layer=above` e lança o terminal Alacritty dedicado com `--class bspwm-scratch`.
    - Atalhos integrados e compatíveis tanto com Super quanto com Alt: `${mod} + u` e `${altMod} + u`.
    - Adicionado `xdo` em `home.packages` do BSPWM.

- **BSPWM — Suíte de Scripts Modernos (Inspirado no gh0stzk/dotfiles)**:
  - **Localizações**:
    - [modules/home-manager/desktop/environments/bspwm/sxhkd.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/sxhkd.nix)
    - [modules/home-manager/desktop/environments/bspwm/packages.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/packages.nix)
  - **Implementações e Melhorias**:
    1. *`ScreenShoTer` (`bspwm-screenshot` / `screenshoter`)*:
       - Substituídas as chamadas cruas ao Flameshot por um script completo baseado no `gh0stzk/dotfiles/config/bspwm/bin/ScreenShoTer`.
       - *Multi-Monitor Aware*: Detecta o monitor onde o cursor do mouse está (`bspc query -T -m pointed`) e captura com `maim` sem gerar barras pretas de canvas estendido.
       - *Múltiplos Modos*: `full` (monitor atual imediato), `area` (seleção interativa com `slop`), `window` (janela focada), `all` (todos os monitores), `in3`/`in5` (temporizador com contagem regressiva OSD no Dunst) e `menu` (menu Rofi interativo). Removida completamente qualquer dependência do Flameshot.
       - *Feedback Visual e Clipboard*: Copia instantaneamente para a área de transferência (`xclip -selection clipboard -t image/png`) e emite notificação Dunst com a miniatura capturada e botões de ação ("Visualizar", "Abrir Pasta", "Excluir").
       - *Atalhos*: `Print` (full), `Shift + Print` (area), `Ctrl + Print` (window), `Alt + Print` (in5), `Super + Print` ou `${mod} + Shift + P` (menu Rofi), `Super + Shift + S` (Snipping Tool).
    2. *OSD de Volume e Brilho (`volumeOsd` / `brightnessOsd`)*:
       - Ícones dinâmicos de acordo com a intensidade (baixo, médio, alto, mudo).
       - Barra de progresso Dunst (`-h int:value`) e tags de stack (`x-dunst-stack-tag:volume` e `brightness`) para atualizações suaves sem empilhar popups.
    3. *Controle de Mídia com OSD (`bspwm-media-control`)*:
       - Integrado ao `playerctl`: exibe notificação com título, artista e status (`Playing`/`Paused`) ao alternar faixas ou pausar.
    4. *Conta-gotas de Cor (`bspwm-colorpicker`)*:
       - Integrado ao `xcolor`: captura o valor HEX do pixel sob o cursor, copia para o clipboard e notifica no Dunst. Atalho: `${mod} + p` ou `${altMod} + p`.
    5. *Binários no PATH*: Disponibilizados `bspwm-screenshot`, `screenshoter`, `bspwm-colorpicker` e `bspwm-media-control` diretamente em `home.packages`.
    6. *Menu Interativo Avançado de Bluetooth (`rofi-bluetooth` / `bspwm-bluetooth`)*:
       - Implementado com base na arquitetura do rice [gh0stzk/dotfiles/config/bspwm/bin/rofi-bluetooth](https://github.com/gh0stzk/dotfiles/blob/master/config/bspwm/bin/rofi-bluetooth) e `nickclyde/rofi-bluetooth`.
       - **Controles do Adaptador**: Liga/desliga controlador (com detecção e desbloqueio automático de `rfkill`), alternância em tempo real de varredura/descoberta (`Scan: ON/OFF`), modo pareável (`Pairable: ON/OFF`), visibilidade/descoberta (`Discoverable: ON/OFF`) e atalho direto para o Blueman (`blueman-manager`).
       - **Submenu por Dispositivo (`device_menu`)**: Ao selecionar um dispositivo na lista, abre um submenu contextual com:
         - Status detalhado: Conectado (Sim/Não), Pareado (Sim/Não), Confiável (Sim/Não) e Nível de Bateria (se suportado).
         - Conectar / Desconectar.
         - Parear / Desparear.
         - Confiar / Remover Confiança (Trust / Untrust).
         - Bloquear / Desbloquear dispositivo.
         - Remover / Esquecer dispositivo.
       - **Ícones Nerd Font Inteligentes por Categoria**: Detecta a classe do dispositivo via `bluetoothctl info` e exibe ícones contextuais (fone de ouvido `󰋋`, headphone `󰥰`, caixa de som `󰓃`, teclado `󰌌`, mouse `󰍽`, smartphone `󰏲`, computador `󰌢`, genérico `󰂯`).
       - **Detecção e Formatação de Bateria**: Extração resiliente de dígitos via regex (`sed` + `tr -dc '0-9'`) para evitar caracteres residuais como parênteses `(80)` do BlueZ (`80)%`), com ícones dinâmicos (`󰁹`, `󰁾`, `󰁼`, `󰂃`), cores adaptativas (verde, amarelo, vermelho) e espaçamento elegante na Polybar (`󰂱 Space Travel  󰁹 80%`).
       - **Isolamento de Pacotes**: `bluez` removido de `packages.nix` do Home Manager para evitar redundâncias com o pacote nativo do host Debian, mantendo apenas o applet `blueman` no perfil de usuário.
       - **Disponibilização Universal**:
         - Pacotes executáveis no PATH: `rofi-bluetooth` e `bspwm-bluetooth` exportados em `home.packages`.
         - Ativação direta ao clicar no módulo de Bluetooth da Polybar (botão esquerdo ou direito).
         - Atalho global de teclado: `${mod} + Shift + B` e `${altMod} + Shift + B`.
         - Adicionado ao menu Quick Settings / Control Center e documentado no Cheat-Sheet de atalhos.

- **BSPWM SXHKD — Diretório Padrão de Trabalho do Terminal (`$HOME` vs Herança de Processo)**:
  - **Localizações**:
    - [modules/home-manager/desktop/environments/bspwm/sxhkd.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/sxhkd.nix)
    - [modules/home-manager/desktop/environments/bspwm/bspwm.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/bspwm.nix)
  - **Causa Raiz**:
    - Em sistemas Unix/Linux, todo processo filho (`child process`) gerado herda o diretório de trabalho atual (`$PWD` / `cwd`) do processo pai.
    - Quando o daemon `sxhkd` é reiniciado manualmente no terminal através de um comando como `pkill -x sxhkd; sxhkd &` de dentro de `~/.dotfiles/nixfiles`, o próprio `sxhkd` passa a ter `~/.dotfiles/nixfiles` como seu `$PWD`.
    - Ao pressionar <kbd>Super</kbd>/<kbd>Alt</kbd> + <kbd>Return</kbd>, o `sxhkd` chamava o binário do terminal sem argumento de diretório, fazendo o Alacritty herdar `~/.dotfiles/nixfiles`.
  - **Solução Definitiva**:
    - No `sxhkd.nix`, os atalhos de abertura do terminal (`${mod} + Return`, `KP_Enter`, `${mod} + t`), o scratchpad (`bspwm-scratchpad`) e os menus Rofi foram parametrizados explicitamente com `--working-directory "$HOME"` (ou `$HOME`).
    - No `bspwm.nix` (`bspwmrc`), a inicialização do daemon de atalhos foi encapsulada com `(cd "$HOME" && ${pkgs.sxhkd}/bin/sxhkd) &`, garantindo que mesmo reiniciando o BSPWM via `bspc wm -r` em qualquer subpasta, o processo pai sempre opere a partir de `$HOME`.

- **Módulo Fastfetch Declarativo (`system.programs.tools.fastfetch`)**:
  - **Localizações**:
    - [modules/home-manager/system/programs/tools/fastfetch/default.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/system/programs/tools/fastfetch/default.nix).
    - [modules/home-manager/system/programs/tools/default.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/system/programs/tools/default.nix).
    - [home-manager/hosts/nitro/default.nix](file:///home/juca/.dotfiles/nixfiles/home-manager/hosts/nitro/default.nix).
  - **Arquitetura e Recursos**:
    - Módulo de alto nível integrado a `programs.fastfetch` nativo do Home Manager.
    - **Conjunto de Módulos Curado (Inspirado no LambBread)**: Configurada lista abrangente de módulos (`title`, `separator`, `os`, `host`, `kernel`, `uptime`, `packages`, `shell`, `display`, `de`, `wm`, `wmtheme`, `theme`, `icons`, `font`, `cursor`, `terminal`, `terminalfont`, `cpu`, `gpu`, `memory`, `swap`, `disk`, `localip`, `battery`, `poweradapter`, `locale`, `break`, `colors`).
    - **Compatibilidade Dual (Nix vs Distro Nativa)**: Suporte a `installPackage`, `useSystemPackage` e `useSystemPackages`, permitindo gerenciar declarativamente apenas o `config.jsonc` caso o usuário utilize o binário `/usr/bin/fastfetch` da distribuição hospedeira.
    - **Retrocompatibilidade de Presets**: Link simbólico automático em `~/.config/fastfetch/presets/default.jsonc` apontando para o `config.jsonc` gerado pelo Home Manager, suportando comandos manuais como `fastfetch --preset default`.
    - **Limpeza Automática**: Integrado ao `system.cleanup` (`cleanup/default.nix`) para purgar `~/.config/fastfetch` automaticamente caso o módulo seja desativado.

- **BSPWM / Polybar / Waybar — Dimensionamento e Colunas dos Menus Rofi (Bluetooth, Wi-Fi e Utilitários)**:
  - **Localizações**:
    - [modules/home-manager/desktop/environments/bspwm/polybar/scripts.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/polybar/scripts.nix)
    - [modules/home-manager/desktop/display-servers/wayland/traditional/waybar.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/display-servers/wayland/traditional/waybar.nix)
  - **Causa Raiz do Truncamento dos Nomes**:
    - No tema global do Rofi (`rofi.nix`), o elemento `listview` foi configurado por padrão com `columns = 2;` para estilo de launcher de aplicativos em grade (`drun`).
    - Quando scripts com `rofi -dmenu` (Bluetooth, Wi-Fi, Powermenu, Janelas Minimizadas) eram executados sem especificar `columns: 1;` no `-theme-str`, herdavam a divisão em duas colunas, fazendo com que janelas dividissem o espaço horizontal em metades estreitas.
    - Como linhas de Bluetooth contêm ícone, nome do dispositivo, MAC, status de conexão e nível de bateria (ex: `󰂱 Space Travel [28:11:A5:68:55:01] (󰂱 Conectado 󰁹 80%)`) e o Wi-Fi contém SSIDs longos com segurança e intensidade de sinal (ex: `󰌾 MinhaRede-Fibra-Optica-Casa-5G-SuperRapida [▂▄▆█]`), o texto excedia a largura de meia coluna e era truncado com reticências.
  - **Correções Aplicadas**:
    - **Coluna Única Forçada (`columns: 1`)**: Injetado explicitamente `listview { columns: 1; ... }` em todas as invocações de `-dmenu` nos scripts do Rofi.
    - **Ampliação das Janelas no Rofi**:
      - Menu Principal Bluetooth: ampliado para `900px` de largura com `lines: 14`, garantindo que nomes extensos de periféricos, MAC e porcentagem de bateria caibam em uma única linha com margens folgadas.
      - Submenu de Ações do Dispositivo Bluetooth: ampliado para `850px` com `lines: 7` e prompt detalhado sem truncamento.
      - Estado Bluetooth Desligado: ampliado para `560px` com `lines: 2`.
      - Menu Wi-Fi: ampliado para `820px` com `lines: 13`, espaçamento de SSID expandido para `%-48s` com barras de intensidade de sinal alinhadas à direita.
      - Diálogo de Senha Wi-Fi: ampliado para `600px` para acomodar prompts com nomes de rede extensos.
      - Power Menu, Janelas Minimizadas e Seletor de Teclado: padronizados com `columns: 1` e larguras confortáveis (320px, 700px e 360px, respectivamente).

- **BSPWM / DWM — Configuração Declarativa de Velocidade e Propriedades do Touchpad (`desktop.touchpad`)**:
  - **Localizações**:
    - [modules/home-manager/desktop/environments/default.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/default.nix)
    - [modules/home-manager/desktop/environments/bspwm/bspwm.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/bspwm.nix)
    - [modules/home-manager/desktop/environments/bspwm/packages.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/packages.nix)
    - [modules/home-manager/desktop/environments/bspwm/sxhkd.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/bspwm/sxhkd.nix)
    - [modules/home-manager/desktop/environments/dwm/dwm.nix](file:///home/juca/.dotfiles/nixfiles/modules/home-manager/desktop/environments/dwm/dwm.nix)
    - [home-manager/hosts/nitro/default.nix](file:///home/juca/.dotfiles/nixfiles/home-manager/hosts/nitro/default.nix)
  - **Causa Raiz da Lentidão**:
    - O driver `libinput` no servidor X11 opera por padrão com velocidade de aceleração neutra (`libinput Accel Speed = 0.0`).
    - Em telas modernas Full HD (1080p), essa velocidade neutra exige múltiplos deslizes físicos no touchpad para cruzar a área de trabalho.
  - **Arquitetura Implementada**:
    - **Opções Declarativas (`desktop.touchpad`)**:
      - `enable`: ativação geral.
      - `speed`: velocidade do ponteiro de `-1.0` a `1.0` (padrão elevado para `0.5`, entregando deslocamento ágil e preciso).
      - `naturalScrolling`: rolagem natural estilo macOS (`true`).
      - `tapping`: toque leve para clique (`true`).
      - `clickMethod`: `"clickfinger"` (2 dedos botão direito, 3 dedos botão do meio).
      - `accelProfile`: `"adaptive"` (curva acelerada para movimentos rápidos e pixel-perfect para movimentos lentos).
    - **Script Utilitário (`touchpad-speed` / `bspwm-touchpad-speed`)**:
      - Permite consultar a velocidade atual executando `touchpad-speed` no terminal.
      - Permite alterar dinamicamente a velocidade em tempo real sem reiniciar o sistema (ex: `touchpad-speed 0.6` ou `touchpad-speed 0.3`), com feedback visual via Dunst.
    - **Menu Quick Settings (Rofi)**:
      - Adicionada opção `󰟸 Velocidade do Touchpad` no Control Center (<kbd>Super</kbd>+<kbd>C</kbd> ou menu de atalhos), com seletores rápidos (`0.0 Padrão`, `0.3 Moderado`, `0.5 Rápido`, `0.7 Muito Rápido`, `1.0 Máximo`).

> 💡 **Dica**: Você pode adicionar novas preferências ou regras a qualquer momento neste arquivo ou utilizando o comando `/learn`.









