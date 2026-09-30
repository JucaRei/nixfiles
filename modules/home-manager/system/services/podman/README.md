# 🐳 Módulo Podman (Home Manager)

Módulo declarativo de containers **Podman rootless** de alta performance para o Home Manager, projetado com as melhores práticas da indústria para funcionar de forma transparente tanto no **NixOS** quanto em **distribuições Linux standalone** (Fedora, Debian, Ubuntu, etc.).

---

## 🚀 Principais Diferenciais e Otimizações

1. **Rootless por Padrão e Seguro**:
   - Execução em espaço de usuário sem privilégios de root, isolada via namespaces do kernel Linux e subuids/subgids.
   - Driver de armazenamento `overlay` acelerado com fallback `fuse-overlayfs` declarativo.
2. **Compatibilidade Docker Transparente (`dockerCompat = true`)**:
   - Variável de ambiente `DOCKER_HOST = "unix://$XDG_RUNTIME_DIR/podman/podman.sock"` exportada globalmente para shells e serviços systemd do usuário.
   - Socket API do Podman gerenciado via systemd user socket (`podman.socket`), com ativação sob demanda.
   - Symlink automático de `%t/docker.sock -> %t/podman/podman.sock` para que ferramentas que procuram `docker.sock` no diretório de runtime funcionem sem configuração adicional.
   - Wrapper executável `docker` que encaminha comandos diretamente para `podman`, garantindo compatibilidade com ferramentas e IDEs (VSCode Dev Containers, JetBrains, DBeaver, etc.).
3. **Caminhos de Binários do Nix Store Garantidos (`helper_binaries_dir`)**:
   - Injeta os binários do Nix Store (`crun`, `conmon`, `passt`, `slirp4netns`, `fuse-overlayfs`) diretamente em `helper_binaries_dir` no `containers.conf`.
   - Elimina erros comuns em distros não-NixOS de ferramentas auxiliares não encontradas no `PATH`.
4. **Performance & Recursos Modernos**:
   - **Runtime OCI**: `crun` (extremamente rápido e leve em C, substituindo o legado runc).
   - **Rede Rootless**: `pasta` por padrão (muito mais rápido e eficiente em recursos que o slirp4netns).
   - **Log Driver**: `k8s-file` por padrão (evita poluir desnecessariamente o journal do systemd).
   - **Compressão**: Algoritmo `zstd` para compressão e descompressão rápida de camadas de imagens.
   - **Busca de Registries**: Docker Hub (`docker.io`), Quay (`quay.io`), GitHub Container Registry (`ghcr.io`) e Fedora Registry, com `short-name-mode = "permissive"` para evitar bloqueios interativos ao rodar `podman run alpine`.
   - **Política de Imagens**: `policy.json` pré-configurado para aceitar imagens públicas sem falhas de assinatura.
5. **Ferramental Completo para Desenvolvedores**:
   - `podman-compose` e `docker-compose` (Compose v2).
   - `lazydocker`: TUI interativa completa para monitoramento e gestão de containers.
   - `podman-tui`: Interface de terminal em ncurses nativa do Podman.
   - `skopeo`: Inspeção remota e cópia de imagens OCI.
   - `buildah`: Construção declarativa de imagens sem daemon.
   - `dive`: Análise de camadas e otimização do tamanho de imagens.
6. **Ferramenta de Diagnóstico Embutida (`podman-doctor`)**:
   - Script rápido que verifica subuids, socket ativo, driver de armazenamento, DOCKER_HOST e testa um container rootless.
7. **Suporte Nativo a Quadlets**:
   - Atributo `system.services.podman.quadlets` para criar arquivos declarativos em `~/.config/containers/systemd/` (`.container`, `.network`, `.volume`, `.pod`, etc.).
8. **Manutenção Periódica Automatizada**:
   - Timers systemd configuráveis para `autoPrune` (limpeza periódica de imagens e volumes órfãos) e `autoUpdate` (atualização automática de containers em produção/laboratório).

---

## 🛠️ Opções Disponíveis

| Opção | Tipo | Padrão | Descrição |
| :--- | :--- | :--- | :--- |
| `system.services.podman.enable` | `bool` | `false` | Ativa o módulo Podman e suas configurações. |
| `system.services.podman.dockerCompat` | `bool` | `true` | Wrapper `docker`, variável `DOCKER_HOST` e symlink `docker.sock`. |
| `system.services.podman.enableSocket` | `bool` | `true` | Ativa o socket systemd do usuário (`podman.socket`). |
| `system.services.podman.runtime` | `"crun"` \| `"runc"` | `"crun"` | Runtime OCI de containers. |
| `system.services.podman.network` | `"pasta"` \| `"slirp4netns"` | `"pasta"` | Pilha de rede rootless de alta performance. |
| `system.services.podman.cgroupManager` | `"systemd"` \| `"cgroupfs"` | `"systemd"` | Gerenciador de cgroups para rootless. |
| `system.services.podman.registries.search` | `listOf str` | `[ "docker.io" "quay.io" "ghcr.io" ... ]` | Registries consultados para nomes curtos. |
| `system.services.podman.registries.shortNameMode` | `enum` | `"permissive"` | Modo de resolução de nomes não qualificados. |
| `system.services.podman.storage.driver` | `str` | `"overlay"` | Driver de armazenamento de imagens e containers. |
| `system.services.podman.autoPrune.enable` | `bool` | `false` | Timer semanal do systemd para limpeza automática. |
| `system.services.podman.autoPrune.schedule` | `str` | `"weekly"` | Expressão `OnCalendar` para o auto-prune. |
| `system.services.podman.autoUpdate.enable` | `bool` | `false` | Timer diário do systemd para auto-update. |
| `system.services.podman.containers` | `attrsOf anything` | `{}` | Containers repassados diretamente ao `services.podman.containers` do Home Manager. |
| `system.services.podman.networks` | `attrsOf anything` | `{}` | Redes repassadas diretamente ao `services.podman.networks` do Home Manager. |
| `system.services.podman.volumes` | `attrsOf anything` | `{}` | Volumes repassados diretamente ao `services.podman.volumes` do Home Manager. |
| `system.services.podman.quadlets` | `attrsOf lines` | `{}` | Definições brutas de arquivos Quadlet para `~/.config/containers/systemd/`. |
| `system.services.podman.extraPackages.compose` | `bool` | `true` | Instala `podman-compose` e `docker-compose`. |
| `system.services.podman.extraPackages.lazydocker` | `bool` | `true` | Instala a TUI `lazydocker`. |
| `system.services.podman.extraPackages.tui` | `bool` | `true` | Instala `podman-tui`. |
| `system.services.podman.extraPackages.inspection` | `bool` | `true` | Instala `buildah`, `skopeo` e `dive`. |
| `system.services.podman.aliases.enable` | `bool` | `true` | Atalhos de shell rápidos (`p`, `d`, `dps`, `dc`, etc.). |

---

## 💻 Exemplos de Uso

### 1. Habilitação Padrão Recomendada
No seu arquivo de usuário ou host (ex: `home-manager/users/juca/default.nix`):

```nix
{
  system.services.podman = {
    enable = true;
    autoPrune.enable = true; # Opcional: limpeza automática semanal
  };
}
```

### 2. Uso com Containers Nativos do Home Manager (Quadlets)
O módulo repassa as declarações diretamente ao motor Quadlet nativo do Home Manager (`services.podman.containers`):

```nix
{
  system.services.podman = {
    enable = true;

    containers.redis = {
      image = "docker.io/library/redis:alpine";
      ports = [ "6379:6379" ];
      volumes = [ "redis-data:/data" ];
      autoUpdate = "registry";
    };

    volumes.redis-data = { };
  };
}
```

Ou declarando diretamente via `services.podman`:
```nix
{
  services.podman.containers.nginx = {
    image = "docker.io/library/nginx:alpine";
    ports = [ "8080:80" ];
  };
}
```

Após o `home-manager switch`, recarregue os daemons do usuário:
```bash
systemctl --user daemon-reload
systemctl --user start redis
```

---

## ⚡ Atalhos de Shell (Aliases)

Quando `aliases.enable = true` e `dockerCompat = true`:

| Alias | Comando Executado | Descrição |
| :--- | :--- | :--- |
| `p` | `podman` | Comando Podman nativo |
| `p-ps` / `dps` | `podman ps --format ...` | Lista containers ativos formatados |
| `p-psa` / `dpsa`| `podman ps -a --format ...`| Lista todos os containers |
| `p-img` / `dimg` | `podman images` | Lista imagens baixadas |
| `p-stop` / `dstop`| `podman stop $(podman ps -q)` | Para todos os containers ativos |
| `p-rm` / `drm` | `podman rm -f $(podman ps -aq)` | Remove todos os containers |
| `p-prune` / `dprune`| `podman system prune -af --volumes` | Limpeza completa de cache/volumes |
| `p-logs` / `dlogs` | `podman logs -f` | Segue os logs de um container |
| `p-exec` / `dexec` | `podman exec -it` | Executa shell interativo |
| `dc` | `podman-compose` | Executa o Podman Compose |
| `d` | `podman` | Alias para docker |

---

## 🩺 Diagnóstico e Verificação

Para verificar se o seu ambiente rootless está funcionando 100%:

```bash
podman-doctor
```

O script testará:
1. Executável do Podman e versão instalada.
2. Mapeamento de `subuid` e `subgid` do usuário atual.
3. Definição da variável `DOCKER_HOST`.
4. Estado do socket `%t/podman/podman.sock`.
5. Driver de armazenamento ativo (`overlay`).
6. Execução de um container de teste rootless (`alpine`).

---

## 🐧 Configuração Adicional em Hosts Não-NixOS (Fedora, Debian, Ubuntu)

Para execução rootless em distribuições tradicionais fora do NixOS:

1. **SubUID e SubGID**: O usuário precisa ter uma faixa de UIDs/GIDs alocada em `/etc/subuid` e `/etc/subgid`:
   ```bash
   sudo usermod --add-subuids 100000-165535 --add-subgids 100000-165535 $USER
   ```
2. **Socket Systemd do Usuário**:
   Para ativar a inicialização do socket do Podman:
   ```bash
   systemctl --user enable --now podman.socket
   ```
3. **Linger (opcional, para containers rodando após logout)**:
   ```bash
   loginctl enable-linger $USER
   ```
