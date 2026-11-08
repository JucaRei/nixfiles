# Declarative Hyprland window rules.
[
  # Diálogos de Seleção de Pastas e Arquivos -> Flutuantes e Centralizados
  "match:class ^(xdg-desktop-portal.*)$, float 1"
  "match:class ^(xdg-desktop-portal.*)$, center 1"
  "match:class ^(pavucontrol)$, float 1"
  "match:class ^(pavucontrol)$, center 1"
  "match:class ^(pavucontrol)$, size 680 480"
  "match:class ^(blueman-manager)$, float 1"
  "match:class ^(blueman-manager)$, center 1"
  "match:class ^(nm-connection-editor)$, float 1"
  "match:class ^(nm-connection-editor)$, center 1"
  "match:class ^(galculator)$, float 1"
  "match:class ^(galculator)$, center 1"
  "match:class ^(org.gnome.FileRoller)$, float 1"
  "match:class ^(org.gnome.FileRoller)$, center 1"
  "match:class ^(org.gnome.NautilusPreviewer)$, float 1"
  "match:class ^(org.gnome.NautilusPreviewer)$, center 1"
  "match:class ^(.*[sS]crcpy.*)$, float 1"
  "match:class ^(.*[sS]crcpy.*)$, center 1"
  "match:initialTitle ^(.*[sS]crcpy.*)$, float 1"
  "match:initialTitle ^(.*[sS]crcpy.*)$, center 1"

  # Títulos bilíngues de seleção de arquivo
  "match:title ^(Open Folder|Abrir pasta|Open File|Abrir Arquivo|Select a folder|Selecionar pasta|Save As|Salvar como)$, float 1"
  "match:title ^(Open Folder|Abrir pasta|Open File|Abrir Arquivo|Select a folder|Selecionar pasta|Save As|Salvar como)$, center 1"
  "match:title ^(Open Folder|Abrir pasta|Open File|Abrir Arquivo|Select a folder|Selecionar pasta|Save As|Salvar como)$, size 850 550"

  # Picture-in-Picture
  "match:title ^(Picture-in-Picture)$, float 1"
  "match:title ^(Picture-in-Picture)$, pin 1"
  "match:title ^(Picture-in-Picture)$, size 640 360"

  # Janelas de Autenticação / Login (Google, GitHub, OAuth, SSO, Bitwarden)
  "match:title ^(.*(Sign in|Fazer login|Log in|Login|Contas do Google|Google Accounts|OAuth|Authorize|Autorizar|Autenticação|Authentication|Bitwarden).*)$, float 1"
  "match:title ^(.*(Sign in|Fazer login|Log in|Login|Contas do Google|Google Accounts|OAuth|Authorize|Autorizar|Autenticação|Authentication|Bitwarden).*)$, center 1"
]
