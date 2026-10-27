# MPV — guia do módulo

Player multimídia MPV com otimizações de aceleração de hardware e scripts.

## Contexto

Localizado em `modules/home-manager/system/programs/multimedia/mpv/`.
Controlado por `system.programs.multimedia.mpv.enable`.

## Decisões em vigor

- **Aceleração Gráfica (`nixGLWrapper`)**: O pacote do MPV é envolvido com `nixGLWrapper` em hosts standalone para permitir reprodução acelerada por hardware via VA-API ou NVDEC.
- **Perfis de Hardware**: Configuração `[hw-preset]` inserida no bloco `[default]` do `mpv.conf`.
- **Suporte a Multi-GPU / Wrappers**: Em laptops com GPU híbrida (ex.: `nitro`), gera ações secundárias no menu de contexto do `.desktop` para alternar entre Intel e NVIDIA.
- **Rede e SMB**: Suporte a URLs `smb://` através do hook Lua `gvfs-smb.lua` e do FUSE do sistema.
- **Presets Limpos**: Preferir options declarativas em vez de testar `hostname == "..."` diretamente no módulo.

## Como prosseguir

- Ao adicionar novos scripts Lua ou opções de vídeo, garantir que opções proprietárias não quebrem em GPUs Intel antigas ou software rendering.

## Validação

```bash
nix-instantiate --parse modules/home-manager/system/programs/multimedia/mpv/default.nix
nix build .#homeConfigurations."juca@nitro".activationPackage --dry-run
```
