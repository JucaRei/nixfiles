# 🧠 Memória e Diretrizes do Projeto (Antigravity / AI Pair Programming)

Este arquivo serve como **memória persistente** e guia de diretrizes para o assistente de IA neste repositório. Ele é carregado automaticamente a cada interação para manter o contexto, padrões arquiteturais e decisões tomadas.

---

## 📌 Contexto Geral do Repositório

- **Tipo**: Configuração declarativa usando **Nix Flakes** para **NixOS** e **Home Manager** (standalone e integrado).
- **Usuário Padrão**: `juca`
- **Hosts**:
  - `anubis` — Fedora standalone, MacBook Air 4,1 (Intel HD 3000 / Sandy Bridge), Wayland (MangoWM / Hyprland + Noctalia Shell)
  - `nitro` — Debian standalone, Acer Nitro 5 (Intel UHD 630 + NVIDIA GTX 1050 Mobile), X11 (BSPWM)
  - `rocinante` — NixOS, MacBook Pro 4,1 (GeForce 8600M GT / NVIDIA 340 Legacy + Nouveau), X11 (DWM-Titus + Quickshell)
  - `virtualvm` — NixOS em VM Virt-Manager, X11 (DWM-Titus + Quickshell)
  - `rocinante-hyperv` — NixOS em Hyper-V
- **Documentação Base**: [README.md](file:///home/juca/.dotfiles/nixfiles/README.md), [WIKI.md](file:///home/juca/.dotfiles/nixfiles/WIKI.md) e `nixos/hosts/<host>/*.md`.

---

## 📐 Padrões de Código e Convenções Nix

1. **Evitar Unused Bindings**: Em assinaturas (`{ lib, pkgs, ... }:`), declare **apenas** argumentos lidos no corpo. O `...` absorve extras (`config`, `options`, `specialArgs`). Em `let`, use `inherit` apenas para atributos usados.
2. **Estrutura Modular**:
   - `home-manager/` → Dotfiles e ferramentas do usuário (entrada: `home-manager/default.nix`).
   - `nixos/` → Configurações de sistema e serviços.
   - `modules/` → Módulos customizados reaproveitáveis (`home-manager/` e `nixos/`).
   - `lib/` → Funções utilitárias (`mkNixos`, `mkHome`).
   - `overlays/` e `pkgs/` → Pacotes próprios e extensões do nixpkgs.
3. **Boas Práticas de Modificação e Validação**:
   - Sempre manter comentários informativos e documentação existente.
   - **Atualização Contínua**: Atualizar este `AGENTS.md` imediatamente a cada diagnóstico, solução ou decisão arquitetural.
   - **Validação Cirúrgica**: Usar `nix eval` ou `nix flake check --no-build` durante edições incrementais.
   - **Verificação Global**: `nix flake check` apenas no fechamento final ou sob demanda.
4. **Padrão de Tiling Managers no Home Manager (NixOS vs Standalone)**:
   - **Wrapper de Inicialização**: Gerar `~/.local/bin/start-<wm>` com profiles do Nix, drivers gráficos nativos e importação de variáveis D-Bus/systemd.
   - **Sessões Desktop**: `.desktop` em `~/.local/share/{wayland,x}-sessions/`. Em standalone, linkar para `/usr/share/*-sessions/`.
   - **PAM e Setuid**: Em standalone, screen lockers e Polkit exigem symlinks em `/run/wrappers/bin/` (ex: `unix_chkpwd`, `polkit-agent-helper-1`).
   - **Teclado Unificado**: Herdar de `home.keyboard` (`layout`, `variant`, `model`).

---

## ⚡ Comandos Rápidos

```bash
# Validação rápida (sem build):
nix flake check --no-build
nix eval .#homeConfigurations."juca@<host>".config.home.stateVersion
nix eval .#nixosConfigurations.<host>.config.system.stateVersion

# Aplicação:
home-manager switch --flake .#juca@<host>        # HM standalone
home-manager switch --flake .#juca@<host> -b backup  # Primeiro switch (evita clobber de .bashrc/.profile)
sudo nixos-rebuild switch --flake .#<host>        # NixOS
```

---

## 🏗️ Padrões Arquiteturais e Gotchas Críticos

### nixGL (Hosts Standalone com GPU)

- **Regra geral para dual GPU Optimus**: Sempre definir `nixGLType = "intel"` no `mkHome` quando Intel gerencia o display. A detecção automática (`auto.nixGLDefault`) só é segura quando nixGL suporta a versão exata do NVIDIA no nixpkgs.
- `lib/nixGL.nix`: Parâmetro `nixGLType` (intel/nvidia/mesa/auto/null). `nixGLBin` calcula o binário correto (`nixGLIntel`, `nixGLMesa`, etc.). Repasse transparente de `.override`/`.overrideAttrs`.
- `lib/helpers.nix`: Quando `nixGLType != null && != "auto"`, aplica `nixGLOverrideOverlay` após `nixgl.overlay`.

### Tema GTK / Catppuccin

- O pacote `pkgs.catppuccin-gtk` gera diretório em **caixa baixa**: `catppuccin-mocha-blue-standard+rimless`. Nome CamelCase não funciona. Unificado em todos os ambientes.
- `dconf.settings."org/gnome/desktop/interface"` com `color-scheme = "prefer-dark"`, export de `GTK_THEME` e symlinks retrocompatíveis.

### Tema de Cursor Catppuccin

- Pacote `pkgs.catppuccin-cursors.mochaDark` → diretório `catppuccin-mocha-dark-cursors` (caixa baixa). Deve definir `xresources.properties`, `XCURSOR_THEME`/`XCURSOR_SIZE` e symlinks em `~/.icons`.

### Wayland — Shells Gráficos

- `desktop.wayland.shell`: `"traditional"` (Waybar + Rofi + Dunst + Hyprlock) ou `"noctalia"` (shell nativo C++/Wayland integrado).
- `desktop.wayland.compositor`: `"hyprland"` ou `"mangowm"`.
- `lib/helpers.nix`: Parâmetro `waylandShell ? "traditional"` repassado via `extraSpecialArgs`.
- `fullDesktopManagers` (gnome, kde, etc.): `shell` recebe `null` para não inicializar sub-shells standalone.

### Noctalia Shell (v5+)

- **Configuração**: TOML em `~/.config/noctalia/config.toml` via `desktop.wayland.noctalia.settings` (tipo `(pkgs.formats.toml { }).type`).
- **MangoWM + Noctalia**: Conecta via `ext-workspace-v1` e socket IPC nativo. Widget `mango_layout` como `custom_button`.
- **Plugins**: Referenciados como `<autor>/<plugin>:<entry>` (nunca `plugin:`).
- **OSD**: Brilho e volume via IPC nativo (`noctalia msg`), sem `notify-send`.
- **Idle**: Seção `[idle.behavior.<nome>]` (não `bahavior`). `pre_action_fade_seconds = 0.0` no Intel HD 3000 para evitar flickering.

### DWM-Titus + Quickshell

- **Sessão NixOS**: `services.xserver.windowManager.dwm.package` usa wrapper que executa `$HOME/.local/bin/start-dwm` (não o `pkgs.dwm` vanilla).
- **Arquivos QML/Config graváveis**: Provisionados como cópias reais (não symlinks do store) via hook `activation.setupDwmConfig`.
- **Scripts `dwm-settings-*`**: Patcheados para aceitar symlinks do Nix store, fallback atômico POSIX (sem exigir coreutils 9.5), e auto-cura de permissões (`chmod go-w`).
- **Dunst**: Ativado apenas se `bar != "quickshell"` (evita colisão D-Bus de notificações).
- **NVIDIA 340 Legacy no Quickshell**: Backend `software` (`QT_QUICK_BACKEND=software`, `QT_XCB_GL_INTEGRATION=none`). `LD_LIBRARY_PATH` exportado apenas quando driver proprietário detectado.
- **Detecção via `osConfig`**: `isNvidiaLegacy = (osConfig.hardware.graphics.cards.gpu or null) == "nvidia-legacy"`.
- **Workspaces**: `xprop -spy` com `stdbuf -oL` para line-buffering. `dwm.c` emite `DWM_TAG_UPDATE` + `XFlush`.
- **Atalhos DWM**: Manter keybinds nativas do `dwm-titus` ativas; alternativas comentadas no `hotkeys.toml`.
- **`window-rules.toml`**: Atributo correto é `isfloating` (não `float`).

### Módulo de Monitores (`desktop.monitors`)

- Módulo genérico em `modules/home-manager/desktop/monitors/default.nix`. Hosts configuram `desktop.monitors = [ { name; width; height; refresh; primary; } ]`.
- Gera automaticamente regras para MangoWM, Hyprland, Kanshi, X11 (xrandr) e DEs completos.
- `desktop.monitorsFontRendering`: Antialiasing, hinting leve e subpixel RGB.

### Tecla Modificadora Universal (`desktop.modifierKey`)

- Aceita `"Super"` (padrão), `"Alt"` ou `"Ctrl"`. Sobrescrita por ambiente (`desktop.hyprland.modifierKey`, etc.).
- Inversão inteligente de secundário quando `mod == "Alt"` → secundário vira `Super`.
- Estados de janelas: `Modifier + F` → floating; `Alt + A` → fullscreen.

### Gerenciador de Arquivos Agnóstico (`system.programs.file-manager`)

- CLI unificado `file-manager` com `default` (`auto/thunar/nautilus/nemo/pcmanfm`), `activeCommand`, `activeName`, `activeDesktopFile`.
- Todos os WMs usam `config.system.programs.file-manager.activeCommand` nos atalhos.

### Limpeza Automática (`system.cleanup`)

- Módulo centralizado purga configs/caches/dados de apps desativadas a cada switch.
- Comparação entre gerações do HM para detectar pacotes removidos.
- Lista de proteção de pastas críticas (`PROTECTED_CONFIGS`).
- Hook `home.activation.cleanupOrphanedConfigs` + CLI `clean-orphaned-configs` (`hm-clean-apps`).

### Podman Rootless (`system.services.podman`)

- `services.podman.enable = true` com Docker compat (`dockerCompat = true`), socket systemd, wrapper `docker` e `DOCKER_HOST`.
- Helpers OCI injetados via `helper_binaries_dir` no `containers.conf`.
- **Standalone (Debian/Ubuntu)**: Requer `apt install uidmap` para `newuidmap` setuid.

---

## 🖥️ Gotchas por Host

### `anubis` (Fedora / MacBook Air 4,1 / Intel HD 3000)

- **Hyprland 0.55+**: `configType = "hyprlang"`, `windowrule` (não `windowrulev2`), `gesture = [ "3, horizontal, workspace" ]`.
- **Intel HD 3000 (Sandy Bridge)**: `debug.vfr = false`, `cursor.no_hardware_cursors = true`, `render.direct_scanout = 0`. Drivers Mesa/GBM explícitos nos wrappers.
- **VA-API**: Driver `i965` (`intel-vaapi-driver`). `LIBVA_DRIVER_NAME = "i965"`. `vainfo` requer `--display drm` (alias configurado).
- **Hyprpaper**: Não funciona no HD 3000 (`PRIME export not supported`). Alternativa: `swaybg`.
- **Backlight**: `acpi_backlight=native` via `grubby`. Passos de 2%.
- **PAM do Hyprlock**: Provisionar `/etc/pam.d/hyprlock` com `system-auth`.
- **Hibernate**: Swap híbrida (zram prioridade 100 + partição física prioridade -1). `resume=UUID=...` no GRUB + Dracut.

### `nitro` (Debian / Acer Nitro 5 / Intel UHD 630 + NVIDIA GTX 1050)

- **nixGL**: `nixGLType = "intel"`.
- **VA-API**: `LIBVA_DRIVER_NAME` não pode ser string vazia (quebra auto-detect). X11 vars: checar Intel primeiro em dual GPU. `vainfo-intel` wrapper com fallback para render node da Intel.
- **Firmware Debian**: `firmware-intel-graphics`, `firmware-intel-misc`, `firmware-intel-sound` necessários.
- **Wi-Fi (Intel AC 9560 / iWD)**: Backend `iwd` no NetworkManager com `EnableNetworkConfiguration=false` no `main.conf`. Desativar `systemd-networkd`. Remover `iwlwifi-reload.service`. Drop-in `After=iwd.service`.
- **BSPWM Multi-Monitor**: Workspaces ímpares (1,3,5,7,9) no primário, pares (2,4,6,8,0) no secundário. Atalhos por nome direto (`bspc desktop -f '{1-9,0}'`).
- **Teclado**: `options = [ "grp:caps_toggle" ]` (não `grp:alt_shift_toggle`, que intercepta `Alt+Shift` para layout XKB).
- **zRAM**: `systemd-zram-generator`, `vm.swappiness = 100`, `vm.page-cluster = 0`.
- **Btrfs**: `compress=zstd:3` (sistema) e `compress=zstd:1` (home/dados). Dracut `compress="zstd -3"`.
- **`mpv-nvidia`**: Injeta apenas `/usr/lib/x86_64-linux-gnu/nvidia/current` em `LD_LIBRARY_PATH` para NVDEC, sem risco de conflito de glibc.
- **Solaar**: `pkgs.solaar` + serviço systemd do usuário para teclados Logitech sem interface em `/sys/class/leds`.
- **Bluetooth (Fones / MX Keys / Autorização / Notificações Dunst)**: Fones (ex: Space Travel 2) presos em "precisa de autorização" ocorrem quando pareados com `Trusted: no`. No BlueZ, reconexões de dispositivos não-confiáveis exigem aprovação via `AuthorizeService(device, uuid)`. A solução definitiva adotada: 1) Rotina de auto-trust em background no startup do `bspwm.nix` para todos os dispositivos pareados (`bluetoothctl trust "$dev"`); 2) Dunst com `mouse_left_click = "do_action, close_current"`; 3) `dconf` com `org/blueman/general.notification-daemon = true` (SEMPRE true: quando `false`, o Blueman ignora o Dunst e cria janelas modais GTK `_NotificationDialog` com `Gtk.WindowPosition.CENTER` que aparecem no centro da tela, ficam presas sem fechar sozinhas e poluem o `polywins` como janelas normais `.blueman-app`); 4) Dunst configurado com `origin = "top-right"`, `offset = "16x46"`, `follow = "mouse"` e regras (`bluetooth`, `blueman`, `bluetooth_stack`, `bluetooth_summary`) com `override_dbus_timeout = true` e `timeout = 4`, garantindo que toda notificação de conexão e desconexão apareça no topo direito como em qualquer desktop manager completo e desapareça suavemente em 4 segundos sem exigir clique manual.

### `rocinante` (NixOS / MacBook Pro 4,1 / GeForce 8600M GT)

- **Boot dual**: Padrão Nouveau (Kernel Zen) + `specialisation.nvidia` (Kernel 6.6 LTS + NVIDIA 340 Legacy).
- **Boot CSM/Legacy obrigatório**: `bootType = "legacy"` (GRUB BIOS). Em EFI nativo, NVIDIA 340 falha com `failed to copy vbios`.
- **NVIDIA 340 Legacy**: Não usar `hardware.nvidia` (adiciona módulos inexistentes). Usar `boot.extraModulePackages = [ legacy340.bin legacy340.mod ]` e `services.xserver.drivers`. `xserver.videoDrivers = lib.mkForce []`.
- **OpenGL no 340**: `LD_LIBRARY_PATH=/run/opengl-driver/lib` nas sessões. Driver monolítico pré-libglvnd.
- **Fix `libglx.so`**: Overlay com `postFixup` criando symlink `libglx.so -> libglx.so.340.108`.
- **Wi-Fi (BCM4321)**: Driver `broadcom-sta` (módulo `wl`). `b43` não recomendado (max 54 Mbps). Repetidores: `wifi-sec.pmf = 1`, `802-11-wireless.mtu = 1460`, DNS `timeout:1 attempts:2 rotate`.
- **Plymouth**: `nouveau` em `initrd.kernelModules`, `simpledrm`/`vesafb` em `availableKernelModules`, `gfxpayload=keep` no GRUB.
- **`antigravity-cli` no Core 2 Duo**: Wrapper com `qemu-x86_64 -cpu Haswell` para emular `PCLMULQDQ`.
- **Lockscreen**: `betterlockscreen` + `i3lock-color` com `security.pam.services.i3lock = {}`.

### `virtualvm` (NixOS / VM Virt-Manager / DWM)

- **Sessão DWM no LightDM**: Wrapper em `dwm.package` que executa `$HOME/.local/bin/start-dwm`.
- **Primeiro switch**: Usar `-b backup` para evitar clobber de `.bashrc`/`.profile` do `/etc/skel`.
- **Permissões**: `chmod 1777 /nix/var/nix/{profiles,gcroots}/per-user`.

---

## 📦 Overlays e Pacotes Notáveis

- **`antigravity-cli`**: Fallback `prev.antigravity-cli or final.unstable.antigravity-cli`.
- **`polybar`**: Override com `pulseSupport = true` (sem ele, `internal/pulseaudio` desativado silenciosamente).
- **`catfish`**: Override injetando `which`, `findutils`, `file` no PATH via `gappsWrapperArgs`.
- **Fcitx5**: Overlay de compatibilidade Qt6 (`fcitx5-with-addons` → `qt6Packages`). Não incluir `fcitx5-configtool` em `home.packages` (colisão de `buildEnv`).
- **Noctalia Shell**: Patches em `overlays/patches/`. Overlay `symlinkJoin` com wrapper.
- **`inherit (final.stdenv.hostPlatform) system`**: Não usar `inherit (final) system` (deprecation warning).
- **Fontes locais (`pkgs/fonts/`)**: Requerem `dontBuild = true;` (presença de Makefile causa `nom-build: command not found`).
- **Zathura**: `package = pkgs.zathura` (wrapper com plugins embarcados). Não usar `pkgs.zathura-pdf-mupdf`.

---

## 🧩 Módulos Principais

| Módulo | Caminho | Notas |
|--------|---------|-------|
| Antigravity IDE | `editors/antigravity` | `-fhs` no NixOS, nativo no standalone. CDP porta 9004. |
| Chromium/Chrome | `browsers/chrome` | `cfg.version` (não `cfg.browser`). `optionals` (não `mkIf`) em listas. |
| Vivaldi | `browsers/chrome` + overlays | `update-ffmpeg --user` para codecs proprietários. Sem `--enable-zero-copy` em GPUs legadas. |
| MPV | `multimedia/mpv` | `[hw-preset]` no `[default]` no final do conf. `useSystemPackage` gera modo universal seguro. |
| Discord | `chat/discord` | Vencord + OpenASAR. Temas: `catppuccin-frappe/mocha`, `doom`, `dracula`. |
| Thunar | `file-manager/thunar` | Wrapper GVfs (`GIO_EXTRA_MODULES`). Sem `pkgs.polkit` em `home.packages` (setuid). `admin://` para root. |
| Nautilus | `file-manager/nautilus` | Wrapper GVfs, Sushi, Open Any Terminal, scripts contextuais. |
| Git | `services/git` | `signing.format = "ssh"`, `signingKey = "~/.ssh/nitro.pub"`. |
| SSH | `services/ssh` | `identityFiles = [ "~/.ssh/nitro" "~/.ssh/id_ed25519" "~/.ssh/id_rsa" ]`. |
| Bash/ble.sh | `shells/bash` | `ble.sh` pré-carregado com `--attach=none` (mkOrder 500), acoplado após Starship (mkOrder 2000). |
| FZF | `shells/fzf` | Motor `fd`, preview `bat`+`eza`, palette Catppuccin. `fif` (ripgrep fuzzy), `fkill`, `fpreview`. |
| Fastfetch | `tools/fastfetch` | Suporte `useSystemPackage`. Preset default linkado. |
| Picom | `bspwm/picom.nix` | v12: Conf via `xdg.configFile` (não `services.picom`). Dual-Kawase blur. Sem opções legadas. |

---

## 🔧 Decisões e Padrões Diversos

- **`home.file.".profile"` no NixOS**: Mover `mkIf (!isNixOS)` para o nível do atributo pai, não dentro de `.text`.
- **NUR**: Overlay já injetado em `lib/helpers.nix` e `modules/home-manager/default.nix`. Não importar `inputs.nur.modules.homeManager.default`.
- **XDG**: `xdg.mimeApps`, `xdg.systemDirs` e `targets.genericLinux.enable` declarados centralmente em `desktop/environments/default.nix` (não nos submódulos).
- **Shell aliases**: Não usar `"$@"` (Fish interpreta como inválido). Comandos POSIX complexos → `pkgs.writeShellScriptBin`.
- **`programs.git`** (HM 24.11+): Opções consolidadas sob `programs.git.settings` (`settings.user.name`, `settings.alias`, etc.).
- **ISOs (`users.users.<name>.shell`)**: Não declarar `shell = mkDefault pkgs.bash` em `nixos/users/default.nix` (colide com o default do NixOS em ISOs).
- **Depreciação `xorg.*` (Nixpkgs 26.05)**: Usar pacotes de primeiro nível (`libx11`, `xrandr`, `setxkbmap`, etc.).
- **Deploy remoto via SSH**: `nix copy --to ssh://` requer `nix-store` no PATH. Symlink `/usr/local/bin/nix-store` + `trusted-users`.
- **GVfs FUSE (standalone)**: `/run/wrappers/bin/fusermount3 -> /usr/bin/fusermount3` via tmpfiles. SMB no MPV via hook Lua `gvfs-smb.lua`.
- **`systemd.user.tmpfiles.rules`**: Usar `- - - -` (não `${username} users`) — usuários sem `CAP_CHOWN`.
- **BSPWM `focus_follows_pointer`**: Verificar `extraConfig` por linhas legadas `bspc config` que sobrescrevem `settings`.
- **BSPWM Scratchpad**: Script nativo (`bspwm-scratchpad`) monitor-aware com `bspc` + `xdo` (substituiu `tdrop`).
- **BSPWM Screenshots**: Script `bspwm-screenshot` multi-monitor com `maim`+`slop` (substituiu Flameshot).
- **BSPWM `bsp-layout`**: Motor nativo reescrito em `pkgs/desktop/bspwm/bsp-layout/bsp-layout.sh` (original phenax tinha bugs de float/subshell).
- **Polybar Multi-Monitor**: `bar/primary` (sistema/perf/rede) + `bar/secondary` (controles/sessão). Zero duplicação. `polybar-launch` com `flock` + debounce.
- **Polybar Bateria**: Opções declarativas `desktop.bspwm.polybar.battery`/`adapter` (nitro usa `BAT1`/`ACAD`).
- **Polybar Estilos (`desktop.bspwm.polybar.style`)**: `"zproger"`/`"pills"` (dimensões e geometria 100% uniformes ao modern: altura 32px, largura 99.2%, offset 6px, raio 10px; player `media` sempre centralizado como no modern; apenas duas cápsulas `#2b2f37`: workspaces e data/hora com `font-4` `JetBrainsMono Nerd Font:size=24;6` para preenchimento vertical contínuo sem degraus/recortes; zero repetições entre monitores com primary focado em hardware/rede e secondary em controles/sessão/data; sem ícones duplicados via `format-prefix = ""` em backlight e data; cores Zproger via `pillModuleOverrides`: números pastel `1: #F9DE8F` a `10: #A3BE8C` em `JetBrainsMono Bold:size=11;3` via `T3` com workspace `0` exibindo `10`, CPU ` #989cff`, RAM ` #d19a66`, Temp ` #a4ebf3`, áudio `#d35f5e`, bluetooth `#61afef`, bateria `#A0E8A2`/`#DF8890`, relógio ` #888e96`, rede `#A3BE8C`, power `#d35f5e`) vs `"modern"` (Waybar/Catppuccin coeso). Paleta Zproger em `polybar/colors.nix`.
- **Polybar Tipagem no Home Manager**: Valores numéricos em `services.polybar.config` devem ser inteiros (`int`) ou `str`, nunca floats (`interval = 3`, não `3.0`).
- **Polybar Bluetooth & Áudio Dinâmicos**: `bluetoothScript` identifica fones (`󰥰`), headset (`󰋋`), caixas (`󰓃`), mouse (`󰍽`), teclado (`󰌌`), etc. e exibe múltiplos dispositivos. Módulo `pulseaudio` usa `custom/script` (`tail = true` via `pactl subscribe`) detectando fones (`󰋋`), headset (`󰋎`), bluetooth (`󰂰`), HDMI (`󰡁`), USB (`󰟵`), alto-falantes (`󰕾`), mudo (`󰝟`) e ciclo de sinks via clique do meio.
- **Polkit no Home Manager**: Não instalar `pkgs.polkit` em `home.packages` (binário sem setuid).
- **Scrcpy**: Regras flutuantes em todos os WMs para variantes `scrcpy`, `Scrcpy`, `.scrcpywrap`, `scrcpy-wrapped`.
- **Janelas de Login/OAuth**: Regras flutuantes para `WM_WINDOW_ROLE.*pop-up` e títulos de autenticação.
- **Virt-Manager (standalone)**: Sempre instalar pelo gerenciador nativo da distro. No Debian: `apt install ovmf swtpm qemu-utils`.
- **SXHKD CWD**: Encapsular startup com `(cd "$HOME" && sxhkd) &`. Terminal com `--working-directory "$HOME"`.
- **Navegadores**: `activation.checkVaapi` centralizado em `browsers/default.nix` (evita conflito entre Firefox e Chrome).
- **Deduplicação de `.desktop` no Rofi**: Usar mesmo nome de arquivo que o upstream para shadowing XDG.
- **Iluminação de teclado**: Script `kbdBrightnessOsd` com fallback `brightnessctl` → `solaar` (Logitech MX Keys).
- **Stalonetray (Bandeja do Sistema Condicional e Filtrada)**: Integrado declarativamente sob `desktop.bspwm.polybar.tray.enable` em `polybar/default.nix` (`background = "#2b2f37"`, `geometry = "5x1-16+44"`, `window_type = "dock"`, `kludges = "force_icons_size"`). Pacote `pkgs.stalonetray`, `stalonetray-toggle`, regras no BSPWM (`state = "floating"`, `sticky = true`, `manage = false`), atalhos no SXHKD (`${mod} + i`, `${mod} + shift + i`), autostart e recarga modular só são ativos quando habilitados na Polybar. Botão toggle `module/tray` ativo na Polybar ao lado de data/powermenu (cápsula redonda `󱊖` no pills/zproger e `sep tray` no modern).
- **Filtro de Ícones do Tray (Exclusivo para Apps Abertos)**: Bluetooth, Teclado, Bateria e Wi-Fi foram removidos do tray porque já possuem módulos nativos dedicados na Polybar: 1) Wi-Fi: `nm-applet` não é iniciado no startup do BSPWM e ignorado via `ignore_classes`; 2) Bluetooth: `dconf` `org/blueman/general.plugin-list = [ "!StatusIcon" ]` desativa o plugin de ícone do Blueman mantendo apenas auth D-Bus e notificações; 3) Teclado: Fcitx5 desativa o addon `notificationitem` via `Enabled=False` declarativo em `conf/` e `addon/`; 4) Bateria/Solaar: ignorado pelo Stalonetray via `ignore_classes solaar Solaar`; 5) Stalonetray configurado com `ignore_classes = "nm-applet Nm-applet blueman-applet Blueman-applet blueman-tray Blueman-tray fcitx fcitx5 Fcitx5 solaar Solaar"`, deixando o tray 100% limpo e exclusivo para aplicativos de terceiros dockados (ex: Telegram, Discord, Steam, Spotify).
- **Recarga Modular de Daemons no `switch-home`**: Cada módulo do BSPWM possui seu próprio hook `home.activation.reload<Daemon>` condicionado ao seu `cfg.enable`: `sxhkd` (`pkill -USR1`), `polybar` (`polybar-launch`), `dunst` (`dunstctl reload` + systemctl), `picom` (systemctl restart), e `stalonetray` (systemctl restart). O processo do `bspwm` **nunca** é reiniciado ou derrubado durante o switch, evitando queda da sessão para o display manager.
- **Menu Interativo de Redes Rofi (`rofi-wifi-menu` / `bspwm-wifi`)**: Totalmente redesenhado no padrão do `rofiBluetoothMenu`: 1) **Alternador de Rede Cabeada (Wired Toggle)**: Detecta interface Ethernet (`eth_dev`), exibindo status de conexão, IP e permitindo ligar/desligar a interface Ethernet com 1 clique (`nmcli device disconnect/connect`) para alternância rápida em testes de rede; 2) **Submenu Completo por Rede**: Ao clicar em qualquer SSID, abre menu contextual com Conectar/Desconectar, Reconectar/Renovar IP, Esquecer Rede (com confirmação e expurgo de credenciais), e Detalhes da Conexão (IP, Gateway, DNS, Sinal, Canal/Freq, BSSID); 3) **Controles Globais**: Alternar rádio Wi-Fi (Power On/Off), escanear redes, conectar a rede oculta (Hidden SSID), gerenciar lista de redes salvas e atalho para o editor gráfico (`nm-connection-editor`); 4) Notificações Dunst dedicadas em pilha `network-osd`.

> 💡 **Dica**: Você pode adicionar novas preferências ou regras a qualquer momento neste arquivo ou utilizando o comando `/learn`.
