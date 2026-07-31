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
