# Limpeza Automática (`system.cleanup`) — guia do módulo

Módulo para expurgo automático de arquivos órfãos, caches e configurações obsoletas de aplicações removidas.

## Contexto

Localizado em `modules/home-manager/system/cleanup/`.
Controlado por `system.cleanup.enable`.

## Decisões em vigor

- **Detecção de Órfãos**: Compara a geração atual com a anterior do Home Manager para identificar pacotes que foram desativados ou removidos.
- **Proteção de Dados**: Mantém uma lista estrita de diretórios protegidos (`PROTECTED_CONFIGS`) para prevenir deleções indevidas em pastas de dados pessoais ou dotfiles essenciais.
- **Hooks e CLI**:
  - Hook de ativação: `home.activation.cleanupOrphanedConfigs`.
  - Utilitário no PATH: `clean-orphaned-configs` (ou `hm-clean-apps`).

## Como prosseguir

- Ao descontinuar um módulo de aplicação, adicione o caminho de sua configuração antiga na lista de pastas órfãs rastreadas por este módulo.

## Validação

```bash
nix-instantiate --parse modules/home-manager/system/cleanup/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
