# Host `virtualvm` — guia do host

Configuração Home Manager standalone para VM Virt-Manager executando DWM.

## Contexto

- **Ambiente**: Máquina virtual Virt-Manager com interface DWM.
- **Saída do flake**: `homeConfigurations."juca@virtualvm"`.
- **Entrada**: `home-manager/hosts/virtualvm/default.nix`.

## Decisões em vigor

- **Sessão DWM no Display Manager**: A inicialização da sessão DWM no LightDM é realizada através do wrapper `start-dwm` em `$HOME/.local/bin/start-dwm`.
- **Primeiro Switch**: Recomenda-se executar com `-b backup` para evitar conflito com arquivos de dotfiles padrão do `/etc/skel` da distro base.
- **Permissões de Diretórios Nix**: Em novas VMs, assegurar permissões adequadas em `/nix/var/nix/{profiles,gcroots}/per-user`.

## Como prosseguir

- As configurações gráficas herdadas seguem o módulo `desktop/environments/dwm/`.

## Validação

```bash
nix eval .#homeConfigurations."juca@virtualvm".config.home.stateVersion
nix build .#homeConfigurations."juca@virtualvm".activationPackage --dry-run
```
