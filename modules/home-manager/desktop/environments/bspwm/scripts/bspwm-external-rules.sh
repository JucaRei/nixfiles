#!/usr/bin/env bash
# shellcheck disable=SC2001,SC2005,SC2012,SC2034,SC2059,SC2076,SC2126,SC2154,SC2155,SC2183,SC2207,SC1091,SC2221,SC2222

wid="$1"
    class="$2"
    instance="$3"
    consequences="$4"

    case "$class" in
      bspwm-scratch)
        echo "state=floating sticky=on"
        exit 0
        ;;
      *xdg-desktop-portal*|*Xdg-desktop-portal*)
        echo "state=floating center=on rectangle=850x550+0+0 follow=on"
        exit 0
        ;;
      *scrcpy*|*Scrcpy*)
        echo "state=floating center=on follow=on"
        exit 0
        ;;
    esac

    case "$instance" in
      *scrcpy*|*Scrcpy*)
        echo "state=floating center=on follow=on"
        exit 0
        ;;
    esac

    # Consultar propriedades X11 da nova janela
    PROPS="$(xprop -id "$wid" WM_NAME _NET_WM_NAME WM_WINDOW_ROLE _NET_WM_WINDOW_TYPE 2>/dev/null)"
    [ -z "$PROPS" ] && exit 0

    # 1. Diálogos nativos de seleção de arquivos (GtkFileChooserDialog) -> tamanho compacto e centralizado
    if echo "$PROPS" | grep -q 'WM_WINDOW_ROLE.*GtkFileChooserDialog'; then
      echo "state=floating center=on rectangle=850x550+0+0 follow=on"
      exit 0
    fi

    # 2. Títulos de janelas de seleção de pastas e arquivos (VSCode, navegadores, Electron, GTK, Qt)
    if echo "$PROPS" | grep -Ei -q '(WM_NAME|_NET_WM_NAME).*"(Open Folder|Abrir [Pp]asta|Open File|Abrir [Aa]rquivo|Select a? [Ff]older|Selecionar .*pasta|Select a? [Ff]ile|Selecionar .*arquivo|Choose [Ff]older|Escolher [Pp]asta|Choose [Ff]ile|Escolher [Aa]rquivo|Save As|Salvar [Cc]omo|Save File|Salvar [Aa]rquivo|File Upload|Enviar [Aa]rquivo|Open Workspace|Abrir [Ee]spaço|Add Folder|Adicionar [Pp]asta)'; then
      echo "state=floating center=on rectangle=850x550+0+0 follow=on"
      exit 0
    fi

    # 3. Janelas modais/diálogos genéricos -> flutuantes e centralizadas preservando tamanho padrão
    if echo "$PROPS" | grep -q '_NET_WM_WINDOW_TYPE_DIALOG'; then
      echo "state=floating center=on follow=on"
      exit 0
    fi

    # 4. Janelas pop-up de navegadores (ex: popups de login Google, OAuth, Bitwarden)
    if echo "$PROPS" | grep -q 'WM_WINDOW_ROLE.*pop-up'; then
      echo "state=floating center=on follow=on"
      exit 0
    fi

    # 5. Títulos de janelas de login, autenticação e OAuth (Google, GitHub, Microsoft, SSO, senhas)
    if echo "$PROPS" | grep -Ei -q '(WM_NAME|_NET_WM_NAME).*(Sign in|Fazer login|Log in|Login com|Entrar com|Contas do Google|Google Accounts|Sign in with|Log in with|OAuth|Authorize|Autorizar|Autentica[cç][aã]o|Authentication|Bitwarden|1Password|Authenticator|Password Required)'; then
      echo "state=floating center=on follow=on"
      exit 0
    fi
