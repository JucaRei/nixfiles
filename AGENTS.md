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
    - `Modifier + Shift + F`: Alterna tela cheia (`fullscreen` / `togglefullscreen`).
    - **Fix de Shell (Zsh/Bash)**: No BSPWM/SXHKD, argumentos de estado utilizam aspas (`'~floating'` e `'~fullscreen'`), prevenindo falhas de expansão de diretório do Zsh (`no such user or named directory: floating`).
  - **Documentação e Menus Dinâmicos**: O menu Rofi de Quick Settings do BSPWM e o cheat-sheet de atalhos renderizam dinamicamente o nome da tecla ativa (`Super + ...`, `Alt + ...` ou `Ctrl + ...`).

> 💡 **Dica**: Você pode adicionar novas preferências ou regras a qualquer momento neste arquivo ou utilizando o comando `/learn`.



