# 📚 Wiki & Guia de Referência - Nixfiles

Bem-vindo à Wiki do repositório `nixfiles`. Este documento serve como um guia completo e detalhado explicando a arquitetura deste repositório e todos os comandos essenciais para gerenciar seu sistema NixOS, ambientes Home Manager e o ecossistema Nix.

---

## 🗂️ 1. Arquitetura do Repositório

```
.
├── flake.nix               # Ponto de entrada principal com as máquinas e inputs
├── flake.lock              # Travamento de versões exatas de cada dependência
├── shell.nix               # Shell de desenvolvimento (`nix develop`)
├── lib/
│   ├── default.nix         # Ponto de entrada das funções utilitárias
│   ├── helpers.nix         # Construtores mkNixos e mkHome
│   └── nixGL.nix           # Wrapper OpenGL para distros não-NixOS
├── nixos/                  # Configurações de sistema operacional NixOS
│   ├── default.nix         # Módulo base do NixOS
│   ├── hosts/              # Configurações específicas de cada computador (hardware/rede)
│   └── users/              # Definição de usuários do NixOS
├── home-manager/           # Configurações de ambiente de usuário e dotfiles
│   ├── default.nix         # Módulo base do Home Manager
│   ├── hosts/              # Ajustes por máquina no Home Manager
│   └── users/              # Perfis e dotfiles do usuário
├── modules/
│   ├── nixos/              # Módulos reutilizáveis do NixOS (boot, hardware, serviços, etc.)
│   └── home-manager/       # Módulos reutilizáveis de usuário (shell, terminal, apps, etc.)
├── overlays/               # Sobrescrita e adição de pacotes ao nixpkgs
└── pkgs/                   # Pacotes locais customizados
```

---

## 🐧 2. Comandos do NixOS (`nixos-rebuild`)

O `nixos-rebuild` é a ferramenta responsável por aplicar as configurações de sistema no NixOS (kernel, serviços, drivers, usuários do sistema).

### 🛠️ Aplicando Configurações

- **`sudo nixos-rebuild switch --flake .#hostname`**  
  Compila a nova configuração, ativa-a imediatamente no sistema em execução e torna-a a opção padrão de boot.

- **`sudo nixos-rebuild test --flake .#hostname`**  
  Testa a nova configuração no sistema atual **sem alterar a opção padrão do boot**. Se você reiniciar o computador, ele voltará para a versão anterior. Excelente para testar modificações arriscadas.

- **`sudo nixos-rebuild boot --flake .#hostname`**  
  Compila e adiciona a nova configuração ao menu de boot (GRUB/Systemd-boot), mas **não altera a sessão atual**. A alteração só entra em vigor no próximo reinício.

- **`sudo nixos-rebuild dry-build --flake .#hostname`**  
  Apenas compila as derivações e mostra o que mudaria no sistema, sem ativar nada.

### 📦 Builds e Imagens ISO

- **`nix build .#nixosConfigurations.hostname.config.system.build.toplevel`**  
  Compila o sistema NixOS completo no `/nix/store` e cria um link simbólico `result` no diretório atual. Utilitário para checar se a compilação do sistema passa sem erros.

- **`nix build .#nixosConfigurations.iso-console.config.system.build.isoImage`**  
  Gera uma imagem ISO bootável do NixOS customizada (o arquivo `.iso` estará dentro de `./result/iso/`).

### 🌐 Instalação Remota com `nixos-anywhere`

- **`nix run github:numtide/nixos-anywhere -- --flake .#hostname root@<IP_DA_MAQUINA>`**  
  Instala o NixOS remotamente via SSH em qualquer servidor/máquina com suporte a Linux básico.

---

## 🏠 3. Comandos do Home Manager

O Home Manager gerencia seu ambiente de usuário: dotfiles, configurações de programas (`.config`), pacotes instalados apenas para o seu usuário e serviços do usuário (`systemd --user`).

### 🛠️ Aplicando Mudanças

- **`home-manager switch --flake .#user@hostname`**  
  Compila e aplica suas configurações de usuário no sistema atual (para distros Linux tradicionais como Fedora, Arch, Ubuntu ou standalone).

- **`home-manager news`**  
  Exibe novidades e avisos de deprecamento das últimas atualizações do Home Manager.

### 📜 Gerenciando Gerações e Histórico

- **`home-manager generations`**  
  Lista todas as gerações anteriores do seu ambiente de usuário com datas e links do nix store.

- **`home-manager expire-generations "-7 days"`**  
  Remove as gerações do Home Manager mais antigas que 7 dias para liberar espaço em disco.

- **`./result/activate`**  
  Caso tenha rodado `nix build .#homeConfigurations."juca@fedora".activationPackage`, você pode rodar esse script diretamente para aplicar o perfil.

---

## ❄️ 4. Comandos Gerais do Nix e Flakes

### 🧪 Testes e Validação

- **`nix flake check`**  
  Executa a suíte de testes declarada no `flake.nix` (`checks`), garantindo que a sintaxe, módulos e pacotes de ativação avaliam sem erros.

- **`nix fmt`**  
  Formata todos os arquivos `.nix` do repositório usando a ferramenta padronizada (`nixpkgs-fmt`).

### 🔄 Atualizações de Dependências

- **`nix flake update`**  
  Atualiza todas as dependências declaradas em `inputs` do `flake.nix` e regera o arquivo `flake.lock`.

- **`nix flake lock --update-input nixpkgs`**  
  Atualiza **apenas** a entrada `nixpkgs` no `flake.lock`, mantendo o resto das ferramentas inalterado.

### 🔍 Busca e Teste de Pacotes Isolados

- **`nix search nixpkgs <nome-do-pacote>`**  
  Busca por pacotes disponíveis nos repositórios do Nix.

- **`nix shell nixpkgs#<pacote1> nixpkgs#<pacote2>`**  
  Abre um subshell temporário com os pacotes informados disponíveis no `PATH`. Quando você sai do shell (`exit`), os programas voltam a ficar indisponíveis.

- **`nix run nixpkgs#<pacote> -- <argumentos>`**  
  Baixa, executa o comando uma única vez e não instala nada no sistema permanente. Exemplo: `nix run nixpkgs#cowsay -- "Ola Nix!"`.

- **`nix develop`**  
  Carrega o ambiente de desenvolvimento definido no arquivo `shell.nix` (ou `.envrc` via direnv).

---

## 🧹 5. Manutenção, Limpeza e Liberação de Espaço

Com o tempo, compilações antigas e versões anteriores do sistema acumulam no `/nix/store`. Para liberar espaço:

- **`nix-collect-garbage -d`**  
  Remove todas as gerações antigas do sistema NixOS e perfis do Home Manager, deletando arquivos não utilizados do `/nix/store`.

- **`sudo nix-collect-garbage -d`**  
  Executa a coleta de lixo no perfil do sistema `root` / NixOS.

- **`nix-store --optimise`**  
  Analisa o `/nix/store` e substitui arquivos idênticos duplicados por *hard links*, reduzindo significativamente o uso de espaço em disco sem deletar nada.

- **`nvd diff /nix/var/nix/profiles/system-X-link /nix/var/nix/profiles/system-Y-link`**  
  Compara exatamente quais pacotes e versões mudaram entre duas gerações do NixOS.

---

## ➕ 6. Como Adicionar Novas Configurações

### Adicionar uma nova máquina no Home Manager (Standalone)
1. Crie uma pasta `home-manager/hosts/minhamaquina/default.nix`.
2. Adicione a entrada em `flake.nix` sob `homeConfigurations`:
   ```nix
   "juca@minhamaquina" = helper.mkHome { hostname = "minhamaquina"; desktop = "bspwm"; };
   ```
3. Aplique com `home-manager switch --flake .#juca@minhamaquina`.

### Adicionar uma nova máquina no NixOS
1. Crie uma pasta `nixos/hosts/minhamaquina/` com `default.nix` e `hardware-configuration.nix`.
2. Adicione a entrada em `flake.nix` sob `nixosConfigurations`:
   ```nix
   minhamaquina = helper.mkNixos { hostname = "minhamaquina"; desktop = "xfce4"; };
   ```
3. Aplique com `sudo nixos-rebuild switch --flake .#minhamaquina`.

---

## 🪟 7. Guia de Integração: Tiling Managers e Sincronização com o Home Manager

Este repositório suporta múltiplos gerenciadores de janelas (como **Hyprland** para Wayland e **BSPWM** para X11). A forma como eles sincronizam com o sistema depende se o host roda **NixOS** ou **Home Manager Standalone** (ex: Fedora, Arch, Ubuntu).

### 🔄 Diferença Arquitetural: NixOS vs Standalone

| Aspecto | NixOS Nativo | Standalone (Fedora, Arch, etc.) |
| :--- | :--- | :--- |
| **Escopo de Configuração** | Sistema operacional completo + usuário unificados | Apenas espaço de usuário (`/home/user`) |
| **Display Manager** | Gerenciado via NixOS (`services.displayManager`) | Gerenciado pela distro nativa (`systemd` do host) |
| **Sessões (`.desktop`)** | Injetadas automaticamente em `/run/current-system` | Geradas em `~/.local/share/*-sessions/` |
| **Autenticação PAM** | Declarativa (`security.pam.services.*`) | Requer arquivo em `/etc/pam.d/` no host |
| **Drivers de GPU / Mesa** | NixOS linka em `/run/opengl-driver` | Requer apontar para os drivers Mesa nativos do host |

---

### 📋 Checklist Passo a Passo: Sincronizando Qualquer Tiling Manager

Siga este roteiro sempre que for ativar, trocar ou sincronizar um Tiling Manager via Home Manager:

#### 1️⃣ Declarar o Ambiente no `flake.nix`
Edite a entrada do seu host em `flake.nix`:
```nix
# Exemplo para Home Manager Standalone:
"juca@fedora" = helper.mkHome {
  hostname = "fedora";
  desktop = "hyprland"; # ou "bspwm"
};
```

#### 2️⃣ Compilar e Aplicar com o Home Manager
No terminal, execute o switch:
```bash
home-manager switch --flake .#juca@<hostname>
```
Isso irá:
- Baixar e compilar o Window Manager e seus utilitários (barra, launcher, notificações, locker).
- Gerar os scripts de inicialização em `~/.local/bin/start-<wm>`.
- Gerar os arquivos de sessão de desktop (`.desktop`).

#### 3️⃣ Garantir o Wrapper de Inicialização (`~/.local/bin/start-<wm>`)
Em distros não-NixOS, o Display Manager (SDDM, LightDM, GDM) **não carrega** o ambiente do Nix por padrão. Por isso, nossos módulos declaram um wrapper que:
1. Carrega `/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh` e `~/.nix-profile/etc/profile.d/nix.sh`.
2. *(Apenas Wayland)* Exporta `GBM_BACKENDS_PATH` e `LIBGL_DRIVERS_PATH` para carregar a aceleração gráfica do Mesa/DRM.
3. Importa o ambiente gráfico no D-Bus e Systemd do usuário:
   ```bash
   dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
   systemctl --user import-environment WAYLAND_DISPLAY XDG_CURRENT_DESKTOP
   ```
4. Executa o binário do gerenciador (ex: `exec hyprland "$@"` ou `exec bspwm`).

#### 4️⃣ Registrar a Sessão no Display Manager do Host
O Home Manager gera o arquivo de sessão dentro do seu diretório pessoal:
- **Wayland (Hyprland)**: `~/.local/share/wayland-sessions/hyprland.desktop`
- **X11 (BSPWM)**: `~/.local/share/xsessions/bspwm.desktop`

Se o Display Manager do host (ex: SDDM no Fedora) não listar automaticamente a nova sessão na tela de login, crie o link simbólico para o diretório de sistema:
```bash
# Para sessões Wayland (Hyprland):
sudo ln -sf ~/.local/share/wayland-sessions/hyprland.desktop /usr/share/wayland-sessions/

# Para sessões X11 (BSPWM):
sudo ln -sf ~/.local/share/xsessions/bspwm.desktop /usr/share/xsessions/
```

> 💡 **Ocultar contas de build do Nix (`nixbld1..32`) na tela do SDDM**:  
> No Linux multi-usuário, o Nix cria usuários de build com UIDs entre 30001 e 30032. Para que o SDDM exiba apenas os usuários reais do sistema:
> ```bash
> sudo tee /etc/sddm.conf.d/hide-nix-users.conf << 'EOF'
> [Users]
> HideShells=/sbin/nologin,/usr/sbin/nologin,/bin/false,/usr/bin/false
> MaximumUid=29999
> EOF
> ```


#### 5️⃣ Configurar o PAM para o Bloqueador de Tela (Screen Locker)
Em sistemas standalone, utilitários de bloqueio como **`hyprlock`** ou **`swaylock`** falham com *"Wrong password!"* se não tiverem uma regra no PAM do sistema host.

No Fedora/RHEL, crie o arquivo com o comando abaixo (uma única vez por máquina):
```bash
sudo tee /etc/pam.d/hyprlock << 'EOF'
#%PAM-1.0
auth        include     system-auth
account     include     system-auth
password    include     system-auth
session     include     system-auth
EOF
```
*(Para distros baseadas em Debian/Ubuntu, substitua `system-auth` por `login`)*.

#### 6️⃣ Configuração Unificada de Teclado
Para manter consistência em qualquer gerenciador de janelas, configure seu teclado centralmente no `home-manager/default.nix`:
```nix
home.keyboard = {
  layout = "us";
  variant = "intl";
  model = "apple"; # se usar Mac, habilita acentos e dead keys ('c -> ç)
};
```
O módulo do Hyprland e do X11 leem essas opções automaticamente, garantindo que acentos e layouts funcionem de imediato.

#### 7️⃣ Iniciar ou Alternar a Sessão
1. Se estiver em um Tiling Manager e acabou de rodar `home-manager switch`, muitos componentes (Waybar, Dunst, Rofi) recarregam automaticamente ou com atalho de reload (`Super + Shift + R`).
2. Se estiver trocando de ambiente (ex: de BSPWM para Hyprland):
   - Faça logout da sessão atual (`Super + Shift + E` ou pelo Power Menu).
   - Na tela do Display Manager (SDDM/GDM), selecione a nova sessão na lista e faça login.

