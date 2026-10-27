# SSH — guia do módulo

Configuração declarativa do cliente OpenSSH.

## Contexto

Localizado em `modules/home-manager/system/services/ssh/`.
Gerencia `~/.ssh/config` e hosts remotos.

## Decisões em vigor

- **Incompatibilidade de DSA (`+ssh-dss`) com OpenSSH 9.8+**:
  O OpenSSH 9.8+ removeu completamente o suporte e parsing do algoritmo DSA. A presença de `+ssh-dss` no `~/.ssh/config` causa erro fatal imediato (`Bad key types '+ssh-dss'`), impedindo até operações normais de Git.
  - **Regra**: NUNCA colocar `+ssh-dss` ou opções legadas no `programs.ssh.settings` global.
  - **Solução**: Dispositivos legados (como NAS D-Link ShareCenter `10.10.10.10`) são acessados exclusivamente via wrappers herméticos (`ssh-legacy`, `scp-legacy`, `ssh-sharecenter`) que utilizam o OpenSSH 9.1p1 fornecido pelo overlay `pkgs.older`.
- **Chaves de Identidade**: Declaradas de forma segura em `identityFiles`.

## Como prosseguir

- Mantenha apenas blocos universais com opções padrão e cifras seguras na configuração global do SSH.

## Validação

```bash
nix-instantiate --parse modules/home-manager/system/services/ssh/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
