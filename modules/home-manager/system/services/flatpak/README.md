# Flatpak Service Module (`system.services.flatpak`)

Módulo reutilizável do Home Manager para gerenciamento declarativo de pacotes Flatpak baseado no [gmodena/nix-flatpak](https://github.com/gmodena/nix-flatpak).

## Exemplo de Uso Simples

No host (`home-manager/hosts/<host>/default.nix`), você pode apenas ativar e listar os pacotes desejados:

```nix
services = {
  flatpak = {
    enable = true;
    packages = [
      "com.spotify.Client"
      "org.mozilla.firefox"
    ];
  };
};
```

## Exemplo com Opções Avançadas

Você pode utilizar todos os recursos do `nix-flatpak`:

```nix
services = {
  flatpak = {
    enable = true;

    # Lista declarativa com suporte a pinning de commit ou remotes específicos
    packages = [
      "com.spotify.Client"
      {
        appId = "im.riot.Riot";
        origin = "flathub";
      }
      {
        appId = "org.libretro.RetroArch";
        commit = "e6be1463c90ba15e8f023e994dfc6fb0567e40730d8eb254ae356205391d0dc5";
      }

      # Flatpak Bundle (.flatpak avulso via URL ou disco, ex: whatRust)
      (let
        sha256 = "fbcf116fb905c556f4b8665cf4ad0f0a63339e6520d0d12dc5fba31357d8a887";
      in {
        appId = "io.github.karem505.whatRust";
        inherit sha256;
        bundle = "${pkgs.fetchurl {
          url = "https://github.com/karem505/whatRust/releases/download/v0.6.7/whatRust_x86_64.flatpak";
          inherit sha256;
        }}";
      })
    ];

    # Atualizações automáticas periódicas em background via systemd timer
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };

    # Ou atualizar durante o home-manager switch (falso por padrão)
    update.onActivation = false;

    # Permissões declarativas por app (substitui Flatseal)
    overrides = {
      global = {
        Context.sockets = [ "wayland" "!x11" ];
      };
    };

    # Convergência estrita (remove Flatpaks não declarados)
    uninstallUnmanaged = false;
  };
};
```

## Tabela de Opções

| Opção | Tipo | Padrão | Descrição |
|---|---|---|---|
| `enable` | `bool` | `false` | Habilita o gerenciamento declarativo de Flatpaks. |
| `packages` | `listOf (str \| attrs)` | `[ ]` | Lista de pacotes Flatpak (ID simples ou attrset com `origin`, `commit`, etc.). |
| `remotes` | `listOf attrs` | Flathub padrão | Lista de repositórios remotos. |
| `update.onActivation` | `bool` | `false` | Atualiza pacotes durante o `home-manager switch`. |
| `update.auto.enable` | `bool` | `false` | Habilita auto-update periódico em background via systemd timer. |
| `update.auto.onCalendar` | `str` | `"weekly"` | Frequência do timer systemd (ex: `"daily"`, `"weekly"`). |
| `overrides` | `attrs` | `{ }` | Permissões declarativas por app ou globais. |
| `uninstallUnmanaged` | `bool` | `false` | Se verdadeiro, desinstala Flatpaks manuais fora do Nix. |

## Integração XDG

O módulo exporta automaticamente para o ambiente do usuário:
- `xdg.systemDirs.data`: adiciona `~/.local/share/flatpak/exports/share` e `/var/lib/flatpak/exports/share` para que Rofi, DWM, Polybar e outros menus encontrem os arquivos `.desktop` e ícones.
- `home.sessionPath`: adiciona os diretórios de executáveis dos Flatpaks ao `PATH`.
