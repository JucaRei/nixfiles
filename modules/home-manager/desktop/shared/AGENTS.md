# Componentes Desktop Compartilhados (`desktop/shared`) — guia do módulo

Utilitários e serviços de desktop compartilhados entre ambientes X11 e Wayland.

## Contexto

Localizado em `modules/home-manager/desktop/shared/`. Agrupa Rofi, Dunst e configurações compartilhadas de ambiente.

## Decisões em vigor

- **Rofi (Menu de Aplicações)**:
  - Deduplicação de entradas `.desktop` utilizando o mesmo nome de arquivo do upstream para sombreamento XDG correto.
  - Submenu de redes Wi-Fi e Ethernet (`rofi-wifi-menu` / `bspwm-wifi`): suporte a perfis cabeados com reload via `nmcli connection reload` e submenus detalhados por SSID com expurgo e confirmação.
  - Cuidados no parsing do `nmcli -t`: nunca incluir `BSSID` antes do SSID fatiado com `IFS=:`. O campo `SSID` deve ser o último.
- **Dunst (Notificações)**:
  - Configuração com `mouse_left_click = "do_action, close_current"`.
  - Integração Bluetooth/Blueman: regras específicas com `override_dbus_timeout = true` e `timeout = 4` segundos para evitar janelas presas na tela.
- **Tecla Modificadora Universal**: `desktop.modifierKey` (`"Super"`, `"Alt"`, `"Ctrl"`). Inverte o secundário quando `mod == "Alt"`.
- **Módulo de Monitores**: `desktop.monitors` gera regras declarativas para X11, Wayland, Kanshi e DEs.

## Como prosseguir

- Centralize configurações comuns aqui para evitar divergência entre ambientes X11 (BSPWM/DWM) e Wayland.

## Validação

```bash
nix-instantiate --parse modules/home-manager/desktop/shared/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
