# MangoWM — guia do ambiente

Compositor Wayland baseado em wlroots e MangoWM.

## Contexto

Utilizado principalmente no host `anubis` (Fedora standalone, MacBook Air 4,1).
Entrada do módulo: `default.nix`. Configuração: `mangowm.nix`.

## Decisões em vigor

- **Sintaxe Estrita `snake_case`**: Todas as diretivas de configuração exigem underscore:
  - Monitores: `monitor_rule=`
  - Dimensões e Gaps: `border_px=`, `gap_inner_horizontal=`, `gap_outer_horizontal=`, `smart_gaps=`
  - Cores: `root_color=`, `border_color=`, `focus_color=`, `urgent_color=`
  - Overview: `overview_gap_inner=`, `overview_gap_outer=` (`ov_tab_mode` descontinuado no upstream v0.18+, migrado para dispatcher `overcircle`)
  - Entrada: `numlock_on=`, `sloppy_focus=`, `warp_cursor=`
  - Autostart e Regras: `exec_once=`, `tag_rule=`, `window_rule=` (com `is_floating:1`, `app_id:`)
- **Atalhos e Binds**:
  - Formato: `bind=MODIFIERS,KEY,COMMAND,PARAMETERS`
  - Utilizar `bindc` para variantes de uma mesma tecla física (ex.: `Tab` e `Shift+Tab`)
  - Teclas que compartilham o mesmo keycode físico (ex.: `/` e `?`) devem ter modificadores distintos para evitar colisões
- **Integração com Shell**: Integra-se nativamente com Noctalia via protocolo `ext-workspace-v1`.

## Como prosseguir

- Para validar a sintaxe do arquivo de configuração gerado sem iniciar o compositor:
  `mango -c <arquivo_de_configuracao> -p`
- Sempre manter nomes de diretivas em `snake_case`.

## Validação

```bash
nix-instantiate --parse modules/home-manager/desktop/environments/mangowm/default.nix
nix build .#homeConfigurations."juca@anubis".activationPackage --dry-run
```
