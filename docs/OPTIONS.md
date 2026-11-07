# Catálogo Declarativo de Opções (OPTIONS.md)

Este catálogo documenta todas as opções declarativas personalizadas disponíveis no repositório **nixfiles**
para os módulos do **Home Manager** e do **NixOS**.

Documentação gerada declarativamente com `pkgs.nixosOptionsDoc`.

---

# 1. Opções do Home Manager (`desktop.*` e `system.*`)

## desktop\.bspwm\.enable



Enable bspwm window manager



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/options\.nix](modules/home-manager/desktop/environments/bspwm/options.nix)



## desktop\.bspwm\.packages\.enable



Enable bspwm-related packages



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/packages\.nix](modules/home-manager/desktop/environments/bspwm/packages.nix)



## desktop\.bspwm\.packages\.extraPackages



Additional packages to include



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/packages\.nix](modules/home-manager/desktop/environments/bspwm/packages.nix)



## desktop\.bspwm\.dunst\.enable

Enable dunst notification daemon for bspwm



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/dunst\.nix](modules/home-manager/desktop/environments/bspwm/dunst.nix)



## desktop\.bspwm\.extraConfig



Additional bspwmrc configuration to append



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/options\.nix](modules/home-manager/desktop/environments/bspwm/options.nix)



## desktop\.bspwm\.extraKeybindings



Atalhos adicionais ou personalizados do SXHKD definidos no host\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/options\.nix](modules/home-manager/desktop/environments/bspwm/options.nix)



## desktop\.bspwm\.lock\.enable



Habilitar bloqueador de tela moderno, minimalista e customizável para BSPWM (i3lock-color + xss-lock)



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.package



Pacote do i3lock-color a ser utilizado



*Type:*
package



*Default:*

```nix
<derivation i3lock-color-2.13.c.5>
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.blur



Raio do desfoque gaussiano da tela atual (0 para desativar blur)



*Type:*
signed integer



*Default:*

```nix
8
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.base



Cor de fundo / interior padrão (hex sem \#)



*Type:*
string



*Default:*

```nix
"24273a"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.blue



Cor do anel em estado de verificação



*Type:*
string



*Default:*

```nix
"8aadf4"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.green



Cor dos destaques de teclas no anel



*Type:*
string



*Default:*

```nix
"a6da95"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.mantle



Cor de verificação / interior secundário



*Type:*
string



*Default:*

```nix
"181926"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.mauve



Cor de destaque principal / anel padrão



*Type:*
string



*Default:*

```nix
"ed8796"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.peach



Cor de aviso do Caps Lock



*Type:*
string



*Default:*

```nix
"f5a97f"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.red



Cor de erro ou backspace



*Type:*
string



*Default:*

```nix
"ed8796"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.subtext



Cor do texto secundário e data



*Type:*
string



*Default:*

```nix
"a5adcb"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.colors\.text



Cor do texto do relógio e verificação



*Type:*
string



*Default:*

```nix
"cad3f5"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.dateFont



Família de fonte para a data da lockscreen



*Type:*
string



*Default:*

```nix
"Inter Medium"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.dateFormat



Formato de exibição da data (strftime)



*Type:*
string



*Default:*

```nix
"%A, %d de %B de %Y"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.dateSize



Tamanho da tipografia da data



*Type:*
signed integer



*Default:*

```nix
16
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.dpmsTimeout



Tempo de inatividade em segundos para desligamento da tela via DPMS (0 para desativar, padrão: 900 = 15 min)\.



*Type:*
signed integer



*Default:*

```nix
900
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.extraArgs



Argumentos adicionais repassados diretamente para o binário i3lock-color



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.font



Família de fonte padrão para a interface da lockscreen



*Type:*
string



*Default:*

```nix
"Inter"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.lockScript



Pacote derivado com o script executável bspwm-lock



*Type:*
package



*Default:*

```nix
<derivation bspwm-lock>
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.radius



Raio do anel circular de desbloqueio em pixels



*Type:*
signed integer



*Default:*

```nix
110
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.ringWidth



Espessura da linha do anel de desbloqueio em pixels



*Type:*
signed integer



*Default:*

```nix
7
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.timeFont



Família de fonte para o relógio da lockscreen



*Type:*
string



*Default:*

```nix
"Inter Bold"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.timeFormat



Formato de exibição do horário (strftime)



*Type:*
string



*Default:*

```nix
"%H:%M:%S"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.timeSize



Tamanho da tipografia do relógio



*Type:*
signed integer



*Default:*

```nix
64
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.timeout



Tempo de inatividade em segundos para bloqueio automático de tela via X11 screensaver / xss-lock (0 para desativar, padrão: 600 = 10 min)\.



*Type:*
signed integer



*Default:*

```nix
600
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.lock\.wallpaper



Papel de parede fixo opcional para a tela de bloqueio (se nulo, usa o screenshot com blur)



*Type:*
null or absolute path or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/lock\.nix](modules/home-manager/desktop/environments/bspwm/lock.nix)



## desktop\.bspwm\.modifierKey



Tecla modificadora principal do BSPWM (ex: ‘Super’, ‘Alt’, ‘Ctrl’)\.



*Type:*
string



*Default:*

```nix
"Alt"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/options\.nix](modules/home-manager/desktop/environments/bspwm/options.nix)



## desktop\.bspwm\.picom\.enable



Enable picom compositor for bspwm



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.activeOpacity



Opacidade das janelas ativas em foco (1\.0 = totalmente opaco)



*Type:*
null or integer or floating point number between 0\.0 and 1\.0 (both inclusive)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.animations\.enable



Enable modern smooth window animations in picom



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.backend



Picom rendering backend (glx for GPU acceleration, xrender for VMs/legacy)



*Type:*
null or one of “xrender”, “glx”, “egl”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.blur\.enable



Enable dual_kawase background blur



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.blur\.strength



Dual-Kawase blur strength (1-20)



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.cornerRadius



Raio dos cantos arredondados das janelas em pixels



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.inactiveOpacity



Opacidade das janelas inativas/desfocadas



*Type:*
null or integer or floating point number between 0\.0 and 1\.0 (both inclusive)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.shadows\.enable



Enable window shadows in picom



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.picom\.useDamage



Only repaint modified regions of the screen



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/picom\.nix](modules/home-manager/desktop/environments/bspwm/picom.nix)



## desktop\.bspwm\.polybar\.enable



Habilitar Polybar modular para BSPWM



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.adapter



Nome do adaptador AC em /sys/class/power_supply



*Type:*
string



*Default:*

```nix
"ADP1"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.battery



Nome do dispositivo da bateria em /sys/class/power_supply



*Type:*
string



*Default:*

```nix
"BAT0"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation



Formato de encapsulamento e estilização de cores e destaques das cápsulas (detalhes e sintaxe em polybar/AGENTS\.md)



*Type:*
(submodule) or (one of “pill”, “shapes”, “slant”, “powerline”) convertible to it



*Default:*

```nix
"pill"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.accent



Cor de destaque padrão global para todas as cápsulas (nome da paleta ou HEX direto com ou sem ‘\#’)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.color



Cor de fundo padrão global para todas as cápsulas (nome da paleta ou HEX direto com ou sem ‘\#’)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.colors



Cores customizadas opcionais para glifos, fundos e destaques das cápsulas (detalhes em polybar/AGENTS\.md)



*Type:*
attribute set of (string or null or string)



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.date



Encapsulamento específico da cápsula de data/relógio (string ou { style, color, accent })



*Type:*
(submodule) or (one of “default”, “pill”, “shapes”, “slant”, “powerline”) convertible to it



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.date\.accent



Cor de destaque dos ícones, textos ativos ou elementos de destaque dentro da cápsula



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.date\.color



Cor de fundo da cápsula e de seus glifos delimitadores (nome da paleta ou HEX direto)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.date\.style



Estilo geométrico do encapsulamento (‘pill’, ‘shapes’, ‘slant’, ‘powerline’, ou ‘default’ para herdar)



*Type:*
one of “default”, “pill”, “shapes”, “slant”, “powerline”



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.default



Encapsulamento padrão herdado por todas as cápsulas (string ou { style, color, accent })



*Type:*
(submodule) or (one of “pill”, “shapes”, “slant”, “powerline”) convertible to it



*Default:*

```nix
"pill"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.default\.accent



Cor de destaque dos ícones, textos ativos ou elementos de destaque dentro da cápsula



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.default\.color



Cor de fundo da cápsula e de seus glifos delimitadores (nome da paleta ou HEX direto)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.default\.style



Estilo geométrico do encapsulamento (‘pill’, ‘shapes’, ‘slant’, ‘powerline’)



*Type:*
one of “pill”, “shapes”, “slant”, “powerline”



*Default:*

```nix
"pill"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.netspeed



Encapsulamento específico da cápsula de velocidade de rede (string ou { style, color, accent })



*Type:*
(submodule) or (one of “default”, “pill”, “shapes”, “slant”, “powerline”) convertible to it



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.netspeed\.accent



Cor de destaque dos ícones, textos ativos ou elementos de destaque dentro da cápsula



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.netspeed\.color



Cor de fundo da cápsula e de seus glifos delimitadores (nome da paleta ou HEX direto)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.netspeed\.style



Estilo geométrico do encapsulamento (‘pill’, ‘shapes’, ‘slant’, ‘powerline’, ou ‘default’ para herdar)



*Type:*
one of “default”, “pill”, “shapes”, “slant”, “powerline”



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.stats



Encapsulamento específico da cápsula de métricas/hardware (string ou { style, color, accent })



*Type:*
(submodule) or (one of “default”, “pill”, “shapes”, “slant”, “powerline”) convertible to it



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.stats\.accent



Cor de destaque dos ícones, textos ativos ou elementos de destaque dentro da cápsula



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.stats\.color



Cor de fundo da cápsula e de seus glifos delimitadores (nome da paleta ou HEX direto)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.stats\.style



Estilo geométrico do encapsulamento (‘pill’, ‘shapes’, ‘slant’, ‘powerline’, ou ‘default’ para herdar)



*Type:*
one of “default”, “pill”, “shapes”, “slant”, “powerline”



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.tray



Encapsulamento específico da cápsula da bandeja (string ou { style, color, accent })



*Type:*
(submodule) or (one of “default”, “pill”, “shapes”, “slant”, “powerline”) convertible to it



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.tray\.accent



Cor de destaque dos ícones, textos ativos ou elementos de destaque dentro da cápsula



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.tray\.color



Cor de fundo da cápsula e de seus glifos delimitadores (nome da paleta ou HEX direto)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.tray\.style



Estilo geométrico do encapsulamento (‘pill’, ‘shapes’, ‘slant’, ‘powerline’, ou ‘default’ para herdar)



*Type:*
one of “default”, “pill”, “shapes”, “slant”, “powerline”



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.workspaces



Encapsulamento específico da cápsula de workspaces (string ou { style, color, accent })



*Type:*
(submodule) or (one of “default”, “pill”, “shapes”, “slant”, “powerline”) convertible to it



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.workspaces\.accent



Cor de destaque dos ícones, textos ativos ou elementos de destaque dentro da cápsula



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.workspaces\.color



Cor de fundo da cápsula e de seus glifos delimitadores (nome da paleta ou HEX direto)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.encapsulation\.workspaces\.style



Estilo geométrico do encapsulamento (‘pill’, ‘shapes’, ‘slant’, ‘powerline’, ou ‘default’ para herdar)



*Type:*
one of “default”, “pill”, “shapes”, “slant”, “powerline”



*Default:*

```nix
"default"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.style



Estilo visual da Polybar: ‘zproger’/‘pills’ (cápsulas flutuantes), ‘shapes’ (blocos de pixel) ou ‘modern’ (estilo Waybar / Catppuccin coeso)



*Type:*
one of “modern”, “zproger”, “pills”, “shapes”



*Default:*

```nix
"zproger"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.polybar\.tray\.enable



Habilitar módulo e serviço de bandeja do sistema (Stalonetray) na Polybar



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/polybar/options\.nix](modules/home-manager/desktop/environments/bspwm/polybar/options.nix)



## desktop\.bspwm\.rofi\.enable



Enable rofi application launcher for bspwm



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/rofi\.nix](modules/home-manager/desktop/environments/bspwm/rofi.nix)



## desktop\.bspwm\.rules



bspwm rules for specific applications



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/options\.nix](modules/home-manager/desktop/environments/bspwm/options.nix)



## desktop\.bspwm\.sxhkd\.enable



Enable sxhkd keybindings for bspwm



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/sxhkd\.nix](modules/home-manager/desktop/environments/bspwm/sxhkd.nix)



## desktop\.bspwm\.sxhkd\.extraKeybindings



Atalhos adicionais ou personalizados do SXHKD definidos no host\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/sxhkd\.nix](modules/home-manager/desktop/environments/bspwm/sxhkd.nix)



## desktop\.bspwm\.sxhkd\.keybindings



sxhkd keybindings adicionais ou customizadas\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/sxhkd\.nix](modules/home-manager/desktop/environments/bspwm/sxhkd.nix)



## desktop\.bspwm\.sxhkd\.modifierKey



Tecla modificadora principal do SXHKD (ex: ‘super’, ‘alt’, ‘ctrl’)\.



*Type:*
string



*Default:*

```nix
"Alt"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/sxhkd\.nix](modules/home-manager/desktop/environments/bspwm/sxhkd.nix)



## desktop\.bspwm\.sxhkd\.screenshotKeybindings



Mapeamento customizado de atalhos para captura de tela quando screenshotProfile = ‘custom’\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/sxhkd\.nix](modules/home-manager/desktop/environments/bspwm/sxhkd.nix)



## desktop\.bspwm\.sxhkd\.screenshotProfile



Perfil de teclas de atalho para captura de tela (screenshots):

 - “auto”: detecta automaticamente (teclado Apple/Mac usa “mac”, outros usam “standard”)\.
 - “standard”: ideal para PCs (Acer, Nitro, VMs, etc\.) usando Print, Shift+Print, Ctrl+Print\. Preserva Super+Shift+1…0 livres para workspaces!
 - “mac”: estilo macOS usando Super+Shift+3/4/5 para telas/áreas de captura\.
 - “custom”: utiliza os atalhos declarados em screenshotKeybindings\.
 - “none”: desativa os atalhos de screenshot do sxhkd\.



*Type:*
one of “auto”, “standard”, “mac”, “custom”, “none”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/bspwm/sxhkd\.nix](modules/home-manager/desktop/environments/bspwm/sxhkd.nix)



## desktop\.display-servers\.backend



Default backend for the system



*Type:*
null or one of “x11”, “wayland”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers](modules/home-manager/desktop/display-servers)



## desktop\.dwm\.enable



Enable DWM window manager with custom config\.def\.h and dwm-titus runtime configuration



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.bar



Barra de status/painel do DWM\. Opções: ‘quickshell’ (painel moderno do dwm-titus com launcher e control center), ‘dwm-status’ (script de status nativo do dwm usando xsetroot), ‘slstatus’, ‘polybar’ ou ‘none’\.



*Type:*
one of “quickshell”, “dwm-status”, “slstatus”, “polybar”, “none”



*Default:*

```nix
"quickshell"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.dunst\.enable



Enable dunst notification daemon for dwm (automatically disabled when Quickshell is active to prevent D-Bus collision)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dunst\.nix](modules/home-manager/desktop/environments/dwm/dunst.nix)



## desktop\.dwm\.keyboard\.brightness\.enable



Habilitar script dwm-kbd-brightness-osd e atalhos de iluminação do teclado com OSD Dunst



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.keyboard\.brightness\.device



Dispositivo específico em /sys/class/leds (ex: ‘smc::kbd_backlight’), ou null para detecção automática



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.keyboard\.brightness\.step



Passo de alteração de brilho do teclado em porcentagem (padrão 5%)



*Type:*
signed integer



*Default:*

```nix
5
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.modifierKey



Tecla modificadora principal do DWM (Super ou Alt)\.



*Type:*
string



*Default:*

```nix
"Alt"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.picom\.enable



Enable picom compositor for dwm



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/picom\.nix](modules/home-manager/desktop/environments/dwm/picom.nix)



## desktop\.dwm\.picom\.backend



Picom rendering backend override



*Type:*
null or one of “xrender”, “glx”, “egl”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/picom\.nix](modules/home-manager/desktop/environments/dwm/picom.nix)



## desktop\.dwm\.quickshell\.enable



Habilitar Quickshell no DWM



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.quickshell\.glIntegration



Backend de integração GL do Qt XCB (QT_XCB_GL_INTEGRATION)\. No NVIDIA 340 Legacy, ‘none’ previne falhas de contexto dummy GLX/EGL no Qt6\.



*Type:*
one of “glx”, “egl”, “auto”, “none”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.quickshell\.qsgBackend



Backend de renderização do Qt Quick Scene Graph (QSG_RHI_BACKEND)\. No NVIDIA 340 Legacy (sem suporte a Vulkan e com FBConfigs GLX incompatíveis no Qt 6\.11), ‘software’ garante renderização estável via CPU\.



*Type:*
one of “opengl”, “software”, “vulkan”, “auto”



*Default:*

```nix
"opengl"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/dwm\.nix](modules/home-manager/desktop/environments/dwm/dwm.nix)



## desktop\.dwm\.rofi\.enable



Enable rofi application launcher for dwm



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/environments/dwm/rofi\.nix](modules/home-manager/desktop/environments/dwm/rofi.nix)



## desktop\.hyprland\.enable



Enable Hyprland dynamic tiling Wayland compositor



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/hyprland\.nix](modules/home-manager/desktop/environments/hyprland/hyprland.nix)



## desktop\.hyprland\.packages\.enable



Enable hyprland-related packages



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/packages\.nix](modules/home-manager/desktop/environments/hyprland/packages.nix)



## desktop\.hyprland\.packages\.extraPackages



Additional packages to include



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/packages\.nix](modules/home-manager/desktop/environments/hyprland/packages.nix)



## desktop\.hyprland\.extraConfig



Additional Hyprland configuration lines to append



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/hyprland\.nix](modules/home-manager/desktop/environments/hyprland/hyprland.nix)



## desktop\.hyprland\.hypridle\.enable

Opção de retrocompatibilidade para hypridle



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/hypridle\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/hypridle.nix)



## desktop\.hyprland\.hyprlock\.enable



Opção de retrocompatibilidade para hyprlock



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/hyprlock\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/hyprlock.nix)



## desktop\.hyprland\.hyprpaper\.enable



Opção de retrocompatibilidade para hyprpaper



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/hyprpaper\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/hyprpaper.nix)



## desktop\.hyprland\.keyboard\.layout



Hyprland keyboard layout (defaults to home\.keyboard\.layout)



*Type:*
string



*Default:*

```nix
"us,br"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/hyprland\.nix](modules/home-manager/desktop/environments/hyprland/hyprland.nix)



## desktop\.hyprland\.keyboard\.model



Hyprland keyboard model (defaults to home\.keyboard\.model)



*Type:*
string



*Default:*

```nix
"pc105"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/hyprland\.nix](modules/home-manager/desktop/environments/hyprland/hyprland.nix)



## desktop\.hyprland\.keyboard\.options



Hyprland keyboard options (defaults to home\.keyboard\.options)



*Type:*
string



*Default:*

```nix
"grp:caps_toggle"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/hyprland\.nix](modules/home-manager/desktop/environments/hyprland/hyprland.nix)



## desktop\.hyprland\.keyboard\.variant



Hyprland keyboard variant (defaults to home\.keyboard\.variant)



*Type:*
string



*Default:*

```nix
"intl,abnt2"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/hyprland\.nix](modules/home-manager/desktop/environments/hyprland/hyprland.nix)



## desktop\.hyprland\.modifierKey



Tecla modificadora principal do Hyprland (ex: ‘SUPER’, ‘ALT’, ‘CTRL’)\.



*Type:*
string



*Default:*

```nix
"Alt"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/hyprland\.nix](modules/home-manager/desktop/environments/hyprland/hyprland.nix)



## desktop\.hyprland\.monitors



Hyprland monitor configurations



*Type:*
list of string



*Default:*

```nix
[
  ",preferred,auto,1"
]
```

*Declared by:*
 - [modules/home-manager/desktop/environments/hyprland/hyprland\.nix](modules/home-manager/desktop/environments/hyprland/hyprland.nix)



## desktop\.hyprland\.rofi\.enable



Opção de retrocompatibilidade para rofi



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/rofi\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/rofi.nix)



## desktop\.hyprland\.waybar\.enable



Opção de retrocompatibilidade para waybar



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/waybar\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/waybar.nix)



## desktop\.mangowm\.enable



Enable MangoWM Wayland dynamic tiling compositor based on dwl



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/environments/mangowm/packages\.nix](modules/home-manager/desktop/environments/mangowm/packages.nix)



## desktop\.mangowm\.modifierKey



Tecla modificadora principal do MangoWM (ex: ‘SUPER’, ‘ALT’, ‘CTRL’)\.



*Type:*
string



*Default:*

```nix
"Alt"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/mangowm/packages\.nix](modules/home-manager/desktop/environments/mangowm/packages.nix)



## desktop\.mangowm\.monitorRules



List of monitor rules for MangoWM (e\.g\. ‘name:eDP-1,width:1366,height:768,refresh:60,scale:1’)



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/environments/mangowm/packages\.nix](modules/home-manager/desktop/environments/mangowm/packages.nix)



## desktop\.mangowm\.waybar\.enable



Opção de retrocompatibilidade para waybar



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/waybar\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/waybar.nix)



## desktop\.modifierKey



Tecla modificadora principal (Super Key / Mod Key) para os Window Managers (BSPWM, Hyprland, MangoWM, XFCE4)\.
Valores aceitos: “Super” (ou Mod4/Cmd/Windows), “Alt” (ou Mod1/Option), “Ctrl” (ou Control)\.



*Type:*
one of “Super”, “Alt”, “Ctrl”, “super”, “alt”, “ctrl”, “SUPER”, “ALT”, “CTRL”, “Mod4”, “Mod1”, “mod4”, “mod1”



*Default:*

```nix
"Super"
```

*Declared by:*
 - [modules/home-manager/desktop/environments](modules/home-manager/desktop/environments)



## desktop\.monitors



Lista declarativa de monitores e resoluções unificada para todos os ambientes de desktop e WMs



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.enabled



Se o monitor está ativo e habilitado



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.height



Altura em pixels da resolução nativa ou desejada



*Type:*
signed integer



*Default:*

```nix
1080
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.name



Identificador da saída/monitor (ex: eDP-1, HDMI-A-1, DP-1, Virtual-1)



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.primary



Define se o monitor é primário (relevante no X11/xrandr)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.refresh



Taxa de atualização em Hz



*Type:*
signed integer or floating point number



*Default:*

```nix
60
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.scale



Fator de escala de renderização (DPI scale)



*Type:*
signed integer or floating point number



*Default:*

```nix
1.0
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.transform



Rotação e orientação da tela



*Type:*
one of “normal”, “90”, “180”, “270”, “flipped”, “flipped-90”, “flipped-180”, “flipped-270”



*Default:*

```nix
"normal"
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.width



Largura em pixels da resolução nativa ou desejada



*Type:*
signed integer



*Default:*

```nix
1920
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.x



Posição X horizontal no canvas de monitores



*Type:*
signed integer



*Default:*

```nix
0
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitors\.\*\.y



Posição Y vertical no canvas de monitores



*Type:*
signed integer



*Default:*

```nix
0
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.monitorsFontRendering\.enable



Otimizar nitidez de renderização de fontes (subpixel RGB + slight hinting + RGBA antialiasing)



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/monitors](modules/home-manager/desktop/monitors)



## desktop\.shared\.dunst\.enable



Habilitar daemon de notificações Dunst compartilhado\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/shared/dunst\.nix](modules/home-manager/desktop/shared/dunst.nix)



## desktop\.shared\.dunst\.reloadOnSwitch



Recarregar ou reiniciar automaticamente o Dunst na ativação do Home Manager\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/shared/dunst\.nix](modules/home-manager/desktop/shared/dunst.nix)



## desktop\.shared\.picom\.enable



Habilitar compositor Picom compartilhado para X11 (BSPWM, DWM, etc\.)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.activeOpacity



Opacidade das janelas ativas em foco (1\.0 = totalmente opaco)



*Type:*
integer or floating point number between 0\.0 and 1\.0 (both inclusive)



*Default:*

```nix
1.0
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.animations\.enable



Habilitar animações modernas suaves de janela no picom



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.backend



Backend de renderização do Picom (glx para aceleração por GPU, xrender para VMs/legado)



*Type:*
one of “xrender”, “glx”, “egl”



*Default:*

```nix
"glx"
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.blur\.enable



Habilitar blur de fundo dual_kawase (requer backend glx/egl e GPU compatível)



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.blur\.strength



Intensidade do blur Dual-Kawase (1-20)



*Type:*
signed integer



*Default:*

```nix
7
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.cornerRadius



Raio dos cantos arredondados das janelas em pixels



*Type:*
signed integer



*Default:*

```nix
16
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.environment



Perfil de ambiente desktop para regras e animações específicas de janela\.



*Type:*
one of “bspwm”, “dwm”, “generic”



*Default:*

```nix
"generic"
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.inactiveOpacity



Opacidade das janelas inativas/desfocadas



*Type:*
integer or floating point number between 0\.0 and 1\.0 (both inclusive)



*Default:*

```nix
0.97
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.shadows\.enable



Habilitar sombras de janela no picom



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.picom\.useDamage



Repintar apenas regiões modificadas da tela (economia em legado/VM)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/shared/picom\.nix](modules/home-manager/desktop/shared/picom.nix)



## desktop\.shared\.rofi\.enable



Enable shared rofi application launcher for desktop environments (BSPWM, DWM, Hyprland, etc\.)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/shared/rofi\.nix](modules/home-manager/desktop/shared/rofi.nix)



## desktop\.shared\.rofi\.backend



Rofi backend package (x11 -> pkgs\.rofi, wayland -> pkgs\.rofi-wayland)



*Type:*
one of “x11”, “wayland”



*Default:*

```nix
"x11"
```

*Declared by:*
 - [modules/home-manager/desktop/shared/rofi\.nix](modules/home-manager/desktop/shared/rofi.nix)



## desktop\.theme\.enable



Whether to enable aplicação do tema (GTK, ícones, cursor, fonte) neste host\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.accent



Papel de cor usado como destaque (` colors.accent `) e, no Catppuccin, no tema GTK\.



*Type:*
one of “red”, “orange”, “yellow”, “green”, “teal”, “cyan”, “blue”, “purple”, “pink”



*Default:*

```nix
"blue"
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.colors



Cores da paleta (“\#rrggbb”)\. Papéis: bg bgAlt bgDark surface surfaceAlt border fg fgMuted fgSubtle red orange yellow green teal cyan blue purple pink accent (+ extras específicos da paleta)\.



*Type:*
attribute set of string *(read only)*



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.colorsBare



Mesmas cores sem o “\#” (formato rrggbb)\.



*Type:*
attribute set of string *(read only)*



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.cursor



Tema de cursor\.



*Type:*
submodule



*Default:*

```nix
{
  aliases = [
    "Catppuccin-Macchiato-Dark-Cursors"
  ];
  name = "catppuccin-macchiato-dark-cursors";
  package = <derivation catppuccin-cursors-2.0.0>;
}
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.cursor\.package



Pacote que fornece o tema\.



*Type:*
package

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.cursor\.aliases



Nomes alternativos que também apontam para o mesmo tema (symlinks)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.cursor\.name



Nome do tema (diretório em share/themes ou share/icons)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.cursor\.size



Tamanho do cursor em pixels\.



*Type:*
signed integer



*Default:*

```nix
24
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom



Paleta inline completa (sem arquivo)\. Quando definida, substitui a paleta de desktop\.theme\.name\.



*Type:*
null or (submodule)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.colors



Conjunto completo de papéis de cor (“\#rrggbb”)\. Deve incluir os papéis obrigatórios\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.cursor



Tema de cursor (opcional; se omitido, usa o da paleta padrão)\.



*Type:*
null or (submodule)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.cursor\.package



Pacote que fornece o tema\.



*Type:*
package

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.cursor\.aliases



Nomes alternativos que também apontam para o mesmo tema (symlinks)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.cursor\.name



Nome do tema (diretório em share/themes ou share/icons)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.cursor\.size



Tamanho do cursor em pixels\.



*Type:*
signed integer



*Default:*

```nix
24
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.gtk



Tema GTK (opcional; se omitido, usa o da paleta padrão)\.



*Type:*
null or (submodule)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.gtk\.package



Pacote que fornece o tema\.



*Type:*
package

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.gtk\.aliases



Nomes alternativos que também apontam para o mesmo tema (symlinks)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.gtk\.name



Nome do tema (diretório em share/themes ou share/icons)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.icons



Tema de ícones (opcional; se omitido, usa o da paleta padrão)\.



*Type:*
null or (submodule)



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.icons\.package



Pacote que fornece o tema\.



*Type:*
package

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.icons\.aliases



Nomes alternativos que também apontam para o mesmo tema (symlinks)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.icons\.name



Nome do tema (diretório em share/themes ou share/icons)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.label



Nome descritivo da paleta customizada\.



*Type:*
string



*Default:*

```nix
"Custom"
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.custom\.variant



Variante clara ou escura da paleta\.



*Type:*
one of “dark”, “light”



*Default:*

```nix
"dark"
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.exclude



Lista de alvos que não devem receber o tema automático (ex\.: \[ “bat” “vscode” ])\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.font



Fonte da interface (GTK)\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.font\.package



Pacote que fornece a fonte\.



*Type:*
package



*Default:*

```nix
<derivation inter-4.1>
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.font\.name



Nome da família de fonte\.



*Type:*
string



*Default:*

```nix
"Inter"
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.font\.size



Tamanho da fonte em pontos\.



*Type:*
signed integer



*Default:*

```nix
10
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.gtk



Tema GTK\.



*Type:*
submodule



*Default:*

```nix
{
  aliases = [
    "catppuccin-macchiato-red-standard+default"
    "catppuccin-macchiato-red-standard+rimless"
    "Catppuccin-Macchiato-Standard-Red-Dark"
    "Catppuccin-Macchiato-Red"
  ];
  name = "catppuccin-macchiato-red-standard";
  package = <derivation catppuccin-gtk-1.0.3>;
}
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.gtk\.package



Pacote que fornece o tema\.



*Type:*
package

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.gtk\.aliases



Nomes alternativos que também apontam para o mesmo tema (symlinks)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.gtk\.name



Nome do tema (diretório em share/themes ou share/icons)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.icons



Tema de ícones\.



*Type:*
submodule



*Default:*

```nix
{
  name = "Papirus-Dark";
  package = <derivation papirus-icon-theme-20250501>;
}
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.icons\.package



Pacote que fornece o tema\.



*Type:*
package

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.icons\.aliases



Nomes alternativos que também apontam para o mesmo tema (symlinks)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.icons\.name



Nome do tema (diretório em share/themes ou share/icons)\.



*Type:*
string

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.lib



Helpers utilitários de cor e geração de temas (rgb, rgba, cssRgb, cssRgba, hexTo0x, hexToTuple, withAlpha, generateTmTheme)\.



*Type:*
attribute set of anything *(read only)*



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.name



Paleta\. Uma por arquivo em desktop/theme/palettes/\.



*Type:*
one of “catppuccin-macchiato”, “catppuccin-mocha”, “doom”, “dracula”, “gruvbox-dark”, “kanagawa-wave”, “nord”, “tokyo-night”, “tokyonight”



*Default:*

```nix
"catppuccin-mocha"
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.overrides



Sobrescritas pontuais de papéis de cores (ex\.: { bg = “\#1e1e2e”; border = “\#ff0000”; })\. Aplicadas sobre a paleta ativa\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.targets



Registro único de alvos de tema\. Cada alvo é booleano (true se ativo para receber o tema, false se listado em desktop\.theme\.exclude)\.



*Type:*
attribute set of boolean *(read only)*



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.variant



Claro ou escuro, conforme a paleta\.



*Type:*
one of “dark”, “light” *(read only)*

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.theme\.xsettingsd\.enable



Ativar serviço e configuração do xsettingsd para ambientes X11\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/theme](modules/home-manager/desktop/theme)



## desktop\.touchpad\.enable



Habilitar configuração declarativa de Touchpad\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments](modules/home-manager/desktop/environments)



## desktop\.touchpad\.accelProfile



Perfil de aceleração (adaptive ou flat)\.



*Type:*
one of “adaptive”, “flat”, “default”



*Default:*

```nix
"adaptive"
```

*Declared by:*
 - [modules/home-manager/desktop/environments](modules/home-manager/desktop/environments)



## desktop\.touchpad\.clickMethod



Método de clique físico (clickfinger: 2 dedos botão direito, 3 dedos botão do meio)\.



*Type:*
one of “clickfinger”, “buttonareas”, “default”



*Default:*

```nix
"clickfinger"
```

*Declared by:*
 - [modules/home-manager/desktop/environments](modules/home-manager/desktop/environments)



## desktop\.touchpad\.naturalScrolling



Habilitar rolagem natural (estilo macOS)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments](modules/home-manager/desktop/environments)



## desktop\.touchpad\.speed



Velocidade do ponteiro / aceleração do touchpad\.
Aceita valores entre -1\.0 e 1\.0 (onde 0\.0 é o padrão do sistema e 0\.5 é ágil e rápido)\.



*Type:*
string or signed integer or floating point number



*Default:*

```nix
0.5
```

*Declared by:*
 - [modules/home-manager/desktop/environments](modules/home-manager/desktop/environments)



## desktop\.touchpad\.tapping



Habilitar toque para clicar (Tap to click)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/environments](modules/home-manager/desktop/environments)



## desktop\.wallpaper\.enable



Whether to enable gerenciador e script agnóstico de wallpaper (X11 / Wayland) com suporte multi-monitor e timer\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/wallpaper](modules/home-manager/desktop/wallpaper)



## desktop\.wallpaper\.autostart



Iniciar automaticamente ao abrir a sessão gráfica (via XDG autostart)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/desktop/wallpaper](modules/home-manager/desktop/wallpaper)



## desktop\.wallpaper\.backend



Backend para aplicar o wallpaper (‘auto’ detecta o desktop/display server automaticamente)\.



*Type:*
one of “auto”, “feh”, “swaybg”, “hyprpaper”, “swww”, “xfconf”, “gsettings”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [modules/home-manager/desktop/wallpaper](modules/home-manager/desktop/wallpaper)



## desktop\.wallpaper\.default



Imagem específica padrão (opcional)\. Se omitido, restaura as últimas ou sorteia da pasta\.



*Type:*
null or absolute path or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/wallpaper](modules/home-manager/desktop/wallpaper)



## desktop\.wallpaper\.directory



Caminho da pasta de wallpapers no host\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/wallpaper](modules/home-manager/desktop/wallpaper)



## desktop\.wallpaper\.interval



Intervalo de tempo para rotacionar o wallpaper automaticamente (ex: ‘30s’, ‘5m’, ‘15m’, ‘1h’)\. Se null, não rotaciona por tempo\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/wallpaper](modules/home-manager/desktop/wallpaper)



## desktop\.wallpaper\.mode



Modo de preenchimento ou ajuste da imagem na tela\.



*Type:*
one of “fill”, “center”, “tile”, “scale”, “max”



*Default:*

```nix
"fill"
```

*Declared by:*
 - [modules/home-manager/desktop/wallpaper](modules/home-manager/desktop/wallpaper)



## desktop\.wallpaper\.randomOnStart



Se verdadeiro, sorteia wallpapers aleatórios e diferentes para cada monitor ao iniciar a sessão\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/wallpaper](modules/home-manager/desktop/wallpaper)



## desktop\.wayland\.compositor



Compositor Wayland ativo associado ao shell



*Type:*
null or one of “hyprland”, “mangowm”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland](modules/home-manager/desktop/display-servers/wayland)



## desktop\.wayland\.noctalia\.enable



Habilitar Noctalia Shell integrado para ambientes Wayland com tema Catppuccin Mocha



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/noctalia](modules/home-manager/desktop/display-servers/wayland/noctalia)



## desktop\.wayland\.noctalia\.settings



Configurações declarativas para o Noctalia Desktop Shell (v5+) em config\.toml



*Type:*
TOML value



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/noctalia](modules/home-manager/desktop/display-servers/wayland/noctalia)



## desktop\.wayland\.shell



Ambiente de shell gráfico para Wayland: ‘traditional’, ‘noctalia’ ou null/none para DEs completos (GNOME, KDE, etc\.)



*Type:*
null or one of “traditional”, “noctalia”, “none”



*Default:*

```nix
"traditional"
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland](modules/home-manager/desktop/display-servers/wayland)



## desktop\.wayland\.traditional\.enable



Habilitar conjunto de componentes do Shell Tradicional para Wayland (Waybar, Rofi, Dunst, Hyprlock, Hypridle, Hyprpaper)



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional](modules/home-manager/desktop/display-servers/wayland/traditional)



## desktop\.wayland\.traditional\.dunst\.enable



Habilitar daemon de notificações Dunst para Wayland



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/dunst\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/dunst.nix)



## desktop\.wayland\.traditional\.hypridle\.enable



Habilitar hypridle daemon para o shell tradicional Wayland



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/hypridle\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/hypridle.nix)



## desktop\.wayland\.traditional\.hyprlock\.enable



Habilitar hyprlock lockscreen para o shell tradicional Wayland



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/hyprlock\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/hyprlock.nix)



## desktop\.wayland\.traditional\.hyprpaper\.enable



Habilitar hyprpaper wallpaper daemon para o shell tradicional Wayland



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/hyprpaper\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/hyprpaper.nix)



## desktop\.wayland\.traditional\.rofi\.enable



Habilitar launcher de aplicações Rofi para shell tradicional Wayland



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/rofi\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/rofi.nix)



## desktop\.wayland\.traditional\.waybar\.enable



Habilitar waybar moderna no shell tradicional Wayland



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/desktop/display-servers/wayland/traditional/waybar\.nix](modules/home-manager/desktop/display-servers/wayland/traditional/waybar.nix)



## desktop\.xfce4\.modifierKey



Tecla modificadora principal (Super Key / Mod Key) para o XFCE4\.
Padrão herda de desktop\.modifierKey (“Super”)\.



*Type:*
one of “Super”, “Alt”, “Ctrl”, “super”, “alt”, “ctrl”, “SUPER”, “ALT”, “CTRL”, “Mod4”, “Mod1”, “mod4”, “mod1”



*Default:*

```nix
"Alt"
```

*Declared by:*
 - [modules/home-manager/desktop/environments/xfce4](modules/home-manager/desktop/environments/xfce4)



## system\.cleanup\.enable



Ativa a limpeza automática e declarativa de configurações residuais (~/\.config),
caches (~/\.cache), dados locais (~/\.local/share) e atalhos de desktop de qualquer
aplicação que tenha sido removida ou desativada no Nixfiles\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/cleanup](modules/home-manager/system/cleanup)



## system\.cleanup\.cleanBrokenSymlinks



Remove links simbólicos corrompidos em ~/\.local/share/applications e ~/\.config\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/cleanup](modules/home-manager/system/cleanup)



## system\.cleanup\.cleanCaches



Remove diretórios de cache (~/\.cache/\<app>) de aplicações desativadas\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/cleanup](modules/home-manager/system/cleanup)



## system\.cleanup\.cleanData



Remove diretórios de dados locais (~/\.local/share/\<app>) de aplicações desativadas\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/cleanup](modules/home-manager/system/cleanup)



## system\.cleanup\.cleanOrphanedDesktops



Remove arquivos \.desktop residuais cujos binários apontem para store paths inexistentes\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/cleanup](modules/home-manager/system/cleanup)



## system\.cleanup\.extraPaths



Lista adicional de diretórios ou arquivos a serem limpos caso existam\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/system/cleanup](modules/home-manager/system/cleanup)



## system\.programs\.browsers\.activeBin



Binário executável do navegador padrão ativo\.



*Type:*
null or string *(read only)*



*Default:*

```nix
"librewolf"
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers](modules/home-manager/system/programs/browsers)



## system\.programs\.browsers\.chromium\.enable



Enable’s chrome web based browser\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/chrome](modules/home-manager/system/programs/browsers/chrome)



## system\.programs\.browsers\.chromium\.version



Choose which chromium version you want\.



*Type:*
one of “chromium”, “ungoogled-chromium”, “google-chrome”, “brave”, “vivaldi”, “edge”



*Default:*

```nix
"brave"
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/chrome](modules/home-manager/system/programs/browsers/chrome)



## system\.programs\.browsers\.default



Navegador padrão do sistema (x-scheme-handler/http, text/html, etc)\.
“auto” seleciona o primeiro navegador habilitado (firefox > chromium)\.



*Type:*
one of “auto”, “firefox”, “chromium”, “none”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers](modules/home-manager/system/programs/browsers)



## system\.programs\.browsers\.firefox\.enable



Enable’s firefox web based browser\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/firefox](modules/home-manager/system/programs/browsers/firefox)



## system\.programs\.browsers\.firefox\.preferNvidia



Prefer NVIDIA dGPU via PRIME offload for browser rendering and video acceleration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/firefox](modules/home-manager/system/programs/browsers/firefox)



## system\.programs\.browsers\.firefox\.version



Choose which firefox version you want\.



*Type:*
one of “firefox”, “firefox-devedition”, “firefox-esr”, “floorp”, “librewolf”



*Default:*

```nix
"firefox"
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/firefox](modules/home-manager/system/programs/browsers/firefox)



## system\.programs\.browsers\.psd\.enable



Habilitar Profile-Sync-Daemon (psd) via o módulo oficial services\.psd do Home Manager\.
Por padrão é true se algum navegador estiver habilitado (Firefox/LibreWolf/Floorp ou Chromium/Brave/etc)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/psd\.nix](modules/home-manager/system/programs/browsers/psd.nix)



## system\.programs\.browsers\.psd\.package



Pacote do profile-sync-daemon utilizado\.



*Type:*
package



*Default:*

```nix
<derivation profile-sync-daemon-6.50>
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/psd\.nix](modules/home-manager/system/programs/browsers/psd.nix)



## system\.programs\.browsers\.psd\.backupLimit



Número máximo de snapshots de recuperação a manter no disco\.



*Type:*
signed integer



*Default:*

```nix
5
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/psd\.nix](modules/home-manager/system/programs/browsers/psd.nix)



## system\.programs\.browsers\.psd\.browsers



Lista explícita de navegadores a serem gerenciados pelo PSD\.
Se vazia, detecta automaticamente os navegadores configurados ou disponíveis no sistema\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/psd\.nix](modules/home-manager/system/programs/browsers/psd.nix)



## system\.programs\.browsers\.psd\.resyncTimer



Intervalo de ressincronização automática dos perfis da RAM para o disco\.



*Type:*
string



*Default:*

```nix
"1h"
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/psd\.nix](modules/home-manager/system/programs/browsers/psd.nix)



## system\.programs\.browsers\.psd\.useBackup



Habilitar backups automáticos de segurança para recuperação em caso de travamentos ou falhas de energia\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/browsers/psd\.nix](modules/home-manager/system/programs/browsers/psd.nix)



## system\.programs\.chat\.discord\.enable



Whether to enable Discord client with performance tweaks and dynamic desktop theme\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.chat\.discord\.client



Discord client variant to install (discord = official + OpenASAR/Vencord, vesktop = modern Wayland app)\.



*Type:*
one of “discord”, “vesktop”, “both”



*Default:*

```nix
"discord"
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.chat\.discord\.extraCommandLineArgs



Extra command line flags passed to Discord Electron\.



*Type:*
list of string



*Default:*

```nix
[
  "--ozone-platform-hint=auto"
  "--enable-features=WaylandWindowDecorations"
]
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.chat\.discord\.installPackage



Se deve instalar o executável do Discord/Vesktop via Nix\.
Se false, apenas os arquivos de temas (\.theme\.css) e configurações serão gerenciados, utilizando a versão nativa do sistema hospedeiro (ex: \.deb ou flatpak)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.chat\.discord\.openasar\.enable



Use OpenASAR replacement for faster boot and reduced memory usage\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.chat\.discord\.theme\.enable



Deploy and enable dynamic theme for Discord/Vesktop/Vencord\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.chat\.discord\.useSystemPackage



Atalho conveniente: quando true, equivale a installPackage = false\.
Permite carregar apenas os temas e configurações utilizando o Discord nativo da distro\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.chat\.discord\.useSystemPackages



Alias para useSystemPackage\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.chat\.discord\.vencord\.enable



Inject Vencord into Discord for plugins, themes and screen audio on Linux\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/chat/discord](modules/home-manager/system/programs/chat/discord)



## system\.programs\.console\.bat\.enable



Enable bat cat clone with syntax highlighting\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/console/bat](modules/home-manager/system/programs/console/bat)



## system\.programs\.console\.eza\.enable



Enable eza\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/console/eza](modules/home-manager/system/programs/console/eza)



## system\.programs\.console\.eza\.customTheme



Conteúdo YAML customizado para o tema do eza\. Se nulo, gerado dinamicamente a partir de desktop\.theme\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/system/programs/console/eza](modules/home-manager/system/programs/console/eza)



## system\.programs\.console\.eza\.theme



Tema de eza (legado/compatibilidade)\.



*Type:*
null or string or attribute set of anything



*Default:*

```nix
"catppuccin-macchiato"
```

*Declared by:*
 - [modules/home-manager/system/programs/console/eza](modules/home-manager/system/programs/console/eza)



## system\.programs\.documents\.libreoffice\.enable



Whether to enable Enables libreoffice…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/documents/libreoffice](modules/home-manager/system/programs/documents/libreoffice)



## system\.programs\.documents\.zathura\.enable



Whether to enable Enables Zathura…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/documents/zathura](modules/home-manager/system/programs/documents/zathura)



## system\.programs\.editors\.antigravity\.enable



Whether to enable Google Antigravity AI IDE\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/antigravity](modules/home-manager/system/programs/editors/antigravity)



## system\.programs\.editors\.antigravity\.package



Package or wrapper for Antigravity IDE\.



*Type:*
package



*Default:*

```nix
<derivation antigravity-ide>
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/antigravity](modules/home-manager/system/programs/editors/antigravity)



## system\.programs\.editors\.antigravity\.remoteDebuggingPort



Port to open Chrome DevTools Protocol (CDP) for automation (e\.g\. Antigravity Auto Accept)\.



*Type:*
null or 16 bit unsigned integer; between 0 and 65535 (both inclusive) or string



*Default:*

```nix
"9004"
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/antigravity](modules/home-manager/system/programs/editors/antigravity)



## system\.programs\.editors\.gedit\.enable



Whether to enable GNOME Text Editor (gedit)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/gedit](modules/home-manager/system/programs/editors/gedit)



## system\.programs\.editors\.gedit\.package



Pacote do gedit a ser utilizado\.



*Type:*
package



*Default:*

```nix
<derivation gedit-wrapped>
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/gedit](modules/home-manager/system/programs/editors/gedit)



## system\.programs\.editors\.gedit\.default



Define o gedit como editor padrão de texto plano (text/plain)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/gedit](modules/home-manager/system/programs/editors/gedit)



## system\.programs\.editors\.gedit\.theme



Tema / esquema de cores padrão do gedit\.



*Type:*
string



*Default:*

```nix
"catppuccin_macchiato"
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/gedit](modules/home-manager/system/programs/editors/gedit)



## system\.programs\.editors\.vscode\.enable



Whether to enable VS Code with declarative settings, extensions, and nixGL auto-wrap\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/vscode](modules/home-manager/system/programs/editors/vscode)



## system\.programs\.editors\.vscode\.enableConfigurableSettings



Whether to enable Whether to enable user settings management\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/editors/vscode](modules/home-manager/system/programs/editors/vscode)



## system\.programs\.file-manager\.enableThumbnails



Habilitar serviço global de miniaturas (Tumbler / Freedesktop Thumbnailer) e geradores
(ffmpegthumbnailer, webp, poppler, libgsf, freetype, shared-mime-info) para todos os gerenciadores de arquivos\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager](modules/home-manager/system/programs/file-manager)



## system\.programs\.file-manager\.activeCommand



Comando executável para invocar o gerenciador de arquivos ativo em atalhos de WM e scripts\.



*Type:*
string



*Default:*

```nix
"/nix/store/7zm5rk4qhga6fipd8p6w7yk4f9cmicl4-thunar-with-gvfs/bin/thunar"
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager](modules/home-manager/system/programs/file-manager)



## system\.programs\.file-manager\.default



Gerenciador de arquivos preferido do sistema\.
Se ‘auto’, seleciona automaticamente entre nautilus, nemo, pcmanfm ou thunar conforme ativado\.



*Type:*
one of “auto”, “thunar”, “nautilus”, “nemo”, “pcmanfm”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager](modules/home-manager/system/programs/file-manager)



## system\.programs\.file-manager\.nautilus\.enable



Whether to enable Enable GNOME Files (Nautilus) with GVfs, Sushi preview, extensions, dconf settings, and custom scripts…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.package



Pacote do Nautilus a ser utilizado\.



*Type:*
package



*Default:*

```nix
<derivation nautilus-50.3.1>
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.installPackage



Se deve instalar o executável do Nautilus compilado via Nix/Home Manager\.
Se false, utiliza o binário da distro nativa (ex: Debian /usr/bin/nautilus), mantendo configurações, extensões e scripts\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.openAnyTerminal\.enable



Habilitar extensão nautilus-open-any-terminal\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.openAnyTerminal\.keybinding



Atalho de teclado para abrir o terminal no diretório atual\.



*Type:*
string



*Default:*

```nix
"<Ctrl><Alt>t"
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.openAnyTerminal\.terminal



Terminal preferido para o nautilus-open-any-terminal (ex: alacritty, kitty, auto)\.



*Type:*
string



*Default:*

```nix
"alacritty"
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.sushi\.enable



Habilitar GNOME Sushi (pré-visualização rápida com Barra de Espaço)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.useSystemPackage



Atalho conveniente: quando true, equivale a installPackage = false\.
Permite carregar apenas as configurações, scripts e extensões preservando o Nautilus da distribuição nativa\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.useSystemPackages



Alias para useSystemPackage\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.view\.defaultView



Modo de visualização padrão de pastas no Nautilus\.



*Type:*
one of “icon-view”, “list-view”



*Default:*

```nix
"icon-view"
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.view\.showCreateLink



Exibir opção ‘Criar Link’ no menu de contexto\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.view\.showDeletePermanently



Exibir opção ‘Excluir Permanentemente’ no menu de contexto (sem passar pela lixeira)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.view\.sortDirectoriesFirst



Exibir pastas antes dos arquivos na ordenação\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nautilus\.view\.useTreeView



Habilitar expansão em árvore de pastas (tree view) no modo lista\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nautilus](modules/home-manager/system/programs/file-manager/nautilus)



## system\.programs\.file-manager\.nemo\.enable



Whether to enable Enable Nemo file manager (Cinnamon) with GVfs, thumbnailers, extensions, and custom actions…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nemo](modules/home-manager/system/programs/file-manager/nemo)



## system\.programs\.file-manager\.nemo\.package



Pacote do Nemo a ser utilizado (padrão com extensões compiladas)\.



*Type:*
package



*Default:*

```nix
<derivation nemo-with-extensions-6.6.4>
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nemo](modules/home-manager/system/programs/file-manager/nemo)



## system\.programs\.file-manager\.nemo\.installPackage



Se deve instalar o executável do Nemo compilado via Nix/Home Manager\.
Se false, utiliza o binário da distro nativa (ex: /usr/bin/nemo), mantendo ações, configurações e dotfiles\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nemo](modules/home-manager/system/programs/file-manager/nemo)



## system\.programs\.file-manager\.nemo\.useSystemPackage



Atalho conveniente: quando true, equivale a installPackage = false\.
Permite carregar apenas configurações e ações preservando o Nemo nativo do sistema\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nemo](modules/home-manager/system/programs/file-manager/nemo)



## system\.programs\.file-manager\.nemo\.useSystemPackages



Alias para useSystemPackage\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nemo](modules/home-manager/system/programs/file-manager/nemo)



## system\.programs\.file-manager\.nemo\.view\.defaultView



Modo de visualização padrão no Nemo\.



*Type:*
one of “icon-view”, “compact-view”, “list-view”



*Default:*

```nix
"icon-view"
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nemo](modules/home-manager/system/programs/file-manager/nemo)



## system\.programs\.file-manager\.nemo\.view\.showFullPathTitles



Exibir caminho completo no título da janela\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nemo](modules/home-manager/system/programs/file-manager/nemo)



## system\.programs\.file-manager\.nemo\.view\.showHiddenFiles



Exibir arquivos ocultos por padrão\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/nemo](modules/home-manager/system/programs/file-manager/nemo)



## system\.programs\.file-manager\.pcmanfm\.enable



Whether to enable Enable PCManFM ultra-lightweight file manager with GVfs, thumbnailers, and tabbed browsing…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/pcmanfm](modules/home-manager/system/programs/file-manager/pcmanfm)



## system\.programs\.file-manager\.pcmanfm\.package



Pacote do PCManFM a ser utilizado\.



*Type:*
package



*Default:*

```nix
<derivation pcmanfm-1.4.0>
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/pcmanfm](modules/home-manager/system/programs/file-manager/pcmanfm)



## system\.programs\.file-manager\.pcmanfm\.installPackage



Se deve instalar o executável do PCManFM compilado via Nix/Home Manager\.
Se false, utiliza o binário da distro nativa (ex: /usr/bin/pcmanfm), mantendo configurações e dotfiles\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/pcmanfm](modules/home-manager/system/programs/file-manager/pcmanfm)



## system\.programs\.file-manager\.pcmanfm\.useSystemPackage



Atalho conveniente: quando true, equivale a installPackage = false\.
Permite carregar apenas as configurações preservando o PCManFM do sistema hospedeiro\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/pcmanfm](modules/home-manager/system/programs/file-manager/pcmanfm)



## system\.programs\.file-manager\.pcmanfm\.useSystemPackages



Alias para useSystemPackage\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/pcmanfm](modules/home-manager/system/programs/file-manager/pcmanfm)



## system\.programs\.file-manager\.pcmanfm\.view\.showHidden



Mostrar arquivos ocultos por padrão\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/pcmanfm](modules/home-manager/system/programs/file-manager/pcmanfm)



## system\.programs\.file-manager\.pcmanfm\.view\.viewMode



Modo de visualização padrão de arquivos\.



*Type:*
one of “icon”, “compact”, “detailed”, “thumbnail”



*Default:*

```nix
"detailed"
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/pcmanfm](modules/home-manager/system/programs/file-manager/pcmanfm)



## system\.programs\.file-manager\.thunar\.enable



Whether to enable Enable Thunar file manager with plugins, custom actions (uca\.xml), and thumbnails support…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/thunar](modules/home-manager/system/programs/file-manager/thunar)



## system\.programs\.file-manager\.thunar\.package



Pacote do Thunar empacotado com plugins, GVfs e temas\.



*Type:*
package



*Default:*

```nix
<derivation thunar-with-gvfs>
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/thunar](modules/home-manager/system/programs/file-manager/thunar)



## system\.programs\.file-manager\.thunar\.rememberViewSettings



Relembrar configurações de exibição específicas para cada pasta no Thunar (misc-directory-specific-settings)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/thunar](modules/home-manager/system/programs/file-manager/thunar)



## system\.programs\.file-manager\.thunar\.restoreTabs



Restaurar abas abertas anteriormente ao iniciar o Thunar (last-restore-tabs)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/file-manager/thunar](modules/home-manager/system/programs/file-manager/thunar)



## system\.programs\.multimedia\.audio-recorder\.enable



Enable audio-recorder tool\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/recorder](modules/home-manager/system/programs/multimedia/recorder)



## system\.programs\.multimedia\.mpv\.enable



Whether to enable mpv media player with custom profiles and scripts\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.mpv\.defaultNvidia



Se o MPV deve abrir por padrão utilizando a dGPU NVIDIA (PRIME offload / mpv-nvidia)
no arquivo \.desktop (sobrescrevendo mpv\.desktop), incluindo uma ação secundária
no menu de contexto para abrir com a iGPU Intel\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.mpv\.floating



Se o MPV deve abrir em modo flutuante (floating) em Window Managers (BSPWM, Hyprland, Sway, i3)\.
Defina como false para abrir diretamente em modo tiled na grade\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.mpv\.hybridGraphics



Habilitar suporte e ações de dGPU NVIDIA / PRIME no desktop entry e perfil \[nvidia]\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.mpv\.installPackage



Se deve instalar o executável do MPV compilado via Nix/Home Manager\.
Se definido como false, o Home Manager instalará apenas as configurações (mpv\.conf, input\.conf, scripts e opções de hardware)
e utilizará o binário nativo do sistema operacional hospedeiro (ex: Debian /usr/bin/mpv)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.mpv\.profile



Perfil de hardware para reprodução no MPV:

 - “auto”: decodificação segura automática (vo=gpu, gpu-api=auto, hwdec=auto-safe)
 - “nitro”: perfil otimizado para Intel UHD 630 + NVIDIA dGPU
 - “legacy-nvidia”: perfil para GPUs legadas com driver proprietário antigo (ex: NVIDIA 340)
 - “legacy-nouveau”: perfil para GPUs legadas com driver Nouveau / Mesa
 - “low-ram”: perfil econômico para máquinas com pouca RAM (ex: MacBook Air 2GB)
 - “software”: perfil para renderização puramente por software em VMs sem aceleração 3D



*Type:*
one of “auto”, “nitro”, “legacy-nvidia”, “legacy-nouveau”, “low-ram”, “software”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.mpv\.useSystemPackage



Atalho conveniente: quando true, equivale a installPackage = false\.
Permite carregar apenas as configurações preservando o MPV da distro nativa\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.mpv\.useSystemPackages



Alias para useSystemPackage\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.mpv\.vaapiDevice



Dispositivo de renderização VA-API opcional (ex: /dev/dri/by-path/pci-0000:00:02\.0-render)\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/mpv](modules/home-manager/system/programs/multimedia/mpv)



## system\.programs\.multimedia\.ncmpcpp\.enable



Enables ncmpcpp



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/ncmpcpp](modules/home-manager/system/programs/multimedia/ncmpcpp)



## system\.programs\.multimedia\.rhythmbox\.enable



Whether to enable Rhythmbox music player\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/rhythmbox](modules/home-manager/system/programs/multimedia/rhythmbox)



## system\.programs\.multimedia\.sonixd\.enable



Whether to enable Enables Front end for subsonic server\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/multimedia/sonixd](modules/home-manager/system/programs/multimedia/sonixd)



## system\.programs\.shells\.enable



Enable command-line shell configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.aliases\.enable



Enable useful shell aliases\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.aliases\.nix\.enable



Enable clean Nix command aliases\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.aliases\.nix\.diffProgram



Tool used by ` nd ` to show generation differences\.



*Type:*
one of “builtin”, “nvd”, “nix-diff”



*Default:*

```nix
"builtin"
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.aliases\.process\.enable



Install process-related tools (procs)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.aliases\.systemd\.enable



Enable systemd-related aliases (sc-, scu-, jc- etc\.)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.bash\.blesh\.enable



Habilitar ble\.sh (Bash Line Editor) para predições de histórico, auto-sugestões e completude estilo Fish/Zsh\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/shells/bash](modules/home-manager/system/programs/shells/bash)



## system\.programs\.shells\.default



Default shell to configure\.



*Type:*
one of “bash”, “fish”, “zsh”, “nu”, “nushell”



*Default:*

```nix
"bash"
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.direnv\.enable



Enable direnv with good Nix integration\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.direnv\.nix-direnv



Use nix-direnv for persistent gc-rooted shells\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.fzf\.enable



Enable fzf with rich previews and unified configuration across all shells\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.shells\.starship\.enable



Enable Starship prompt with an aesthetic, lightweight configuration\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/shells](modules/home-manager/system/programs/shells)



## system\.programs\.terminal\.enable



Enable terminal emulator configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal](modules/home-manager/system/programs/terminal)



## system\.programs\.terminal\.package



Pacote opcional do emulador de terminal a ser instalado em home\.packages\.



*Type:*
null or package



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal](modules/home-manager/system/programs/terminal)



## system\.programs\.terminal\.activeCommand



Comando executável agnóstico para invocar o terminal ativo em atalhos de WM e scripts\.



*Type:*
string



*Default:*

```nix
"/nix/store/4n0gj497f4fkz0ngam5w43fzb4pchf90-nixgl-alacritty-0.17.0/bin/alacritty --working-directory $HOME"
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal](modules/home-manager/system/programs/terminal)



## system\.programs\.terminal\.activeName



Nome amigável do terminal ativo para exibição em menus e manuais de atalhos\.



*Type:*
string



*Default:*

```nix
"Alacritty"
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal](modules/home-manager/system/programs/terminal)



## system\.programs\.terminal\.activeWorkingDirCommand



Comando base para abrir o terminal em um diretório de trabalho específico\.



*Type:*
string



*Default:*

```nix
"/nix/store/4n0gj497f4fkz0ngam5w43fzb4pchf90-nixgl-alacritty-0.17.0/bin/alacritty --working-directory"
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal](modules/home-manager/system/programs/terminal)



## system\.programs\.terminal\.command



Comando de invocação customizado para o terminal (ex: “ghostty”, “st -e tmux”, “urxvtc”)\.
Se fornecido, substitui a geração automática de comando baseada em ` name `\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal](modules/home-manager/system/programs/terminal)



## system\.programs\.terminal\.name



Nome do emulador de terminal selecionado para o ambiente de trabalho\.
Pode ser qualquer terminal suportado (ex: “alacritty”, “urxvt”, “kitty”, “foot”, “wezterm”, “xfce4-terminal”, “ghostty”, “st”, “xterm”)
ou qualquer comando customizado presente no PATH\.



*Type:*
null or string



*Default:*

```nix
"alacritty"
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal](modules/home-manager/system/programs/terminal)



## system\.programs\.terminal\.scratchpadCommand



Comando adaptado para abrir o terminal no modo flutuante/scratchpad\.



*Type:*
string



*Default:*

```nix
"/nix/store/4n0gj497f4fkz0ngam5w43fzb4pchf90-nixgl-alacritty-0.17.0/bin/alacritty --class \"$SCRATCHPAD_NAME,$SCRATCHPAD_NAME\" --working-directory \"$HOME\""
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal](modules/home-manager/system/programs/terminal)



## system\.programs\.terminal\.urxvt\.enable



Whether to enable URxvt (rxvt-unicode) terminal emulator with dynamic theme colors and tabbedex/clipboard/vtwheel extensions…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/terminal/urxvt](modules/home-manager/system/programs/terminal/urxvt)



## system\.programs\.tools\.bleachbit\.enable



Whether to enable Enable’s bleachbit…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/bleachbit](modules/home-manager/system/programs/tools/bleachbit)



## system\.programs\.tools\.fastfetch\.enable



Whether to enable Enable Fastfetch system information fetch tool with custom display modules…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.fastfetch\.package



Pacote do Fastfetch a ser utilizado\.



*Type:*
package



*Default:*

```nix
<derivation fastfetch-2.63.1>
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.fastfetch\.display



Configurações visuais de exibição (display) do Fastfetch\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.fastfetch\.extraSettings



Configurações adicionais mescladas ao config\.jsonc gerado pelo Home Manager\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.fastfetch\.installPackage



Se deve instalar o executável do fastfetch via Nix\.
Se false, apenas a configuração (~/\.config/fastfetch/config\.jsonc) será gerenciada, utilizando o binário nativo da distro hospedeira\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.fastfetch\.logo



Configurações de logo do Fastfetch\.



*Type:*
attribute set



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.fastfetch\.modules



Lista declarativa de módulos a serem exibidos no Fastfetch (baseado na suíte do LambBread)\.



*Type:*
list of (string or (attribute set))



*Default:*

```nix
[
  "title"
  "separator"
  "os"
  "host"
  "kernel"
  "uptime"
  "packages"
  "shell"
  "display"
  "de"
  "wm"
  "wmtheme"
  "theme"
  "icons"
  "font"
  "cursor"
  "terminal"
  "terminalfont"
  "cpu"
  "gpu"
  "memory"
  "swap"
  "disk"
  "localip"
  "battery"
  "poweradapter"
  "locale"
  "break"
  "colors"
]
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.fastfetch\.useSystemPackage



Atalho conveniente: quando true, equivale a installPackage = false\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.fastfetch\.useSystemPackages



Alias para useSystemPackage\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/fastfetch](modules/home-manager/system/programs/tools/fastfetch)



## system\.programs\.tools\.flameshot\.enable



Whether to enable Enable Flameshot screenshot tool…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/flameshot](modules/home-manager/system/programs/tools/flameshot)



## system\.programs\.tools\.meld\.enable



Whether to enable Enable’s meld\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/meld](modules/home-manager/system/programs/tools/meld)



## system\.programs\.tools\.ssh\.enable



Enable’s ssh configs\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/ssh](modules/home-manager/system/programs/tools/ssh)



## system\.programs\.tools\.yt-dlp\.enable



Whether to enable Enable yt-dlp with custom aliases and aria2 integration…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/yt-dlp](modules/home-manager/system/programs/tools/yt-dlp)



## system\.programs\.tools\.yt-dlp\.installPackage



Se deve instalar o executável do yt-dlp via Nix\.
Se false, apenas o arquivo de configuração (~/\.config/yt-dlp/config) e aliases serão gerenciados, utilizando o binário nativo da distro hospedeira\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/yt-dlp](modules/home-manager/system/programs/tools/yt-dlp)



## system\.programs\.tools\.yt-dlp\.useSystemPackage



Atalho conveniente: quando true, equivale a installPackage = false\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/yt-dlp](modules/home-manager/system/programs/tools/yt-dlp)



## system\.programs\.tools\.yt-dlp\.useSystemPackages



Alias para useSystemPackage\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/programs/tools/yt-dlp](modules/home-manager/system/programs/tools/yt-dlp)



## system\.services\.fcitx5\.enable



Whether to enable Fcitx5 Input Method Framework com suporte a Japonês (Mozc) e CJK\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/fcitx5](modules/home-manager/system/services/fcitx5)



## system\.services\.flatpak\.enable



Whether to enable Gerenciamento declarativo de Flatpaks via nix-flatpak no Home Manager\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/flatpak](modules/home-manager/system/services/flatpak)



## system\.services\.flatpak\.packages



Lista declarativa de pacotes Flatpak a serem instalados no host\.
Suporta strings com App ID ou attribute sets configurando appId, origin, commit, flatpakref ou bundle\.



*Type:*
list of (string or attribute set of anything)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/system/services/flatpak](modules/home-manager/system/services/flatpak)



## system\.services\.flatpak\.overrides



Permissões e overrides declarativos por aplicativo Flatpak (equivalente ao Flatseal via código)\.



*Type:*
attribute set of anything



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/system/services/flatpak](modules/home-manager/system/services/flatpak)



## system\.services\.flatpak\.remotes



Lista de repositórios remotos do Flatpak (Flathub configurado por padrão)\.



*Type:*
list of attribute set of anything



*Default:*

```nix
[
  {
    location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
    name = "flathub";
  }
]
```

*Declared by:*
 - [modules/home-manager/system/services/flatpak](modules/home-manager/system/services/flatpak)



## system\.services\.flatpak\.uninstallUnmanaged



Se verdadeiro, remove Flatpaks instalados manualmente fora do Nix (convergência estrita)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/services/flatpak](modules/home-manager/system/services/flatpak)



## system\.services\.flatpak\.update\.auto\.enable



Habilitar atualizações automáticas periódicas em background via systemd user timer\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/services/flatpak](modules/home-manager/system/services/flatpak)



## system\.services\.flatpak\.update\.auto\.onCalendar



Expressão OnCalendar do systemd para o timer de auto-atualização (ex: ‘weekly’, ‘daily’)\.



*Type:*
string



*Default:*

```nix
"weekly"
```

*Declared by:*
 - [modules/home-manager/system/services/flatpak](modules/home-manager/system/services/flatpak)



## system\.services\.flatpak\.update\.onActivation



Se verdadeiro, atualiza os Flatpaks a cada home-manager switch (falso por padrão para manter o switch rápido)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/services/flatpak](modules/home-manager/system/services/flatpak)



## system\.services\.git\.enable



Enable git services\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/services/git](modules/home-manager/system/services/git)



## system\.services\.git\.signByDefault



Whether to sign commits by default\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/git](modules/home-manager/system/services/git)



## system\.services\.git\.signingFormat



Format used for signing commits (‘ssh’, ‘openpgp’, or ‘x509’)\.



*Type:*
one of “ssh”, “openpgp”, “x509”



*Default:*

```nix
"ssh"
```

*Declared by:*
 - [modules/home-manager/system/services/git](modules/home-manager/system/services/git)



## system\.services\.git\.signingKey



Path to the SSH public key or GPG key ID used to sign commits\.



*Type:*
null or string



*Default:*

```nix
"~/.ssh/nitro.pub"
```

*Declared by:*
 - [modules/home-manager/system/services/git](modules/home-manager/system/services/git)



## system\.services\.git\.userEmail



The default email\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/home-manager/system/services/git](modules/home-manager/system/services/git)



## system\.services\.git\.userName



The default username\.



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [modules/home-manager/system/services/git](modules/home-manager/system/services/git)



## system\.services\.podman\.enable



Whether to enable Podman rootless container engine with best practices and upstream Home Manager integration…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.enableSocket



Enable Podman API systemd user socket for Docker API compatibility (DevContainers, Compose, etc\.)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.package



The Podman package to use\.



*Type:*
package



*Default:*

```nix
<derivation podman-5.8.9>
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.aliases\.enable



Enable convenient shell aliases for Podman and Docker\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.autoPrune\.enable



Enable periodic systemd user timer to prune unused containers, images, and volumes\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.autoPrune\.flags



Flags passed to ‘podman system prune’\.



*Type:*
list of string



*Default:*

```nix
[
  "--all"
  "--volumes"
  "--force"
  "--filter"
  "until=168h"
]
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.autoPrune\.schedule



Systemd OnCalendar expression for auto-prune\.



*Type:*
string



*Default:*

```nix
"weekly"
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.autoUpdate\.enable



Enable periodic systemd user timer to auto-update containers via upstream Home Manager services\.podman\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.autoUpdate\.schedule



Systemd OnCalendar expression for auto-update\.



*Type:*
string



*Default:*

```nix
"daily"
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.cgroupManager



Cgroup manager to use for rootless containers\.



*Type:*
one of “systemd”, “cgroupfs”



*Default:*

```nix
"systemd"
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.containers



Declarative container definitions forwarded to upstream Home Manager ‘services\.podman\.containers’\.



*Type:*
attribute set of anything



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.dockerCompat



Enable Docker compatibility (docker CLI wrapper, DOCKER_HOST variable and docker\.sock symlink)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.extraPackages\.packages



Additional container packages to install\.



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.extraPackages\.compose



Install podman-compose and docker-compose\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.extraPackages\.inspection



Install skopeo, buildah, and dive for image inspection, building, and layer analysis\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.extraPackages\.lazydocker



Install lazydocker (rich interactive TUI dashboard for containers)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.extraPackages\.tui



Install podman-tui (terminal UI for Podman)\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.network



Default rootless network mode (pasta is high-performance, slirp4netns is classic fallback)\.



*Type:*
one of “pasta”, “slirp4netns”



*Default:*

```nix
"pasta"
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.networks



Declarative network definitions forwarded to upstream Home Manager ‘services\.podman\.networks’\.



*Type:*
attribute set of anything



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.quadlets



Raw Quadlet definitions placed in ~/\.config/containers/systemd/\.



*Type:*
attribute set of strings concatenated with “\\n”



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.registries\.block



List of blocked registries\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.registries\.insecure



List of insecure registries (HTTP or untrusted TLS)\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.registries\.search



List of registries to search when image name is unqualified\.



*Type:*
list of string



*Default:*

```nix
[
  "docker.io"
  "quay.io"
  "ghcr.io"
  "registry.fedoraproject.org"
]
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.registries\.shortNameMode



Short-name resolution mode\. ‘permissive’ avoids interactive prompt blocking in scripts\.



*Type:*
one of “permissive”, “enforcing”, “disabled”



*Default:*

```nix
"permissive"
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.runtime



OCI container runtime (crun is fast, lightweight, and modern)\.



*Type:*
one of “crun”, “runc”



*Default:*

```nix
"crun"
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.storage\.driver



Storage driver to use\.



*Type:*
string



*Default:*

```nix
"overlay"
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.storage\.graphroot



Path to the storage graphroot\. Defaults to ~/\.local/share/containers/storage\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.storage\.mountProgram



Mount program for rootless overlay (fuse-overlayfs ensures high compatibility)\.



*Type:*
null or string



*Default:*

```nix
"/nix/store/72hjbc319c9qb3bwf3x1klldzlfymj7d-fuse-overlayfs-1.17/bin/fuse-overlayfs"
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.storage\.runroot



Path to the storage runroot (tmpfs)\. Defaults to /run/user/\<UID>/containers\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.podman\.volumes



Declarative volume definitions forwarded to upstream Home Manager ‘services\.podman\.volumes’\.



*Type:*
attribute set of anything



*Default:*

```nix
{ }
```

*Declared by:*
 - [modules/home-manager/system/services/podman](modules/home-manager/system/services/podman)



## system\.services\.ssh\.enable



Enable ssh configs\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/home-manager/system/services/ssh](modules/home-manager/system/services/ssh)



## system\.services\.ssh\.identityFiles



SSH IdentityFiles to load by default\.



*Type:*
list of string



*Default:*

```nix
[
  "~/.ssh/nitro"
  "~/.ssh/id_ed25519"
  "~/.ssh/id_rsa"
]
```

*Declared by:*
 - [modules/home-manager/system/services/ssh](modules/home-manager/system/services/ssh)



---

# 2. Opções do NixOS (`desktop.*`, `system.*` e `hardware.*`)

## desktop\.display-managers\.gdm\.enable

Enable GDM as the display manager\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/desktop/display-managers/gdm](modules/nixos/desktop/display-managers/gdm)



## desktop\.display-managers\.lightdm\.enable



Enable LightDM as the display manager\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/desktop/display-managers/lightdm](modules/nixos/desktop/display-managers/lightdm)



## desktop\.display-managers\.name



The selected display-manager for your desktop environment\.



*Type:*
null or one of “lightdm”, “sddm”, “regreet”, “gdm”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/desktop/display-managers](modules/nixos/desktop/display-managers)



## desktop\.display-managers\.regreet\.enable



Enable’s regreet as display manager\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/desktop/display-managers/regreet](modules/nixos/desktop/display-managers/regreet)



## desktop\.display-managers\.sddm\.enable



Enable SDDM as the display manager\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/desktop/display-managers/sddm](modules/nixos/desktop/display-managers/sddm)



## desktop\.display-managers\.sddm\.sddm-theme



The SDDM theme to use\.



*Type:*
one of “sddm-astronaut”, “catppuccin-sddm-corners”, “sddm-sugar-dark”, “sddm-chili-theme”, “abstractdark-sddm-theme”



*Default:*

```nix
"sddm-astronaut"
```

*Declared by:*
 - [modules/nixos/desktop/display-managers/sddm](modules/nixos/desktop/display-managers/sddm)



## desktop\.display-managers\.sddm\.wayland-session



Enable Wayland support\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/desktop/display-managers/sddm](modules/nixos/desktop/display-managers/sddm)



## desktop\.display-servers\.backend



Default backend for the system



*Type:*
null or one of “x11”, “wayland”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/desktop/display-servers](modules/nixos/desktop/display-servers)



## desktop\.display-servers\.x11\.numlock



Ativar numlock na inicializacao da sessao X11 via numlockx\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/desktop/display-servers/x11](modules/nixos/desktop/display-servers/x11)



## hardware\.enableAllFirmware



Whether to enable all firmware, including [unfree packages that must be explictly allowed](https://nixos\.org/manual/nixpkgs/unstable/\#sec-allow-unfree)\.

Alternatively, use the ` hardware.enableRedistributableFirmware ` option\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/all-firmware\.nix](nixos/modules/hardware/all-firmware.nix)



## hardware\.enableAllHardware



Whether to enable Enable support for most hardware\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/all-hardware\.nix](nixos/modules/hardware/all-hardware.nix)



## hardware\.enableRedistributableFirmware



Whether to enable firmware with a license allowing redistribution\.



*Type:*
boolean



*Default:*

```nix
config.hardware.enableAllFirmware
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/all-firmware\.nix](nixos/modules/hardware/all-firmware.nix)



## hardware\.acpilight\.enable



Enable acpilight\.
This will allow brightness control via xbacklight from users in the video group



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/acpilight\.nix](nixos/modules/hardware/acpilight.nix)



## hardware\.alsa\.enable



Whether to set up the user space part of the Advanced Linux Sound Architecture (ALSA)

**Warning:** Enable this option only if you want to use ALSA as your main sound system,
not if you’re using a sound server (e\.g\. PulseAudio or Pipewire)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.enableBluetooth



Whether to enable Bluetooth audio support via BlueALSA\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.enableOSSEmulation



Whether to enable the OSS emulation\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.enablePersistence



Whether to enable ALSA sound card state saving on shutdown\.
This is generally not necessary if you’re using an external sound server\.



*Type:*
boolean



*Default:*

```nix
config.hardware.alsa.enable
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.enableRecorder



Whether to set up a loopback device that continuously records and
allows to play back audio from the computer\.

The loopback device is named ` pcm.recorder `, audio can be saved
by capturing from this device as with any microphone\.

**Note:** By default the output is duplicated to the recorder assuming stereo
audio, for a more complex layout you have to override the pcm\.splitter
device using ` hardware.alsa.config `\.
See the generated /etc/asound\.conf for its definition\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.cardAliases



Assign custom names and reorder the sound cards\.

**Note:** You can find the card ids by looking at ` /proc/asound/cards `\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  soundchip = { driver = "snd_intel_hda"; id = 0; };
  videocard = { driver = "snd_intel_hda"; id = 1; };
  usb       = { driver = "snd_usb_audio"; id = 2; };
}

```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.cardAliases\.\<name>\.driver



Name of the kernel module that provides the card\.



*Type:*
string

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.cardAliases\.\<name>\.id



The ID of the sound card



*Type:*
signed integer



*Default:*

```nix
"default"
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.config



The content of the system-wide ALSA configuration (/etc/asound\.conf)\.

Documentation of the configuration language and examples can be found
in the unofficial ALSA wiki: [https://alsa\.opensrc\.org/Asoundrc](https://alsa\.opensrc\.org/Asoundrc)



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```



*Example:*

```nix
# Send audio to a remote host via SSH
pcm.remote {
  @args [ HOSTNAME ]
  @args.HOSTNAME { type string }
  type file
  format raw
  slave.pcm pcm.null
  file {
    @func concat
    strings [
      "| ${lib.getExec pkgs.openssh} -C "
      $HOSTNAME
      " aplay -f %f -c %c -r %r -"
    ]
  }
}

```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.controls



Virtual volume controls (softvols) to add to a sound card\.
These can be used to control the volume of specific applications
or a digital output device (HDMI video card)\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

````nix
{
  firefox = { device = "front"; maxVolume = -25.0; };
  mpv     = { device = "front"; maxVolume = -25.0; };
  # and run programs with `env ALSA_AUDIO_OUT=<name>`
}

````

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.controls\.\<name>\.card



Name of the PCM card to control (slave)\.



*Type:*
string



*Default:*

```nix
"default"
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.controls\.\<name>\.device



Name of the PCM device to control (slave)\.



*Type:*
string



*Default:*

```nix
"default"
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.controls\.\<name>\.maxVolume



The maximum volume in dB\.



*Type:*
floating point number



*Default:*

```nix
0.0
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.controls\.\<name>\.name



Name of the control, as it appears in ` alsamixer `\.
If null it will be the same as the softvol device name\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.defaultDevice\.capture



The default capture device (i\.e\. microphone)\.
Leave empty to let ALSA pick the default automatically\.

**Note:** The device can be changed at runtime by setting the ALSA_AUDIO_IN
environment variables (but only before starting a program)\.



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"dsnoop:CARD=0,DEV=2"
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.defaultDevice\.playback



The default playback device\.
Leave empty to let ALSA pick the default automatically\.

**Note:** The device can be changed at runtime by setting the ALSA_AUDIO_OUT
environment variables (but only before starting a program)\.



*Type:*
string



*Default:*

```nix
""
```



*Example:*

```nix
"dmix:CARD=1,DEV=0"
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.deviceAliases



Assign custom names to sound cards\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  hdmi1 = "hw:CARD=videocard,DEV=5";
  hdmi2 = "hw:CARD=videocard,DEV=6";
}

```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.alsa\.plugins



List of ALSA plugins to be added to the search path\.



*Type:*
list of package



*Default:*

```nix
[ ]
```



*Example:*

```nix
[ pkgs.bluez-alsa ]
```

*Declared by:*
 - [nixos/modules/services/audio/alsa\.nix](nixos/modules/services/audio/alsa.nix)



## hardware\.amdgpu\.initrd\.enable



Whether to enable loading ` amdgpu ` kernelModule in stage 1\.
Can fix lower resolution in boot screen during initramfs phase
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/amdgpu\.nix](nixos/modules/services/hardware/amdgpu.nix)



## hardware\.amdgpu\.legacySupport\.enable



Whether to enable using ` amdgpu ` kernel driver instead of ` radeon ` for Southern Islands
(Radeon HD 7000) series and Sea Islands (Radeon HD 8000)
series cards\. Note: this removes support for analog video outputs,
which is only available in the ` radeon ` driver
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/amdgpu\.nix](nixos/modules/services/hardware/amdgpu.nix)



## hardware\.amdgpu\.opencl\.enable



Whether to enable OpenCL support using ROCM runtime library\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/amdgpu\.nix](nixos/modules/services/hardware/amdgpu.nix)



## hardware\.amdgpu\.overdrive\.enable



Whether to enable ` amdgpu ` overdrive mode for overclocking\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/amdgpu\.nix](nixos/modules/services/hardware/amdgpu.nix)



## hardware\.amdgpu\.overdrive\.ppfeaturemask



Sets the ` amdgpu.ppfeaturemask ` kernel option\. It can be used to enable the overdrive bit\.
Default is ` 0xfffd7fff ` as it is less likely to cause flicker issues\. Setting it to
` 0xffffffff ` enables all features, but also can be unstable\. See
[the kernel documentation](https://git\.kernel\.org/pub/scm/linux/kernel/git/torvalds/linux\.git/tree/drivers/gpu/drm/amd/include/amd_shared\.h\#n169)
for more information\.



*Type:*
string



*Default:*

```nix
"0xfffd7fff"
```



*Example:*

```nix
"0xffffffff"
```

*Declared by:*
 - [nixos/modules/services/hardware/amdgpu\.nix](nixos/modules/services/hardware/amdgpu.nix)



## hardware\.amdgpu\.zluda\.enable



Whether to enable CUDA support using ZLUDA runtime library\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/amdgpu\.nix](nixos/modules/services/hardware/amdgpu.nix)



## hardware\.amdgpu\.zluda\.package



The zluda package to use\.



*Type:*
package



*Default:*

```nix
pkgs.zluda
```

*Declared by:*
 - [nixos/modules/services/hardware/amdgpu\.nix](nixos/modules/services/hardware/amdgpu.nix)



## hardware\.apple\.touchBar\.enable



Whether to enable support for the Touch Bar on some Apple laptops using tiny-dfr\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/apple-touchbar\.nix](nixos/modules/hardware/apple-touchbar.nix)



## hardware\.apple\.touchBar\.package



The tiny-dfr package to use\.



*Type:*
package



*Default:*

```nix
pkgs.tiny-dfr
```

*Declared by:*
 - [nixos/modules/hardware/apple-touchbar\.nix](nixos/modules/hardware/apple-touchbar.nix)



## hardware\.apple\.touchBar\.settings



Configuration for tiny-dfr\. See [example configuration](https://github\.com/WhatAmISupposedToPutHere/tiny-dfr/blob/master/share/tiny-dfr/config\.toml) for available options\.



*Type:*
TOML value



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  MediaLayerDefault = true;
  ShowButtonOutlines = false;
  EnablePixelShift = true;
}

```

*Declared by:*
 - [nixos/modules/hardware/apple-touchbar\.nix](nixos/modules/hardware/apple-touchbar.nix)



## hardware\.audio\.enable



Enable audio system manager



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/hardware/audio](modules/nixos/hardware/audio)



## hardware\.audio\.manager



Default audio system manager



*Type:*
null or one of “pipewire”, “pulseaudio”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/hardware/audio](modules/nixos/hardware/audio)



## hardware\.audio\.pipewire\.useLowLatencyPipewire



Whether enable low latency configuration\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/hardware/audio/pipewire](modules/nixos/hardware/audio/pipewire)



## hardware\.bladeRF\.enable



Enables udev rules for BladeRF devices\. By default grants access
to users in the “bladerf” group\. You may want to install the
libbladeRF package\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/bladeRF\.nix](nixos/modules/hardware/bladeRF.nix)



## hardware\.block\.defaultScheduler



Default block I/O scheduler\.

Unless ` null `, the value is assigned through a udev rule matching all
block devices\.



*Type:*
null or udev rule value



*Default:*

```nix
null
```



*Example:*

```nix
"kyber"
```

*Declared by:*
 - [nixos/modules/hardware/iosched\.nix](nixos/modules/hardware/iosched.nix)



## hardware\.block\.defaultSchedulerExclude



Device name pattern to exclude from default scheduler assignment
through ` config.hardware.block.defaultScheduler ` and
` config.hardware.block.defaultSchedulerRotational `\.

By default this excludes loop devices which generally do not benefit
from extra I/O scheduling in addition to the scheduling already
performed for their backing devices\.

This setting does not affect ` config.hardware.block.scheduler `\.



*Type:*
null or udev rule value



*Default:*

```nix
"loop[0-9]*"
```

*Declared by:*
 - [nixos/modules/hardware/iosched\.nix](nixos/modules/hardware/iosched.nix)



## hardware\.block\.defaultSchedulerRotational



Default block I/O scheduler for rotational drives (e\.g\. hard disks)\.

Unless ` null `, the value is assigned through a udev rule matching all
rotational block devices\.

This option takes precedence over
` config.hardware.block.defaultScheduler `\.



*Type:*
null or udev rule value



*Default:*

```nix
null
```



*Example:*

```nix
"bfq"
```

*Declared by:*
 - [nixos/modules/hardware/iosched\.nix](nixos/modules/hardware/iosched.nix)



## hardware\.block\.scheduler



Assign block I/O scheduler by device name pattern\.

Names are matched using the [` udev(7) `](https://www.freedesktop.org/software/systemd/man/udev.html) pattern syntax:

 - *‌` * `‌*
   
   Matches zero or more characters\.

 - *‌` ? `‌*
   
   Matches any single character\.

 - *‌` [] `‌*
   
   Matches any single character specified in the brackets\. Ranges are
   supported via the ` - ` character\.

 - *‌` | `‌*
   
   Separates alternative patterns\.

Please note that overlapping patterns may produce unexpected results\.
More complex configurations requiring these should instead be specified
directly through custom udev rules, for example via
[` config.services.udev.extraRules `](\#opt-services\.udev\.extraRules),
to ensure correct ordering\.

Available schedulers depend on the kernel configuration but modern
Linux systems typically support:

 - *‌` none `‌*
   
   No‐operation scheduler with no re‐ordering of requests\. Suitable
   for devices with fast random I/O such as NVMe SSDs\.

 - *‌[` mq-deadline `](https://www\.kernel\.org/doc/html/latest/block/deadline-iosched\.html)‌*
   
   Simple latency‐oriented general‐purpose scheduler\.

 - *‌[` kyber `](https://www\.kernel\.org/doc/html/latest/block/kyber-iosched\.html)‌*
   
   Simple latency‐oriented scheduler for fast multi‐queue devices
   like NVMe SSDs\.

 - *‌[` bfq `](https://www\.kernel\.org/doc/html/latest/block/bfq-iosched\.html)‌*
   
   Complex fairness‐oriented scheduler\. Higher processing overhead,
   but good interactive response, especially with slower devices\.

Schedulers assigned through this option take precedence over
` config.hardware.block.defaultScheduler ` and
` config.hardware.block.defaultSchedulerRotational ` but may be
overridden by other udev rules\.



*Type:*
attribute set of udev rule value



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  "mmcblk[0-9]*" = "bfq";
  "nvme[0-9]*" = "kyber";
}
```

*Declared by:*
 - [nixos/modules/hardware/iosched\.nix](nixos/modules/hardware/iosched.nix)



## hardware\.bluetooth\.enable



Whether to enable support for Bluetooth\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/bluetooth\.nix](nixos/modules/services/hardware/bluetooth.nix)



## hardware\.bluetooth\.package



The bluez package to use\.



*Type:*
package



*Default:*

```nix
pkgs.bluez
```

*Declared by:*
 - [nixos/modules/services/hardware/bluetooth\.nix](nixos/modules/services/hardware/bluetooth.nix)



## hardware\.bluetooth\.disabledPlugins



Built-in plugins to disable



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/services/hardware/bluetooth\.nix](nixos/modules/services/hardware/bluetooth.nix)



## hardware\.bluetooth\.hsphfpd\.enable



Whether to enable support for hsphfpd\[-prototype] implementation\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/bluetooth\.nix](nixos/modules/services/hardware/bluetooth.nix)



## hardware\.bluetooth\.input



Set configuration for the input service (/etc/bluetooth/input\.conf)\.
See [https://github\.com/bluez/bluez/blob/master/profiles/input/input\.conf](https://github\.com/bluez/bluez/blob/master/profiles/input/input\.conf) for full list of options\.



*Type:*
attribute set of section of an INI file (attrs of INI atom (null, bool, int, float or string))



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  General = {
    ClassicBondedOnly = true;
    IdleTimeout = 30;
  };
}
```

*Declared by:*
 - [nixos/modules/services/hardware/bluetooth\.nix](nixos/modules/services/hardware/bluetooth.nix)



## hardware\.bluetooth\.network



Set configuration for the network service (/etc/bluetooth/network\.conf)\.
See [https://github\.com/bluez/bluez/blob/master/profiles/network/network\.conf](https://github\.com/bluez/bluez/blob/master/profiles/network/network\.conf) for full list of options\.



*Type:*
attribute set of section of an INI file (attrs of INI atom (null, bool, int, float or string))



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  General = {
    DisableSecurity = true;
  };
}
```

*Declared by:*
 - [nixos/modules/services/hardware/bluetooth\.nix](nixos/modules/services/hardware/bluetooth.nix)



## hardware\.bluetooth\.powerOnBoot



Whether to power up the default Bluetooth controller on boot\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/bluetooth\.nix](nixos/modules/services/hardware/bluetooth.nix)



## hardware\.bluetooth\.settings



Set configuration for system-wide bluetooth (/etc/bluetooth/main\.conf)\.
See [https://github\.com/bluez/bluez/blob/master/src/main\.conf](https://github\.com/bluez/bluez/blob/master/src/main\.conf) for full list of options\.



*Type:*
attribute set of section of an INI file (attrs of INI atom (null, bool, int, float or string))



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  General = {
    ControllerMode = "bredr";
  };
}
```

*Declared by:*
 - [nixos/modules/services/hardware/bluetooth\.nix](nixos/modules/services/hardware/bluetooth.nix)



## hardware\.brillo\.enable



Whether to enable brillo in userspace\.
This will allow brightness control from users in the video group
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/brillo\.nix](nixos/modules/hardware/brillo.nix)



## hardware\.bumblebee\.enable



Enable the bumblebee daemon to manage Optimus hybrid video cards\.
This should power off secondary GPU until its use is requested
by running an application with optirun\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/video/bumblebee\.nix](nixos/modules/hardware/video/bumblebee.nix)



## hardware\.bumblebee\.connectDisplay



Set to true if you intend to connect your discrete card to a
monitor\. This option will set up your Nvidia card for EDID
discovery and to turn on the monitor signal\.

Only nvidia driver is supported so far\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/video/bumblebee\.nix](nixos/modules/hardware/video/bumblebee.nix)



## hardware\.bumblebee\.driver



Set driver used by bumblebeed\. Supported are nouveau and nvidia\.



*Type:*
one of “nvidia”, “nouveau”



*Default:*

```nix
"nvidia"
```

*Declared by:*
 - [nixos/modules/hardware/video/bumblebee\.nix](nixos/modules/hardware/video/bumblebee.nix)



## hardware\.bumblebee\.group



Group for bumblebee socket



*Type:*
string



*Default:*

```nix
"wheel"
```



*Example:*

```nix
"video"
```

*Declared by:*
 - [nixos/modules/hardware/video/bumblebee\.nix](nixos/modules/hardware/video/bumblebee.nix)



## hardware\.bumblebee\.pmMethod



Set preferred power management method for unused card\.



*Type:*
one of “auto”, “bbswitch”, “switcheroo”, “none”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [nixos/modules/hardware/video/bumblebee\.nix](nixos/modules/hardware/video/bumblebee.nix)



## hardware\.ckb-next\.enable



Whether to enable the Corsair keyboard/mouse driver\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/ckb-next\.nix](nixos/modules/hardware/ckb-next.nix)



## hardware\.ckb-next\.package



The ckb-next package to use\.



*Type:*
package



*Default:*

```nix
pkgs.ckb-next
```

*Declared by:*
 - [nixos/modules/hardware/ckb-next\.nix](nixos/modules/hardware/ckb-next.nix)



## hardware\.ckb-next\.gid



Limit access to the ckb daemon to a particular group\.



*Type:*
null or signed integer



*Default:*

```nix
null
```



*Example:*

```nix
100
```

*Declared by:*
 - [nixos/modules/hardware/ckb-next\.nix](nixos/modules/hardware/ckb-next.nix)



## hardware\.coral\.pcie\.enable



Whether to enable Coral PCIe support\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/coral\.nix](nixos/modules/hardware/coral.nix)



## hardware\.coral\.usb\.enable



Whether to enable Coral USB support\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/coral\.nix](nixos/modules/hardware/coral.nix)



## hardware\.cpu\.enable



Enables cpu hardware defaults



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/nixos/hardware/cpu](modules/nixos/hardware/cpu)



## hardware\.cpu\.enableKvm



Whether to enable kernel hardening options\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/nixos/hardware/cpu](modules/nixos/hardware/cpu)



## hardware\.cpu\.amd\.microcodePackage



The microcode-amd package to use\.



*Type:*
package



*Default:*

```nix
pkgs.microcode-amd
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-microcode\.nix](nixos/modules/hardware/cpu/amd-microcode.nix)



## hardware\.cpu\.amd\.ryzen-smu\.enable



Whether to enable ryzen_smu, a linux kernel driver that exposes access to the SMU (System Management Unit) for certain AMD Ryzen Processors\.

WARNING: Damage cause by use of your AMD processor outside of official AMD specifications or outside of factory settings are not covered under any AMD product warranty and may not be covered by your board or system manufacturer’s warranty
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-ryzen-smu\.nix](nixos/modules/hardware/cpu/amd-ryzen-smu.nix)



## hardware\.cpu\.amd\.sev\.enable



Whether to enable access to the AMD SEV device\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-sev\.nix](nixos/modules/hardware/cpu/amd-sev.nix)



## hardware\.cpu\.amd\.sev\.group



Group to assign to the SEV device\.



*Type:*
string



*Default:*

```nix
"sev"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-sev\.nix](nixos/modules/hardware/cpu/amd-sev.nix)



## hardware\.cpu\.amd\.sev\.mode



Mode to set for the SEV device\.



*Type:*
string



*Default:*

```nix
"0660"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-sev\.nix](nixos/modules/hardware/cpu/amd-sev.nix)



## hardware\.cpu\.amd\.sev\.user



Owner to assign to the SEV device\.



*Type:*
string



*Default:*

```nix
"root"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-sev\.nix](nixos/modules/hardware/cpu/amd-sev.nix)



## hardware\.cpu\.amd\.sevGuest\.enable



Whether to enable access to the AMD SEV guest device\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-sev\.nix](nixos/modules/hardware/cpu/amd-sev.nix)



## hardware\.cpu\.amd\.sevGuest\.group



Group to assign to the SEV guest device\.



*Type:*
string



*Default:*

```nix
"sev-guest"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-sev\.nix](nixos/modules/hardware/cpu/amd-sev.nix)



## hardware\.cpu\.amd\.sevGuest\.mode



Mode to set for the SEV guest device\.



*Type:*
string



*Default:*

```nix
"0660"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-sev\.nix](nixos/modules/hardware/cpu/amd-sev.nix)



## hardware\.cpu\.amd\.sevGuest\.user



Owner to assign to the SEV guest device\.



*Type:*
string



*Default:*

```nix
"root"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-sev\.nix](nixos/modules/hardware/cpu/amd-sev.nix)



## hardware\.cpu\.amd\.updateMicrocode



Update the CPU microcode for AMD processors\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/cpu/amd-microcode\.nix](nixos/modules/hardware/cpu/amd-microcode.nix)



## hardware\.cpu\.cpuVendor



Vendor for the CPU, meant mostly for x86/x86_64 systems\.



*Type:*
one of “intel”, “amd”, “other”



*Default:*

```nix
"other"
```

*Declared by:*
 - [modules/nixos/hardware/cpu](modules/nixos/hardware/cpu)



## hardware\.cpu\.hardenKernel



Whether to enable kernel hardening options\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/nixos/hardware/cpu](modules/nixos/hardware/cpu)



## hardware\.cpu\.improveTCP



Whether to enable tcp extra config…



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/nixos/hardware/cpu](modules/nixos/hardware/cpu)



## hardware\.cpu\.intel\.microcodePackage



The microcode-intel package to use\.



*Type:*
package



*Default:*

```nix
pkgs.microcode-intel
```

*Declared by:*
 - [nixos/modules/hardware/cpu/intel-microcode\.nix](nixos/modules/hardware/cpu/intel-microcode.nix)



## hardware\.cpu\.intel\.npu\.enable



Whether to enable Intel NPU support\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/cpu/intel-npu\.nix](nixos/modules/hardware/cpu/intel-npu.nix)



## hardware\.cpu\.intel\.sgx\.enableDcapCompat



Whether to enable backward compatibility for SGX software build for the
out-of-tree Intel SGX DCAP driver\.

Creates symbolic links for the SGX devices ` /dev/sgx_enclave `
and ` /dev/sgx_provision ` to make them available as
` /dev/sgx/enclave `  and ` /dev/sgx/provision `,
respectively\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/cpu/intel-sgx\.nix](nixos/modules/hardware/cpu/intel-sgx.nix)



## hardware\.cpu\.intel\.sgx\.provision\.enable



Whether to enable access to the Intel SGX provisioning device\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/cpu/intel-sgx\.nix](nixos/modules/hardware/cpu/intel-sgx.nix)



## hardware\.cpu\.intel\.sgx\.provision\.group



Group to assign to the SGX provisioning device\.



*Type:*
string



*Default:*

```nix
"sgx_prv"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/intel-sgx\.nix](nixos/modules/hardware/cpu/intel-sgx.nix)



## hardware\.cpu\.intel\.sgx\.provision\.mode



Mode to set for the SGX provisioning device\.



*Type:*
string



*Default:*

```nix
"0660"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/intel-sgx\.nix](nixos/modules/hardware/cpu/intel-sgx.nix)



## hardware\.cpu\.intel\.sgx\.provision\.user



Owner to assign to the SGX provisioning device\.



*Type:*
string



*Default:*

```nix
"root"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/intel-sgx\.nix](nixos/modules/hardware/cpu/intel-sgx.nix)



## hardware\.cpu\.intel\.updateMicrocode



Update the CPU microcode for Intel processors\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/cpu/intel-microcode\.nix](nixos/modules/hardware/cpu/intel-microcode.nix)



## hardware\.cpu\.x86\.msr\.enable



Whether to enable the ` msr ` (Model-Specific Registers) kernel module and configure ` udev ` rules for its devices (usually ` /dev/cpu/*/msr `)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/cpu/x86-msr\.nix](nixos/modules/hardware/cpu/x86-msr.nix)



## hardware\.cpu\.x86\.msr\.group



Group to set for devices of the ` msr ` kernel subsystem\.



*Type:*
string



*Default:*

```nix
"msr"
```



*Example:*

```nix
"users"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/x86-msr\.nix](nixos/modules/hardware/cpu/x86-msr.nix)



## hardware\.cpu\.x86\.msr\.mode



Mode to set for devices of the ` msr ` kernel subsystem\.



*Type:*
string



*Default:*

```nix
"0640"
```



*Example:*

```nix
"0660"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/x86-msr\.nix](nixos/modules/hardware/cpu/x86-msr.nix)



## hardware\.cpu\.x86\.msr\.owner



Owner to set for devices of the ` msr ` kernel subsystem\.



*Type:*
string



*Default:*

```nix
"root"
```



*Example:*

```nix
"alice"
```

*Declared by:*
 - [nixos/modules/hardware/cpu/x86-msr\.nix](nixos/modules/hardware/cpu/x86-msr.nix)



## hardware\.cpu\.x86\.msr\.settings



Parameters for the ` msr ` kernel module\.



*Type:*
open submodule of attribute set of (boolean or signed integer or string)



*Default:*

```nix
{ }
```

*Declared by:*
 - [nixos/modules/hardware/cpu/x86-msr\.nix](nixos/modules/hardware/cpu/x86-msr.nix)



## hardware\.cpu\.x86\.msr\.settings\.allow-writes



Whether to allow writes to MSRs (` "on" `) or not (` "off" `)\.



*Type:*
null or one of “on”, “off”



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/cpu/x86-msr\.nix](nixos/modules/hardware/cpu/x86-msr.nix)



## hardware\.decklink\.enable



Whether to enable hardware support for the Blackmagic Design Decklink audio/video interfaces\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/decklink\.nix](nixos/modules/hardware/decklink.nix)



## hardware\.deviceTree\.enable



Build device tree files\. These are used to describe the
non-discoverable hardware of a system\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.dtbSource



Path to dtb directory that overlays and other processing will be applied to\. Uses
device trees bundled with the Linux kernel by default\.



*Type:*
absolute path



*Default:*

```nix
${cfg.kernelPackage}/dtbs
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.dtboBuildExtraIncludePaths



Additional include paths that will be passed to the preprocessor when creating the final \.dts to compile into \.dtbo



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  ./my_custom_include_dir_1
  ./custom_include_dir_2
]

```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.dtboBuildExtraPreprocessorFlags



Additional flags to pass to the preprocessor during dtbo compilations



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[ "-DMY_DTB_DEFINE" ]
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.filter

Only include \.dtb files matching glob expression\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"*rpi*.dtb"
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.kernelPackage



Kernel package where device tree include directory is from\. Also used as default source of dtb package to apply overlays to



*Type:*
absolute path



*Default:*

```nix
config.boot.kernelPackages.kernel
```



*Example:*

```nix
pkgs.linux_latest
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.name



The name of an explicit dtb to be loaded, relative to the dtb base\.
Useful in extlinux scenarios if the bootloader doesn’t pick the
right \.dtb file from FDTDIR\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"some-dtb.dtb"
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.overlays



List of overlays to apply to base device-tree (\.dtb) files\.



*Type:*
list of ((submodule) or absolute path convertible to it)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  { name = "pps"; dtsFile = ./dts/pps.dts; }
  { name = "spi";
    dtsText = "...";
  }
  { name = "precompiled"; dtboFile = ./dtbos/example.dtbo; }
]

```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.overlays\.\*\.dtboFile



Path to \.dtbo compiled overlay file\.



*Type:*
null or absolute path



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.overlays\.\*\.dtsFile



Path to \.dts overlay file, overlay is applied to
each \.dtb file matching “compatible” of the overlay\.



*Type:*
null or absolute path



*Default:*

```nix
null
```



*Example:*

```nix
./dts/overlays.dts
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.overlays\.\*\.dtsText



Literal DTS contents, overlay is applied to
each \.dtb file matching “compatible” of the overlay\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
''
  /dts-v1/;
  /plugin/;
  / {
          compatible = "raspberrypi";
  };
  &{/soc} {
          pps {
                  compatible = "pps-gpio";
                  status = "okay";
          };
  };
''
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.overlays\.\*\.filter



Only apply to \.dtb files matching glob expression\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"*rpi*.dtb"
```

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.deviceTree\.overlays\.\*\.name



Name of this overlay



*Type:*
string

*Declared by:*
 - [nixos/modules/hardware/device-tree\.nix](nixos/modules/hardware/device-tree.nix)



## hardware\.digitalbitbox\.enable



Enables udev rules for Digital Bitbox devices\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/digitalbitbox\.nix](nixos/modules/hardware/digitalbitbox.nix)



## hardware\.digitalbitbox\.package



The digitalbitbox package to use\. This can be used to install a package with udev rules that differ from the defaults\.



*Type:*
package



*Default:*

```nix
pkgs.digitalbitbox
```

*Declared by:*
 - [nixos/modules/hardware/digitalbitbox\.nix](nixos/modules/hardware/digitalbitbox.nix)



## hardware\.display\.edid\.enable



Enables handling of EDID files



*Type:*
boolean



*Default:*

```nix
config.hardware.display.edid.packages != null
```

*Declared by:*
 - [nixos/modules/services/hardware/display\.nix](nixos/modules/services/hardware/display.nix)



## hardware\.display\.edid\.packages



List of packages containing EDID binary files at ` $out/lib/firmware/edid `\.
Such files will be available for use in ` drm.edid_firmware ` kernel
parameter as ` edid/<filename> `\.

You can craft one directly here or use sibling options ` linuxhw ` and ` modelines `\.



*Type:*
list of package



*Default:*

```nix
[ ]
```



*Example:*

````nix
[
  (pkgs.runCommand "edid-custom" {} ''
    mkdir -p "$out/lib/firmware/edid"
    base64 -d > "$out/lib/firmware/edid/custom1.bin" <<'EOF'
    <insert your base64 encoded EDID file here `base64 < /sys/class/drm/card0-.../edid`>
    EOF
  '')
]

````

*Declared by:*
 - [nixos/modules/services/hardware/display\.nix](nixos/modules/services/hardware/display.nix)



## hardware\.display\.edid\.linuxhw



Exposes EDID files from users-sourced database at [https://github\.com/linuxhw/EDID](https://github\.com/linuxhw/EDID)

Attribute names will be mapped to EDID filenames ` <NAME>.bin `\.

Attribute values are lists of ` awk ` regexp patterns that (together) must match
exactly one line in either of:

 - [AnalogDisplay\.md](https://raw\.githubusercontent\.com/linuxhw/EDID/master/AnalogDisplay\.md)
 - [DigitalDisplay\.md](https://raw\.githubusercontent\.com/linuxhw/EDID/master/DigitalDisplay\.md)

There is no universal way of locating your device config, but here are some practical tips:

 1. locate your device:

 - find your model number (second column)
 - locate manufacturer (first column) and go through the list manually

 2. narrow down results using other columns until there is only one left:

 - ` Name ` column
 - production date (` Made ` column)
 - resolution ` Res `
 - screen diagonal (` Inch ` column)
 - as a last resort use ` ID ` from the last column



*Type:*
attribute set of list of string



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  PG278Q_2014 = [ "PG278Q" "2014" ];
}

```

*Declared by:*
 - [nixos/modules/services/hardware/display\.nix](nixos/modules/services/hardware/display.nix)



## hardware\.display\.edid\.modelines



Attribute set of XFree86 Modelines automatically converted
and exposed as ` edid/<name>.bin ` files in initrd\.
See for more information:

 - [https://en\.wikipedia\.org/wiki/XFree86_Modeline](https://en\.wikipedia\.org/wiki/XFree86_Modeline)



*Type:*
attribute set of string



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  "PG278Q_60" = "    241.50   2560 2608 2640 2720   1440 1443 1448 1481   -hsync +vsync";
  "PG278Q_120" = "   497.75   2560 2608 2640 2720   1440 1443 1448 1525   +hsync -vsync";
  "U2711_60" = "     241.50   2560 2600 2632 2720   1440 1443 1448 1481   -hsync +vsync";
}

```

*Declared by:*
 - [nixos/modules/services/hardware/display\.nix](nixos/modules/services/hardware/display.nix)



## hardware\.display\.outputs



Hardware/kernel-level configuration of specific outputs\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  edid.modelines."PG278Q_60" = "241.50   2560 2608 2640 2720   1440 1443 1448 1481   -hsync +vsync";
  outputs."DP-1".edid = "PG278Q_60.bin";
  outputs."DP-1".mode = "e";
}

```

*Declared by:*
 - [nixos/modules/services/hardware/display\.nix](nixos/modules/services/hardware/display.nix)



## hardware\.display\.outputs\.\<name>\.edid



An EDID filename to be used for configured display, as in ` edid/<filename> `\.
See for more information:

 - ` hardware.display.edid.packages `
 - [https://wiki\.archlinux\.org/title/Kernel_mode_setting\#Forcing_modes_and_EDID](https://wiki\.archlinux\.org/title/Kernel_mode_setting\#Forcing_modes_and_EDID)



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/services/hardware/display\.nix](nixos/modules/services/hardware/display.nix)



## hardware\.display\.outputs\.\<name>\.mode



A ` video ` kernel parameter (framebuffer mode) configuration for the specific output:

```
<xres>x<yres>[M][R][-<bpp>][@<refresh>][i][m][eDd]
```

See for more information:

 - [https://docs\.kernel\.org/fb/modedb\.html](https://docs\.kernel\.org/fb/modedb\.html)
 - [https://wiki\.archlinux\.org/title/Kernel_mode_setting\#Forcing_modes](https://wiki\.archlinux\.org/title/Kernel_mode_setting\#Forcing_modes)



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"e"

```

*Declared by:*
 - [nixos/modules/services/hardware/display\.nix](nixos/modules/services/hardware/display.nix)



## hardware\.facetimehd\.enable



Whether to enable the facetimehd kernel module\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/webcam/facetimehd\.nix](nixos/modules/hardware/video/webcam/facetimehd.nix)



## hardware\.facetimehd\.withCalibration



Whether to include sensor calibration files for facetimehd\.
This makes colors look much better but is experimental, see
[https://github\.com/patjak/facetimehd/wiki/Extracting-the-sensor-calibration-files](https://github\.com/patjak/facetimehd/wiki/Extracting-the-sensor-calibration-files)
for details\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/webcam/facetimehd\.nix](nixos/modules/hardware/video/webcam/facetimehd.nix)



## hardware\.facter\.enable



Whether to enable automatic hardware configuration using a report generated by nixos-facter\.

See [https://nix-community\.github\.io/nixos-facter/](https://nix-community\.github\.io/nixos-facter/) for more information\.



*Type:*
boolean



*Default:*

```nix
config.hardware.facter.report != { }

```

*Declared by:*
 - [nixos/modules/hardware/facter](nixos/modules/hardware/facter)



## hardware\.facter\.debug\.nix-diff



A shell application which will produce a nix-diff of the system closure with and without facter enabled\.



*Type:*
package

*Declared by:*
 - [nixos/modules/hardware/facter/debug\.nix](nixos/modules/hardware/facter/debug.nix)



## hardware\.facter\.debug\.nvd



A shell application which will produce an nvd diff of the system closure with and without facter enabled\.



*Type:*
package

*Declared by:*
 - [nixos/modules/hardware/facter/debug\.nix](nixos/modules/hardware/facter/debug.nix)



## hardware\.facter\.detected\.bluetooth\.enable



Whether to enable Enable the Facter bluetooth module\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/bluetooth\.nix](nixos/modules/hardware/facter/bluetooth.nix)



## hardware\.facter\.detected\.boot\.disk\.kernelModules



List of kernel modules that are needed to access the disk\.



*Type:*
list of string



*Default:*

```nix
"hardware dependent"
```

*Declared by:*
 - [nixos/modules/hardware/facter/disk\.nix](nixos/modules/hardware/facter/disk.nix)



## hardware\.facter\.detected\.boot\.graphics\.kernelModules



List of kernel modules to load at boot for the graphics card\.



*Type:*
list of string



*Default:*

```nix
"hardware dependent"
```

*Declared by:*
 - [nixos/modules/hardware/facter/graphics](nixos/modules/hardware/facter/graphics)



## hardware\.facter\.detected\.boot\.initrd\.networking\.kernelModules



List of kernel modules to include in the initrd to support networking\.



*Type:*
list of string



*Default:*

```nix
"hardware dependent"
```

*Declared by:*
 - [nixos/modules/hardware/facter/networking/initrd\.nix](nixos/modules/hardware/facter/networking/initrd.nix)



## hardware\.facter\.detected\.boot\.keyboard\.kernelModules



List of kernel modules to include in the initrd to support the keyboard\.



*Type:*
list of string



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
[
  "usbhid"
]
```

*Declared by:*
 - [nixos/modules/hardware/facter/keyboard\.nix](nixos/modules/hardware/facter/keyboard.nix)



## hardware\.facter\.detected\.camera\.ipu6\.enable



Whether to enable webcams using ipu6 from Intel\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/camera/ipu6\.nix](nixos/modules/hardware/facter/camera/ipu6.nix)



## hardware\.facter\.detected\.dhcp\.enable



Whether to enable Facter dhcp module\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/networking](nixos/modules/hardware/facter/networking)



## hardware\.facter\.detected\.dhcp\.interfaces



List of network interface names to configure with DHCP\. Defaults to auto-detected physical interfaces\.



*Type:*
list of string



*Default:*

```nix
automatically detected from facter report
```



*Example:*

```nix
[
  "eth0"
  "wlan0"
]
```

*Declared by:*
 - [nixos/modules/hardware/facter/networking](nixos/modules/hardware/facter/networking)



## hardware\.facter\.detected\.fingerprint\.enable



Whether to enable Fingerprint devices\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/fingerprint](nixos/modules/hardware/facter/fingerprint)



## hardware\.facter\.detected\.graphics\.enable



Whether to enable Enable the Graphics module\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/graphics](nixos/modules/hardware/facter/graphics)



## hardware\.facter\.detected\.graphics\.amd\.enable



Whether to enable Enable the AMD Graphics module\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/graphics/amd\.nix](nixos/modules/hardware/facter/graphics/amd.nix)



## hardware\.facter\.detected\.networking\.intel\._2200BG\.enable



Whether to enable the Facter Intel 2200BG module\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/networking/intel\.nix](nixos/modules/hardware/facter/networking/intel.nix)



## hardware\.facter\.detected\.networking\.intel\._3945ABG\.enable



Whether to enable the Facter Intel 3945ABG module\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/networking/intel\.nix](nixos/modules/hardware/facter/networking/intel.nix)



## hardware\.facter\.detected\.uefi\.supported



Whether to enable the facter uefi module\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/boot\.nix](nixos/modules/hardware/facter/boot.nix)



## hardware\.facter\.detected\.virtualisation\.hyperv\.enable



Whether to enable Enable the Facter Virtualisation Hyper-V module\.



*Type:*
boolean



*Default:*

```nix
"environment dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/virtualisation\.nix](nixos/modules/hardware/facter/virtualisation.nix)



## hardware\.facter\.detected\.virtualisation\.none\.enable



Whether to enable Enable the Facter Virtualisation None module\.



*Type:*
boolean



*Default:*

```nix
"environment dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/virtualisation\.nix](nixos/modules/hardware/facter/virtualisation.nix)



## hardware\.facter\.detected\.virtualisation\.oracle\.enable



Whether to enable Enable the Facter Virtualisation Oracle module\.



*Type:*
boolean



*Default:*

```nix
"environment dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/virtualisation\.nix](nixos/modules/hardware/facter/virtualisation.nix)



## hardware\.facter\.detected\.virtualisation\.parallels\.enable



Whether to enable Enable the Facter Virtualisation Parallels module\.



*Type:*
boolean



*Default:*

```nix
"environment dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/virtualisation\.nix](nixos/modules/hardware/facter/virtualisation.nix)



## hardware\.facter\.detected\.virtualisation\.qemu\.enable



Whether to enable Enable the Facter Virtualisation Qemu module\.



*Type:*
boolean



*Default:*

```nix
"environment dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/virtualisation\.nix](nixos/modules/hardware/facter/virtualisation.nix)



## hardware\.facter\.detected\.virtualisation\.virtio_scsi\.enable



Whether to enable Enable the Facter Virtualisation Virtio SCSI module\.



*Type:*
boolean



*Default:*

```nix
"hardware dependent"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/facter/virtualisation\.nix](nixos/modules/hardware/facter/virtualisation.nix)



## hardware\.facter\.report



Hardware report data generated by nixos-facter\.

See [https://nix-community\.github\.io/nixos-facter/](https://nix-community\.github\.io/nixos-facter/) for more information\.



*Type:*
attribute set of anything



*Default:*

```nix
"A JSON import from config.hardware.facter.reportPath (if not null), {} otherwise."
```

*Declared by:*
 - [nixos/modules/hardware/facter](nixos/modules/hardware/facter)



## hardware\.facter\.reportPath



Path to a hardware report generated by nixos-facter\.

To generate a report, run the following as root:

```
nix-shell -p nixos-facter --run nixos-facter > facter.json
```

See [https://nix-community\.github\.io/nixos-facter/](https://nix-community\.github\.io/nixos-facter/) for more information\.



*Type:*
null or absolute path



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/facter](nixos/modules/hardware/facter)



## hardware\.fancontrol\.enable



Whether to enable software fan control (requires fancontrol\.config)\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/fancontrol\.nix](nixos/modules/services/hardware/fancontrol.nix)



## hardware\.fancontrol\.config



Required fancontrol configuration file content\. See ` pwmconfig(8) ` from the lm_sensors package\.



*Type:*
strings concatenated with “\\n”



*Example:*

```nix
''
  # Configuration file generated by pwmconfig
  INTERVAL=10
  DEVPATH=hwmon3=devices/virtual/thermal/thermal_zone2 hwmon4=devices/platform/f71882fg.656
  DEVNAME=hwmon3=soc_dts1 hwmon4=f71869a
  FCTEMPS=hwmon4/device/pwm1=hwmon3/temp1_input
  FCFANS=hwmon4/device/pwm1=hwmon4/device/fan1_input
  MINTEMP=hwmon4/device/pwm1=35
  MAXTEMP=hwmon4/device/pwm1=65
  MINSTART=hwmon4/device/pwm1=150
  MINSTOP=hwmon4/device/pwm1=0
''
```

*Declared by:*
 - [nixos/modules/services/hardware/fancontrol\.nix](nixos/modules/services/hardware/fancontrol.nix)



## hardware\.firmware



List of packages containing firmware files\.  Such files
will be loaded automatically if the kernel asks for them
(i\.e\., when it has detected specific hardware that requires
firmware to function)\.  If multiple packages contain firmware
files with the same name, the first package in the list takes
precedence\.  Note that you must rebuild your system if you add
files to any of these directories\.



*Type:*
list of package



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/services/hardware/udev\.nix](nixos/modules/services/hardware/udev.nix)



## hardware\.firmwareCompression



Whether to compress firmware files\.
Defaults depend on the kernel version\.
For kernels older than 5\.3, firmware files are not compressed\.
For kernels 5\.3 and newer, firmware files are compressed with xz\.
For kernels 5\.19 and newer, firmware files are compressed with zstd\.



*Type:*
one of “xz”, “zstd”, “none”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [nixos/modules/services/hardware/udev\.nix](nixos/modules/services/hardware/udev.nix)



## hardware\.flipperzero\.enable



Whether to enable udev rules and software for Flipper Zero devices\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/flipperzero\.nix](nixos/modules/hardware/flipperzero.nix)



## hardware\.flirc\.enable



Whether to enable software to configure a Flirc USB device\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/flirc\.nix](nixos/modules/hardware/flirc.nix)



## hardware\.fw-fanctrl\.enable



Whether to enable the fw-fanctrl systemd service and install the needed packages\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.package



The fw-fanctrl package to use\.



*Type:*
package



*Default:*

```nix
pkgs.fw-fanctrl
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config



Additional config entries for the fw-fanctrl service (documentation: [https://github\.com/TamtamHero/fw-fanctrl/blob/main/doc/configuration\.md](https://github\.com/TamtamHero/fw-fanctrl/blob/main/doc/configuration\.md))



*Type:*
open submodule of attribute set of (JSON value)



*Default:*

```nix
{ }
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config\.defaultStrategy



Default strategy to use



*Type:*
string



*Default:*

```nix
"lazy"
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config\.strategies



Additional strategies which can be used by fw-fanctrl



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config\.strategies\.\<name>\.fanSpeedUpdateFrequency



How often the fan speed should be updated in seconds



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
5
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config\.strategies\.\<name>\.movingAverageInterval



Interval (seconds) of the last temperatures to use to calculate the average temperature



*Type:*
unsigned integer, meaning >=0



*Default:*

```nix
25
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config\.strategies\.\<name>\.speedCurve



How should the speed curve look like



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config\.strategies\.\<name>\.speedCurve\.\*\.speed



Percent how fast the fan should run at



*Type:*
integer between 0 and 100 (both inclusive)



*Default:*

```nix
0
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config\.strategies\.\<name>\.speedCurve\.\*\.temp



Temperature in °C at which the fan speed should be changed



*Type:*
signed integer



*Default:*

```nix
0
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.config\.strategyOnDischarging



Default strategy on discharging



*Type:*
string



*Default:*

```nix
""
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.disableBatteryTempCheck



Disable checking battery temperature sensor



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.fw-fanctrl\.ectoolPackage



The fw-ectool package to use\.



*Type:*
package



*Default:*

```nix
pkgs.fw-ectool
```

*Declared by:*
 - [nixos/modules/hardware/fw-fanctrl\.nix](nixos/modules/hardware/fw-fanctrl.nix)



## hardware\.glasgow\.enable



Enables Glasgow udev rules and ensures ‘plugdev’ group exists\.
This is a prerequisite to using Glasgow without being root\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/glasgow\.nix](nixos/modules/hardware/glasgow.nix)



## hardware\.gpgSmartcards\.enable



Whether to enable udev rules for gnupg smart cards\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/gpgsmartcards\.nix](nixos/modules/hardware/gpgsmartcards.nix)



## hardware\.graphics\.enable



Whether to enable hardware accelerated graphics drivers\.

This is required to allow most graphical applications and
environments to use hardware rendering, video encode/decode
acceleration, etc\.

This option should be enabled by default by the corresponding modules,
so you do not usually have to set it yourself\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/graphics\.nix](nixos/modules/hardware/graphics.nix)



## hardware\.graphics\.enable32Bit



On 64-bit systems, whether to also install 32-bit drivers for
32-bit applications (such as Wine)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/graphics\.nix](nixos/modules/hardware/graphics.nix)



## hardware\.graphics\.package



The package that provides the default driver set\.



*Type:*
package

*Declared by:*
 - [nixos/modules/hardware/graphics\.nix](nixos/modules/hardware/graphics.nix)



## hardware\.graphics\.package32



The package that provides the 32-bit driver set\. Used when ` enable32Bit ` is enabled\.



*Type:*
package

*Declared by:*
 - [nixos/modules/hardware/graphics\.nix](nixos/modules/hardware/graphics.nix)



## hardware\.graphics\.cards\.enable



Enable graphics for selected device\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/nixos/hardware/graphics](modules/nixos/hardware/graphics)



## hardware\.graphics\.cards\.acceleration



Enables graphics acceleration



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/hardware/graphics](modules/nixos/hardware/graphics)



## hardware\.graphics\.cards\.gpu



Manufacturer/type of the primary system GPU



*Type:*
null or one of “amd”, “intel”, “nvidia”, “nvidia-legacy”, “hybrid-nvidia”, “hybrid-amd”, “integrated-amd”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/hardware/graphics](modules/nixos/hardware/graphics)



## hardware\.graphics\.extraPackages



Additional packages to add to the default graphics driver lookup path\.
This can be used to add OpenCL drivers, VA-API/VDPAU drivers, etc\.

**Note:** intel-media-driver supports hardware Broadwell (2014) or newer\. Older hardware should use the mostly unmaintained intel-vaapi-driver driver\.



*Type:*
list of package



*Default:*

```nix
[ ]
```



*Example:*

```nix
with pkgs; [ intel-media-driver intel-ocl intel-vaapi-driver ]
```

*Declared by:*
 - [nixos/modules/hardware/graphics\.nix](nixos/modules/hardware/graphics.nix)



## hardware\.graphics\.extraPackages32



Additional packages to add to 32-bit graphics driver lookup path on 64-bit systems\.
Used when ` enable32Bit ` is set\. This can be used to add OpenCL drivers, VA-API/VDPAU drivers, etc\.

**Note:** intel-media-driver supports hardware Broadwell (2014) or newer\. Older hardware should use the mostly unmaintained intel-vaapi-driver driver\.



*Type:*
list of package



*Default:*

```nix
[ ]
```



*Example:*

```nix
with pkgs.pkgsi686Linux; [ intel-media-driver intel-vaapi-driver ]
```

*Declared by:*
 - [nixos/modules/hardware/graphics\.nix](nixos/modules/hardware/graphics.nix)



## hardware\.hackrf\.enable



Enables hackrf udev rules and ensures ‘plugdev’ group exists\.
This is a prerequisite to using HackRF devices without being root, since HackRF USB descriptors will be owned by plugdev through udev\.
Ensure your user is a member of the ‘plugdev’ group after enabling\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/hackrf\.nix](nixos/modules/hardware/hackrf.nix)



## hardware\.hid-fanatecff\.enable



Whether to enable hid-fanatecff, a Linux kernel driver that aims to add support for Fanatec devices\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/hid-fanatecff\.nix](nixos/modules/hardware/hid-fanatecff.nix)



## hardware\.i2c\.enable



Whether to enable i2c devices support\. By default access is granted to users in the “i2c”
group (will be created if non-existent) and any user with a seat, meaning
logged on the computer locally
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/i2c\.nix](nixos/modules/hardware/i2c.nix)



## hardware\.i2c\.group



Grant access to i2c devices (/dev/i2c-\*) to users in this group\.



*Type:*
string



*Default:*

```nix
"i2c"
```

*Declared by:*
 - [nixos/modules/hardware/i2c\.nix](nixos/modules/hardware/i2c.nix)



## hardware\.infiniband\.enable



Whether to enable Infiniband support\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/infiniband\.nix](nixos/modules/hardware/infiniband.nix)



## hardware\.infiniband\.guids



A list of infiniband port guids on the system\. This is discoverable using ` ibstat -p `



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "0xe8ebd30000eee2e1"
]
```

*Declared by:*
 - [nixos/modules/hardware/infiniband\.nix](nixos/modules/hardware/infiniband.nix)



## hardware\.inputmodule\.enable



Whether to enable Support for Framework input modules\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/inputmodule\.nix](nixos/modules/hardware/inputmodule.nix)



## hardware\.intel-gpu-tools\.enable



Whether to enable a setcap wrapper for intel-gpu-tools\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/intel-gpu-tools\.nix](nixos/modules/hardware/video/intel-gpu-tools.nix)



## hardware\.ipu6\.enable



Whether to enable support for Intel IPU6/MIPI cameras\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/webcam/ipu6\.nix](nixos/modules/hardware/video/webcam/ipu6.nix)



## hardware\.ipu6\.platform



Choose the version for your hardware platform\.

Use ` ipu6 ` for Tiger Lake, ` ipu6ep ` for Alder Lake or Raptor Lake,
and ` ipu6epmtl ` for Meteor Lake\.



*Type:*
one of “ipu6”, “ipu6ep”, “ipu6epmtl”

*Declared by:*
 - [nixos/modules/hardware/video/webcam/ipu6\.nix](nixos/modules/hardware/video/webcam/ipu6.nix)



## hardware\.ipu6\.videoDeviceNumber



v4l2loopback device number for the relay output (` /dev/videoN `)\.

Must be fixed so application camera permission grants, which are keyed to
the PipeWire node name (derived from the sysfs device path), survive
reboots\. Choose a number above the IPU6 raw node range (typically 3-34)
and any other v4l2loopback devices on the system\.



*Type:*
signed integer



*Default:*

```nix
50
```

*Declared by:*
 - [nixos/modules/hardware/video/webcam/ipu6\.nix](nixos/modules/hardware/video/webcam/ipu6.nix)



## hardware\.keyboard\.qmk\.enable



Whether to enable non-root access to the firmware of QMK keyboards\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/keyboard/qmk\.nix](nixos/modules/hardware/keyboard/qmk.nix)



## hardware\.keyboard\.qmk\.keychronSupport



Whether to enable udev rules for keychron QMK based keyboards\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/keyboard/qmk\.nix](nixos/modules/hardware/keyboard/qmk.nix)



## hardware\.keyboard\.teck\.enable



Whether to enable non-root access to the firmware of TECK keyboards\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/keyboard/teck\.nix](nixos/modules/hardware/keyboard/teck.nix)



## hardware\.keyboard\.uhk\.enable



Whether to enable non-root access to the firmware of UHK keyboards\.
You need it when you want to flash a new firmware on the keyboard\.
Access to the keyboard is granted to users in the “input” group\.
You may want to install the uhk-agent package
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/keyboard/uhk\.nix](nixos/modules/hardware/keyboard/uhk.nix)



## hardware\.keyboard\.zsa\.enable



Whether to enable udev rules for keyboards from ZSA like the ErgoDox EZ, Planck EZ and Moonlander Mark I\.
You need it when you want to flash a new configuration on the keyboard
or use their live training in the browser\.
You may want to install the wally-cli package
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/keyboard/zsa\.nix](nixos/modules/hardware/keyboard/zsa.nix)



## hardware\.kryoflux\.enable



Enables kryoflux udev rules, ensures ‘floppy’ group exists\. This is a
prerequisite to using devices supported by kryoflux without being root,
since kryoflux device descriptors will be owned by floppy through udev\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/kryoflux\.nix](nixos/modules/hardware/kryoflux.nix)



## hardware\.kryoflux\.package



The kryoflux package to use\.



*Type:*
package



*Default:*

```nix
pkgs.kryoflux
```

*Declared by:*
 - [nixos/modules/hardware/kryoflux\.nix](nixos/modules/hardware/kryoflux.nix)



## hardware\.ksm\.enable



Whether to enable Linux kernel Same-Page Merging\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/ksm\.nix](nixos/modules/hardware/ksm.nix)



## hardware\.ksm\.sleep



How many milliseconds ksmd should sleep between scans\.
Setting it to ` null ` uses the kernel’s default time\.



*Type:*
null or signed integer



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/ksm\.nix](nixos/modules/hardware/ksm.nix)



## hardware\.ledger\.enable



Whether to enable udev rules for Ledger devices\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/ledger\.nix](nixos/modules/hardware/ledger.nix)



## hardware\.libftdi\.enable



Whether to enable udev rules for devices supported by libftdi\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/libftdi\.nix](nixos/modules/hardware/libftdi.nix)



## hardware\.libftdi\.package



The libftdi1 package to use\.



*Type:*
package



*Default:*

```nix
pkgs.libftdi1
```

*Declared by:*
 - [nixos/modules/hardware/libftdi\.nix](nixos/modules/hardware/libftdi.nix)



## hardware\.libjaylink\.enable



Whether to enable udev rules for devices supported by libjaylink\.
Add users to the ` jlink ` group in order to grant
them access
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/libjaylink\.nix](nixos/modules/hardware/libjaylink.nix)



## hardware\.libjaylink\.package



The libjaylink package to use\.



*Type:*
package



*Default:*

```nix
pkgs.libjaylink
```

*Declared by:*
 - [nixos/modules/hardware/libjaylink\.nix](nixos/modules/hardware/libjaylink.nix)



## hardware\.logitech\.lcd\.enable



Whether to enable support for Logitech LCD Devices\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/logitech\.nix](nixos/modules/hardware/logitech.nix)



## hardware\.logitech\.lcd\.devices



List of USB device ids supported by g15daemon\.

You most likely do not need to change this\.



*Type:*
list of string



*Default:*

```nix
[
  "0a07"
  "c222"
  "c225"
  "c227"
  "c251"
]
```

*Declared by:*
 - [nixos/modules/hardware/logitech\.nix](nixos/modules/hardware/logitech.nix)



## hardware\.logitech\.lcd\.startWhenNeeded



Only run the service when an actual supported device is plugged\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/logitech\.nix](nixos/modules/hardware/logitech.nix)



## hardware\.logitech\.wireless\.enable



Whether to enable support for Logitech Wireless Devices\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/logitech\.nix](nixos/modules/hardware/logitech.nix)



## hardware\.logitech\.wireless\.enableGraphical



Enable graphical support applications\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/logitech\.nix](nixos/modules/hardware/logitech.nix)



## hardware\.mcelog\.enable



Enable the Machine Check Exception logger\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/mcelog\.nix](nixos/modules/hardware/mcelog.nix)



## hardware\.mwProCapture\.enable



Whether to enable the Magewell Pro Capture family kernel module\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/capture/mwprocapture\.nix](nixos/modules/hardware/video/capture/mwprocapture.nix)



## hardware\.new-lg4ff\.enable



Enables improved Linux module drivers for Logitech driving wheels\.
This will replace the existing in-kernel hid-logitech modules\.
Works most notably on the Logitech G25, G27, G29 and Driving Force (GT)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/new-lg4ff\.nix](nixos/modules/hardware/new-lg4ff.nix)



## hardware\.nfc-nci\.enable



Whether to enable PN5xx kernel module with udev rules, libnfc-nci userland, and optional ifdnfc-nci PC/SC driver\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/nfc-nci\.nix](nixos/modules/hardware/nfc-nci.nix)



## hardware\.nfc-nci\.enableIFD



Register ifdnfc-nci as a serial reader with pcscd\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/nfc-nci\.nix](nixos/modules/hardware/nfc-nci.nix)



## hardware\.nfc-nci\.settings



Configuration to be written to the libncf-nci configuration files\.
To understand the configuration format, refer to [https://github\.com/NXPNFCLinux/linux_libnfc-nci/tree/master/conf](https://github\.com/NXPNFCLinux/linux_libnfc-nci/tree/master/conf)\.



*Type:*
attribute set



*Default:*

```nix
{
  init = {
    NXPLOG_EXTNS_LOGLEVEL = "0x01";
    NXPLOG_FWDNLD_LOGLEVEL = "0x00";
    NXPLOG_GLOBAL_LOGLEVEL = "0x01";
    NXPLOG_NCIHAL_LOGLEVEL = "0x01";
    NXPLOG_NCIR_LOGLEVEL = "0x01";
    NXPLOG_NCIX_LOGLEVEL = "0x01";
    NXPLOG_TML_LOGLEVEL = "0x01";
    NXP_ACT_PROP_EXTN = "{2F, 02, 00}";
    NXP_CORE_STANDBY = "{2F, 00, 01, 01}";
    NXP_I2C_FRAGMENTATION_ENABLED = "0x01";
    NXP_NFC_DEV_NODE = "\"/dev/pn544\"";
    NXP_NFC_PROFILE_EXTN = ''
      {20, 02, 05, 01,
        A0, 44, 01, 00
      }
    '';
  };
  nci = {
    APPL_TRACE_LEVEL = "0x01";
    HOST_LISTEN_TECH_MASK = "0x07";
    P2P_LISTEN_TECH_MASK = "0xC5";
    POLLING_TECH_MASK = "0xEF";
    PROTOCOL_TRACE_LEVEL = "0x01";
  };
  pn54x = {
    MIFARE_READER_ENABLE = "0x01";
    NXP_CORE_CONF = ''
      {20, 02, 2B, 0D,
        28, 01, 00,
        21, 01, 00,
        30, 01, 08,
        31, 01, 03,
        33, 04, 04, 03, 02, 01,
        54, 01, 06,
        50, 01, 02,
        5B, 01, 00,
        60, 01, 0E,
        80, 01, 01,
        81, 01, 01,
        82, 01, 0E,
        18, 01, 01
      }
    '';
    NXP_CORE_CONF_EXTN = ''
      {20, 02, 30, 04,
        A0, 5E, 01, 01,
        A0, 40, 01, 00,
        A0, 43, 01, 00,
        A0, 0F, 20,
        00, 03, 1D, 01, 03, 00, 02, 00,
        01, 00, 01, 00, 00, 00, 00, 00,
        00, 00, 00, 00, 00, 00, 00, 00,
        00, 00, 00, 00, 00, 00, 00, 00
      }
    '';
    NXP_EXT_TVDD_CFG = "0x01";
    NXP_EXT_TVDD_CFG_1 = ''
      {20, 02, 07, 01,
        A0, 0E, 03, 16, 09, 00
      }
    '';
    NXP_NFC_MAX_EE_SUPPORTED = "0x00";
    NXP_NFC_PROPRIETARY_CFG = "{05:FF:FF:06:81:80:70:FF:FF}";
    NXP_SYS_CLK_FREQ_SEL = "0x00";
    NXP_SYS_CLK_SRC_SEL = "0x01";
    NXP_SYS_CLOCK_TO_CFG = "0x01";
  };
}
```

*Declared by:*
 - [nixos/modules/hardware/nfc-nci\.nix](nixos/modules/hardware/nfc-nci.nix)



## hardware\.nitrokey\.enable



Enables udev rules for Nitrokey devices\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/nitrokey\.nix](nixos/modules/hardware/nitrokey.nix)



## hardware\.nvidia\.enabled



True if NVIDIA support is enabled



*Type:*
boolean *(read only)*



*Default:*
` true ` if NVIDIA support is enabled

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.package



The NVIDIA driver package to use\.

Prefer using ` hardware.nvidia.branch ` when possible\.

If you set this option, it is recommended to pick a package from
` config.boot.kernelPackages.nvidiaPackages ` so the driver build matches
your configured kernel\.

For custom versions, you can use ` nvidiaPackages.mkDriver `; see
` pkgs/os-specific/linux/nvidia-x11/default.nix ` for examples\.



*Type:*
package



*Default:*

```nix
config.boot.kernelPackages.nvidiaPackages.${config.hardware.nvidia.branch}
```



*Example:*

```nix
config.boot.kernelPackages.nvidiaPackages.legacy_470
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.branch



The branch of the NVIDIA driver to use\.

Note: if ` hardware.nvidia.package ` is set, it overrides this option\.

Commonly interesting branches for end users:

 - production, new_feature, beta:
   NVIDIA’s official production / new feature / beta release branches\.

 - stable:
   The default; the highest stable version\.

 - latest:
   Whichever is newer of ` production ` and ` new_feature `\.

 - bleeding_edge:
   Whichever is newer of ` latest ` and ` beta `\.

 - legacy_580:
   The long-lived 580 series (LTSB), for GPUs that newer driver branches
   no longer support (often Maxwell through Volta; roughly GeForce GTX 9xx
   through 10xx, plus rare Volta cards like TITAN V)\.

 - vulkan_beta:
   The Vulkan developer beta driver, for users interested in testing new
   Vulkan features\.



*Type:*
one of the available driver branches in \`pkgs/os-specific/linux/nvidia-x11/default\.nix\`



*Default:*

```nix
if config.hardware.nvidia.datacenter.enable then "dc" else "stable"

```



*Example:*

```nix
"bleeding_edge"
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.datacenter\.enable



Whether to enable Data Center drivers for NVIDIA cards on a NVLink topology
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.datacenter\.settings



Additional configuration options for fabricmanager\.



*Type:*
attribute set of (atom (null, bool, int, float or string))



*Default:*

```nix
{
  LOG_LEVEL=4;
  LOG_FILE_NAME="/var/log/fabricmanager.log";
  LOG_APPEND_TO_LOG=1;
  LOG_FILE_MAX_SIZE=1024;
  LOG_USE_SYSLOG=0;
  DAEMONIZE=1;
  BIND_INTERFACE_IP="127.0.0.1";
  STARTING_TCP_PORT=16000;
  FABRIC_MODE=0;
  FABRIC_MODE_RESTART=0;
  STATE_FILE_NAME="/var/tmp/fabricmanager.state";
  FM_CMD_BIND_INTERFACE="127.0.0.1";
  FM_CMD_PORT_NUMBER=6666;
  FM_STAY_RESIDENT_ON_FAILURES=0;
  ACCESS_LINK_FAILURE_MODE=0;
  TRUNK_LINK_FAILURE_MODE=0;
  NVSWITCH_FAILURE_MODE=0;
  ABORT_CUDA_JOBS_ON_FM_EXIT=1;
}

```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.dynamicBoost\.enable



Whether to enable dynamic Boost balances power between the CPU and the GPU for improved
performance on supported laptops using the nvidia-powerd daemon\. For more
information, see the NVIDIA docs, on Chapter 23\. Dynamic Boost on Linux
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.forceFullCompositionPipeline



Whether to enable forcefully the full composition pipeline\.
This sometimes fixes screen tearing issues\.
This has been reported to reduce the performance of some OpenGL applications and may produce issues in WebGL\.
It also drastically increases the time the driver needs to clock down after load
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.gsp\.enable



Whether to enable the GPU System Processor (GSP) on the video card
\.



*Type:*
boolean



*Default:*

```nix
config.hardware.nvidia.open == true || lib.versionAtLeast config.hardware.nvidia.package.version "555"

```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.modesetting\.enable



Whether to enable kernel modesetting when using the NVIDIA proprietary driver\.

Enabling this fixes screen tearing when using Optimus via PRIME (see
` hardware.nvidia.prime.sync.enable `\. This is not enabled
by default because it is not officially supported by NVIDIA and would not
work with SLI\.

Enabling this and using version 545 or newer of the proprietary NVIDIA
driver causes it to provide its own framebuffer device, which can cause
Wayland compositors to work when they otherwise wouldn’t\.
\.



*Type:*
boolean



*Default:*

```nix
lib.versionAtLeast cfg.package.version "535"
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.moduleParams



Additional parameters to pass to the NVIDIA kernel module\.



*Type:*
attribute set of attribute set of raw value



*Default:*

```nix
{ }
```



*Example:*

```nix
''
  {
    nvidia = {
      NVreg_UsePageAttributeTable = 1;
      NVreg_RegistryDwords = "EnableBrightnessControl=1"
    };
  }
''
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.nvidiaPersistenced



Whether to enable nvidia-persistenced a update for NVIDIA GPU headless mode, i\.e\.
It ensures all GPUs stay awake even during headless mode
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.nvidiaSettings



Whether to enable nvidia-settings, NVIDIA’s GUI configuration tool
\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.open



Whether to enable the open source NVIDIA kernel module\.



*Type:*
null or boolean



*Default:*

```nix
if lib.versionOlder config.hardware.nvidia.package.version "560" then false else null

```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.powerManagement\.enable



Whether to enable experimental power management through systemd\. For more information, see
the NVIDIA docs, on Chapter 21\. Configuring Power Management Support
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.powerManagement\.finegrained



Whether to enable experimental power management of PRIME offload\. For more information, see
the NVIDIA docs, on Chapter 22\. PCI-Express Runtime D3 (RTD3) Power Management
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.powerManagement\.kernelSuspendNotifier



Whether to enable NVIDIA driver support for kernel suspend notifiers, which allows the driver
to be notified of suspend and resume events by the kernel, rather than
relying on systemd services\.
Requires NVIDIA driver version 595 or newer, and the open source kernel modules\.
\.



*Type:*
boolean



*Default:*

```nix
config.hardware.nvidia.open == true && lib.versionAtLeast config.hardware.nvidia.package.version "595"

```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.allowExternalGpu



Whether to enable configuring X to allow external NVIDIA GPUs when using Prime \[Reverse] sync optimus
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.amdgpuBusId



Bus ID of the AMD APU\. You can find it using lspci; for example if lspci
shows the AMD APU at “0001:02:03\.4”, set this option to “PCI:2@1:3:4”\.

lspci might omit the PCI domain (0001 in above example) if it is zero\.
In which case, use “@0” instead\.

Please be aware that this option takes decimal address while lspci reports
hexadecimal address\. So for device at domain “10000”, use “@65536”\.



*Type:*
string matching the pattern (\[\[:print:]]+:\[0-9]{1,3}(@\[0-9]{1,10})?:\[0-9]{1,2}:\[0-9])?



*Default:*

```nix
""
```



*Example:*

```nix
"PCI:4@0:0:0"
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.intelBusId



Bus ID of the Intel GPU\. You can find it using lspci; for example if lspci
shows the Intel GPU at “0001:02:03\.4”, set this option to “PCI:2@1:3:4”\.

lspci might omit the PCI domain (0001 in above example) if it is zero\.
In which case, use “@0” instead\.

Please be aware that this option takes decimal address while lspci reports
hexadecimal address\. So for device at domain “10000”, use “@65536”\.



*Type:*
string matching the pattern (\[\[:print:]]+:\[0-9]{1,3}(@\[0-9]{1,10})?:\[0-9]{1,2}:\[0-9])?



*Default:*

```nix
""
```



*Example:*

```nix
"PCI:0@0:2:0"
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.nvidiaBusId



Bus ID of the NVIDIA GPU\. You can find it using lspci; for example if lspci
shows the NVIDIA GPU at “0001:02:03\.4”, set this option to “PCI:2@1:3:4”\.

lspci might omit the PCI domain (0001 in above example) if it is zero\.
In which case, use “@0” instead\.

Please be aware that this option takes decimal address while lspci reports
hexadecimal address\. So for device at domain “10000”, use “@65536”\.



*Type:*
string matching the pattern (\[\[:print:]]+:\[0-9]{1,3}(@\[0-9]{1,10})?:\[0-9]{1,2}:\[0-9])?



*Default:*

```nix
""
```



*Example:*

```nix
"PCI:1@0:0:0"
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.offload\.enable



Whether to enable render offload support using the NVIDIA proprietary driver via PRIME\.

If this is enabled, then the bus IDs of the NVIDIA and Intel/AMD GPUs have to
be specified (` hardware.nvidia.prime.nvidiaBusId ` and
` hardware.nvidia.prime.intelBusId ` or
` hardware.nvidia.prime.amdgpuBusId `)
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.offload\.enableOffloadCmd



Whether to enable adding a ` nvidia-offload ` convenience script to ` environment.systemPackages `
for offloading programs to an nvidia device\. To work, you must also enable
` hardware.nvidia.prime.offload.enable ` or ` hardware.nvidia.prime.reverseSync.enable `\.

Example usage: ` nvidia-offload sauerbraten_client `

This script can be renamed with ` hardware.nvidia.prime.offload.enableOffloadCmd `\.
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.offload\.offloadCmdMainProgram



Specifies the CLI name of the ` hardware.nvidia.prime.offload.enableOffloadCmd `
convenience script for offloading programs to an nvidia device\.



*Type:*
string



*Default:*

```nix
"nvidia-offload"
```



*Example:*

```nix
"prime-run"
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.reverseSync\.enable



Whether to enable NVIDIA Optimus support using the NVIDIA proprietary driver via reverse
PRIME\. If enabled, the Intel/AMD GPU will be used for all rendering, while
enabling output to displays attached only to the NVIDIA GPU without a
multiplexer\.

Warning: This feature is relatively new, depending on your system this might
work poorly\. AMD support, especially so\.
See: [https://forums\.developer\.nvidia\.com/t/the-all-new-outputsink-feature-aka-reverse-prime/129828](https://forums\.developer\.nvidia\.com/t/the-all-new-outputsink-feature-aka-reverse-prime/129828)

Note that this option only has any effect if the “nvidia” driver is specified
in ` services.xserver.videoDrivers `, and it should preferably
be the only driver there\.

If this is enabled, then the bus IDs of the NVIDIA and Intel/AMD GPUs have to
be specified (` hardware.nvidia.prime.nvidiaBusId ` and
` hardware.nvidia.prime.intelBusId ` or
` hardware.nvidia.prime.amdgpuBusId `)\.

If you enable this, you may want to also enable kernel modesetting for the
NVIDIA driver (` hardware.nvidia.modesetting.enable `) in order
to prevent tearing\.

Note that this configuration will only be successful when a display manager
for which the ` services.xserver.displayManager.setupCommands `
option is supported is used
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.reverseSync\.setupCommands\.enable



Whether to enable configure the display manager to be able to use the outputs
attached to the NVIDIA GPU\.
Disable in order to configure the NVIDIA GPU outputs manually using xrandr\.
Note that this configuration will only be successful when a display manager
for which the ` services.xserver.displayManager.setupCommands `
option is supported is used
\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.prime\.sync\.enable



Whether to enable NVIDIA Optimus support using the NVIDIA proprietary driver via PRIME\.
If enabled, the NVIDIA GPU will be always on and used for all rendering,
while enabling output to displays attached only to the integrated Intel/AMD
GPU without a multiplexer\.

Note that this option only has any effect if the “nvidia” driver is specified
in ` services.xserver.videoDrivers `, and it should preferably
be the only driver there\.

If this is enabled, then the bus IDs of the NVIDIA and Intel/AMD GPUs have to
be specified (` hardware.nvidia.prime.nvidiaBusId ` and
` hardware.nvidia.prime.intelBusId ` or
` hardware.nvidia.prime.amdgpuBusId `)\.

If you enable this, you may want to also enable kernel modesetting for the
NVIDIA driver (` hardware.nvidia.modesetting.enable `) in order
to prevent tearing\.

Note that this configuration will only be successful when a display manager
for which the ` services.xserver.displayManager.setupCommands `
option is supported is used
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia\.videoAcceleration



Whether to enable video acceleration (VA-API)\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/video/nvidia\.nix](nixos/modules/hardware/video/nvidia.nix)



## hardware\.nvidia-container-toolkit\.enable



Enable dynamic CDI configuration for Nvidia devices by running
nvidia-container-toolkit on boot\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.enable-hooks



List of hooks to enable when generating the CDI specification\.
Each hook name will be passed as ` --enable-hook <hook-name> ` to nvidia-ctk\.
Set to an empty list to enable no hooks\.



*Type:*
list of non-empty string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.package



The nvidia-container-toolkit package to use\.



*Type:*
package



*Default:*

```nix
pkgs.nvidia-container-toolkit
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.csv-files



The path to the list of CSV files to use when generating the CDI specification in CSV mode\.



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.device-name-strategy



Specify the strategy for generating device names,
passed to ` nvidia-ctk cdi generate `\. This will affect how
you reference the device using ` nvidia.com/gpu= ` in
the container runtime\.



*Type:*
one of “index”, “uuid”, “type-index”



*Default:*

```nix
"index"
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.disable-hooks



List of hooks to disable when generating the CDI specification\.
Each hook name will be passed as ` --disable-hook <hook-name> ` to nvidia-ctk\.
Set to an empty list to disable no hooks\.



*Type:*
list of non-empty string



*Default:*

```nix
[
  "create-symlinks"
]
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.discovery-mode



The mode to use when discovering the available entities\.



*Type:*
one of “auto”, “csv”, “nvml”, “wsl”



*Default:*

```nix
"auto"
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.extraArgs



Extra arguments to be passed to nvidia-ctk\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.mount-nvidia-docker-1-directories



Mount nvidia-docker-1 directories on containers: /usr/local/nvidia/lib and
/usr/local/nvidia/lib64\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.mount-nvidia-executables



Mount executables nvidia-smi, nvidia-cuda-mps-control, nvidia-cuda-mps-server,
nvidia-debugdump, nvidia-powerd and nvidia-ctk on containers\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.mounts



Mounts to be added to every container under the Nvidia CDI profile\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.mounts\.\*\.containerPath



Container path\.



*Type:*
string

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.mounts\.\*\.hostPath



Host path\.



*Type:*
string

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.mounts\.\*\.mountOptions



Mount options\.



*Type:*
list of string



*Default:*

```nix
[
  "ro"
  "nosuid"
  "nodev"
  "bind"
]
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidia-container-toolkit\.suppressNvidiaDriverAssertion



Suppress the assertion for installing Nvidia driver\.
Useful in WSL where drivers are mounted from Windows, not provided by NixOS\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-container-toolkit](nixos/modules/services/hardware/nvidia-container-toolkit)



## hardware\.nvidiaOptimus\.disable



Completely disable the NVIDIA graphics card and use the
integrated graphics processor instead\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/services/hardware/nvidia-optimus\.nix](nixos/modules/services/hardware/nvidia-optimus.nix)



## hardware\.onlykey\.enable



Enable OnlyKey device (https://crp\.to/p/) support\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/onlykey/default\.nix](nixos/modules/hardware/onlykey/default.nix)



## hardware\.openrazer\.enable



Whether to enable OpenRazer drivers and userspace daemon
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.packages\.daemon



The openrazer-daemon package to use\.



*Type:*
package



*Default:*

```nix
pkgs.python3Packages.openrazer-daemon
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.packages\.kernel



The openrazer kernel package to use\.



*Type:*
package



*Default:*

```nix
config.boot.kernelPackages.openrazer
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.batteryNotifier



Settings for device battery notifications\.



*Type:*
submodule



*Default:*

```nix
{ }
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.batteryNotifier\.enable



Mouse battery notifier\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.batteryNotifier\.frequency



How often battery notifications should be shown (in seconds)\.
A value of 0 disables notifications\.



*Type:*
signed integer



*Default:*

```nix
600
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.batteryNotifier\.percentage



At what battery percentage the device should reach before
sending notifications\.



*Type:*
signed integer



*Default:*

```nix
33
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.devicesOffOnScreensaver



Turn off the devices when the systems screensaver kicks in\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.keyStatistics



Collects number of keypresses per hour per key used to
generate a heatmap\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.syncEffectsEnabled



Set the sync effects flag to true so any assignment of
effects will work across devices\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.users



Usernames to be added to the “openrazer” group, so that they
can start and interact with the OpenRazer userspace daemon\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.openrazer\.verboseLogging



Whether to enable verbose logging\. Logs debug messages\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/openrazer\.nix](nixos/modules/hardware/openrazer.nix)



## hardware\.opentabletdriver\.enable



Enable OpenTabletDriver udev rules, user service and blacklist kernel
modules known to conflict with OpenTabletDriver\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/opentabletdriver\.nix](nixos/modules/hardware/opentabletdriver.nix)



## hardware\.opentabletdriver\.package



The opentabletdriver package to use\.



*Type:*
package



*Default:*

```nix
pkgs.opentabletdriver
```

*Declared by:*
 - [nixos/modules/hardware/opentabletdriver\.nix](nixos/modules/hardware/opentabletdriver.nix)



## hardware\.opentabletdriver\.blacklistedKernelModules



Blacklist of kernel modules known to conflict with OpenTabletDriver\.



*Type:*
list of string



*Default:*

```nix
[
  "hid-uclogic"
  "wacom"
]
```

*Declared by:*
 - [nixos/modules/hardware/opentabletdriver\.nix](nixos/modules/hardware/opentabletdriver.nix)



## hardware\.opentabletdriver\.daemon\.enable



Whether to start OpenTabletDriver daemon as a systemd user service\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/opentabletdriver\.nix](nixos/modules/hardware/opentabletdriver.nix)



## hardware\.parallels\.enable



This enables Parallels Tools for Linux guests\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/virtualisation/parallels-guest\.nix](nixos/modules/virtualisation/parallels-guest.nix)



## hardware\.parallels\.package



The prl-tools package to use\.



*Type:*
package



*Default:*

```nix
pkgs.prl-tools
```

*Declared by:*
 - [nixos/modules/virtualisation/parallels-guest\.nix](nixos/modules/virtualisation/parallels-guest.nix)



## hardware\.pcmcia\.enable



Enable this option to support PCMCIA card\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/pcmcia\.nix](nixos/modules/hardware/pcmcia.nix)



## hardware\.pcmcia\.config



Path to the configuration file which maps the memory, IRQs
and ports used by the PCMCIA hardware\.



*Type:*
null or absolute path



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/pcmcia\.nix](nixos/modules/hardware/pcmcia.nix)



## hardware\.pcmcia\.firmware



List of firmware used to handle specific PCMCIA card\.



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/hardware/pcmcia\.nix](nixos/modules/hardware/pcmcia.nix)



## hardware\.printers\.ensureDefaultPrinter



Ensures the named printer is the default CUPS printer / printer queue\.



*Type:*
null or printable string without spaces, \# and /



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/printers\.nix](nixos/modules/hardware/printers.nix)



## hardware\.printers\.ensurePrinters



Will regularly ensure that the given CUPS printers are configured as declared here\.
If a printer’s options are manually changed afterwards, they will be overwritten eventually\.
This option will never delete any printer, even if removed from this list\.
You can check existing printers with ` lpstat -s `
and remove printers with ` lpadmin -x <printer-name> `\.
Printers not listed here can still be manually configured\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/hardware/printers\.nix](nixos/modules/hardware/printers.nix)



## hardware\.printers\.ensurePrinters\.\*\.description



Optional human-readable description\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"Brother HL-5140"
```

*Declared by:*
 - [nixos/modules/hardware/printers\.nix](nixos/modules/hardware/printers.nix)



## hardware\.printers\.ensurePrinters\.\*\.deviceUri



How to reach the printer\.
` lpinfo -v ` shows a list of supported device URIs and schemes\.



*Type:*
string



*Example:*

```nix
"ipp://printserver.local/printers/BrotherHL_Workroom"
"usb://HP/DESKJET%20940C?serial=CN16E6C364BH"

```

*Declared by:*
 - [nixos/modules/hardware/printers\.nix](nixos/modules/hardware/printers.nix)



## hardware\.printers\.ensurePrinters\.\*\.location



Optional human-readable location\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"Workroom"
```

*Declared by:*
 - [nixos/modules/hardware/printers\.nix](nixos/modules/hardware/printers.nix)



## hardware\.printers\.ensurePrinters\.\*\.model



Location of the ppd driver file for the printer\.
` lpinfo -m ` shows a list of supported models\.



*Type:*
string



*Example:*

```nix
"gutenprint.${lib.versions.majorMinor (lib.getVersion pkgs.gutenprint)}://brother-hl-5140/expert"

```

*Declared by:*
 - [nixos/modules/hardware/printers\.nix](nixos/modules/hardware/printers.nix)



## hardware\.printers\.ensurePrinters\.\*\.name



Name of the printer / printer queue\.
May contain any printable characters except “/”, “\#”, and space\.



*Type:*
printable string without spaces, \# and /



*Example:*

```nix
"BrotherHL_Workroom"
```

*Declared by:*
 - [nixos/modules/hardware/printers\.nix](nixos/modules/hardware/printers.nix)



## hardware\.printers\.ensurePrinters\.\*\.ppdOptions



Sets PPD options for the printer\.
` lpoptions [-p printername] -l ` shows supported PPD options for the given printer\.



*Type:*
attribute set of string



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  Duplex = "DuplexNoTumble";
  PageSize = "A4";
}
```

*Declared by:*
 - [nixos/modules/hardware/printers\.nix](nixos/modules/hardware/printers.nix)



## hardware\.raid\.HPSmartArray\.enable



Whether to enable HP Smart Array kernel modules and CLI utility\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/raid/hpsa\.nix](nixos/modules/hardware/raid/hpsa.nix)



## hardware\.rasdaemon\.enable



Whether to enable RAS logging daemon\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/rasdaemon\.nix](nixos/modules/services/hardware/rasdaemon.nix)



## hardware\.rasdaemon\.package



The rasdaemon package to use\.



*Type:*
package



*Default:*

```nix
pkgs.rasdaemon
```

*Declared by:*
 - [nixos/modules/services/hardware/rasdaemon\.nix](nixos/modules/services/hardware/rasdaemon.nix)



## hardware\.rasdaemon\.config



rasdaemon configuration, currently only used for CE PFA
for details, read rasdaemon\.outPath/etc/sysconfig/rasdaemon’s comments



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```



*Example:*

```nix
''
  # defaults from included config
  PAGE_CE_REFRESH_CYCLE="24h"
  PAGE_CE_THRESHOLD="50"
  PAGE_CE_ACTION="soft"
''
```

*Declared by:*
 - [nixos/modules/services/hardware/rasdaemon\.nix](nixos/modules/services/hardware/rasdaemon.nix)



## hardware\.rasdaemon\.extraModules



extra kernel modules to load



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "i7core_edac"
]
```

*Declared by:*
 - [nixos/modules/services/hardware/rasdaemon\.nix](nixos/modules/services/hardware/rasdaemon.nix)



## hardware\.rasdaemon\.labels



Additional memory module label descriptions to be placed in /etc/ras/dimm_labels\.d/labels



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```



*Example:*

````nix
''
  # vendor and model may be shown by 'ras-mc-ctl --mainboard'
  vendor: ASRock
    product: To Be Filled By O.E.M.
    model: B450M Pro4
      # these labels are names for the motherboard slots
      # the numbers may be shown by `ras-mc-ctl --error-count`
      # they are mc:csrow:channel
      DDR4_A1: 0.2.0;  DDR4_B1: 0.2.1;
      DDR4_A2: 0.3.0;  DDR4_B2: 0.3.1;
''
````

*Declared by:*
 - [nixos/modules/services/hardware/rasdaemon\.nix](nixos/modules/services/hardware/rasdaemon.nix)



## hardware\.rasdaemon\.mainboard



Custom mainboard description, see ` ras-mc-ctl(8) ` for more details\.



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```



*Example:*

```nix
''
  vendor = ASRock
  model = B450M Pro4
  
  # it should default to such values from
  # /sys/class/dmi/id/board_[vendor|name]
  # alternatively one can supply a script
  # that returns the same format as above
  
  script = <path to script>
''
```

*Declared by:*
 - [nixos/modules/services/hardware/rasdaemon\.nix](nixos/modules/services/hardware/rasdaemon.nix)



## hardware\.rasdaemon\.record



record events via sqlite3, required for ras-mc-ctl



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/rasdaemon\.nix](nixos/modules/services/hardware/rasdaemon.nix)



## hardware\.rasdaemon\.testing



Whether to enable error injection infrastructure\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/rasdaemon\.nix](nixos/modules/services/hardware/rasdaemon.nix)



## hardware\.rtl-sdr\.enable



Enables rtl-sdr udev rules, ensures ‘plugdev’ group exists, and blacklists DVB kernel modules\.
This is a prerequisite to using devices supported by rtl-sdr without being root, since rtl-sdr USB descriptors will be owned by plugdev through udev\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/rtl-sdr\.nix](nixos/modules/hardware/rtl-sdr.nix)



## hardware\.rtl-sdr\.package



The rtl-sdr package to use\.



*Type:*
package



*Default:*

```nix
pkgs.rtl-sdr
```

*Declared by:*
 - [nixos/modules/hardware/rtl-sdr\.nix](nixos/modules/hardware/rtl-sdr.nix)



## hardware\.saleae-logic\.enable



Whether to enable udev rules for Saleae Logic devices\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/saleae-logic\.nix](nixos/modules/hardware/saleae-logic.nix)



## hardware\.saleae-logic\.package



Saleae Logic package to use\.



*Type:*
package



*Default:*

```nix
pkgs.saleae-logic-2
```

*Declared by:*
 - [nixos/modules/hardware/saleae-logic\.nix](nixos/modules/hardware/saleae-logic.nix)



## hardware\.sane\.enable



Enable support for SANE scanners\.

**Note:** Users in the “scanner” group will gain access to the scanner, or the “lp” group if it’s also a printer\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sane\.backends-package



The sane-backends package to use\.



*Type:*
package



*Default:*

```nix
pkgs.sane-backends
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sane\.brscan4\.enable



When enabled, will automatically register the “brscan4” sane
backend and bring configuration files to their expected location\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan4\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan4.nix)



## hardware\.sane\.brscan4\.netDevices



The list of network devices that will be registered against the brscan4
sane backend\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  office1 = {
    ip = "192.168.1.2";
    model = "MFC-7860DW";
  };
  office2 = {
    model = "MFC-7860DW";
    nodename = "BRW0080927AFBCE";
  };
}
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan4\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan4.nix)



## hardware\.sane\.brscan4\.netDevices\.\<name>\.ip



The ip address of the device\. If undefined, you will have to
provide a nodename\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"192.168.1.2"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan4\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan4.nix)



## hardware\.sane\.brscan4\.netDevices\.\<name>\.model



The model of the network device\.



*Type:*
string



*Example:*

```nix
"MFC-7860DW"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan4\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan4.nix)



## hardware\.sane\.brscan4\.netDevices\.\<name>\.name



The friendly name you give to the network device\. If undefined,
the name of attribute will be used\.



*Type:*
string



*Example:*

```nix
"office1"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan4\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan4.nix)



## hardware\.sane\.brscan4\.netDevices\.\<name>\.nodename



The node name of the device\. If undefined, you will have to
provide an ip\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"BRW0080927AFBCE"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan4\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan4.nix)



## hardware\.sane\.brscan5\.enable



Whether to enable the Brother brscan5 sane backend\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan5\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan5.nix)



## hardware\.sane\.brscan5\.netDevices



The list of network devices that will be registered against the brscan5
sane backend\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  office1 = {
    ip = "192.168.1.2";
    model = "MFC-7860DW";
  };
  office2 = {
    model = "MFC-7860DW";
    nodename = "BRW0080927AFBCE";
  };
}
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan5\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan5.nix)



## hardware\.sane\.brscan5\.netDevices\.\<name>\.ip



The ip address of the device\. If undefined, you will have to
provide a nodename\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"192.168.1.2"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan5\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan5.nix)



## hardware\.sane\.brscan5\.netDevices\.\<name>\.model



The model of the network device\.



*Type:*
string



*Example:*

```nix
"ADS-1200"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan5\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan5.nix)



## hardware\.sane\.brscan5\.netDevices\.\<name>\.name



The friendly name you give to the network device\. If undefined,
the name of attribute will be used\.



*Type:*
string



*Example:*

```nix
"office1"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan5\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan5.nix)



## hardware\.sane\.brscan5\.netDevices\.\<name>\.nodename



The node name of the device\. If undefined, you will have to
provide an ip\.



*Type:*
null or string



*Default:*

```nix
null
```



*Example:*

```nix
"BRW0080927AFBCE"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/brscan5\.nix](nixos/modules/services/hardware/sane_extra_backends/brscan5.nix)



## hardware\.sane\.disabledDefaultBackends



Names of backends which are enabled by default but should be disabled\.
See ` $SANE_CONFIG_DIR/dll.conf ` for the list of possible names\.



*Type:*
list of string



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  "v4l"
]
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sane\.drivers\.scanSnap\.enable



Whether to enable drivers for the Fujitsu ScanSnap scanners\.

The driver files are unfree and extracted from the Windows driver image\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sane\.drivers\.scanSnap\.package



The epjitsu package to use\. Useful if you want to extract the driver files yourself\.

The process is described in the ` /etc/sane.d/epjitsu.conf ` file in
the ` sane-backends ` package\.



*Type:*
package



*Default:*

```nix
pkgs.sane-drivers.epjitsu
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sane\.dsseries\.enable



When enabled, will automatically register the “dsseries” SANE backend\.

This supports the Brother DSmobile scanner series, including the
DS-620, DS-720D, DS-820W, and DS-920DW scanners\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/sane_extra_backends/dsseries\.nix](nixos/modules/services/hardware/sane_extra_backends/dsseries.nix)



## hardware\.sane\.extraBackends



Packages providing extra SANE backends to enable\.

**Note:** The example contains the package for HP scanners, and the package for
Apple AirScan and Microsoft WSD support (supports many
vendors/devices)\.



*Type:*
list of absolute path



*Default:*

```nix
[ ]
```



*Example:*

```nix
[ pkgs.hplipWithPlugin pkgs.sane-airscan ]
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sane\.netConf



Network hosts that should be probed for remote scanners\.



*Type:*
strings concatenated with “\\n”



*Default:*

```nix
""
```



*Example:*

```nix
"192.168.0.16"
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sane\.openFirewall



Open ports needed for discovery of scanners on the local network, e\.g\.
needed for Canon scanners (BJNP protocol)\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sane\.snapshot



Use a development snapshot of SANE scanner drivers\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/services/hardware/sane\.nix](nixos/modules/services/hardware/sane.nix)



## hardware\.sata\.timeout\.enable



Whether to enable SATA drive timeouts\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/sata\.nix](nixos/modules/hardware/sata.nix)



## hardware\.sata\.timeout\.deciSeconds



Set SCT Error Recovery Control timeout in deciseconds for use in RAID configurations\.

Values are as follows:
0 = disable SCT ERT
70 = default in consumer drives (7 seconds)

Maximum is disk dependant but probably 60 seconds\.



*Type:*
signed integer



*Example:*

```nix
70
```

*Declared by:*
 - [nixos/modules/hardware/sata\.nix](nixos/modules/hardware/sata.nix)



## hardware\.sata\.timeout\.drives



List of drives for which to configure the timeout\.



*Type:*
list of (submodule)

*Declared by:*
 - [nixos/modules/hardware/sata\.nix](nixos/modules/hardware/sata.nix)



## hardware\.sata\.timeout\.drives\.\*\.idBy



The method to identify the drive\.



*Type:*
one of “path”, “wwn”



*Default:*

```nix
"path"
```

*Declared by:*
 - [nixos/modules/hardware/sata\.nix](nixos/modules/hardware/sata.nix)



## hardware\.sata\.timeout\.drives\.\*\.name



Drive name without the full path\.



*Type:*
string

*Declared by:*
 - [nixos/modules/hardware/sata\.nix](nixos/modules/hardware/sata.nix)



## hardware\.sensor\.hddtemp\.enable



Enable this option to support HDD/SSD temperature sensors\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/sensor/hddtemp\.nix](nixos/modules/hardware/sensor/hddtemp.nix)



## hardware\.sensor\.hddtemp\.dbEntries



Additional DB entries



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/hardware/sensor/hddtemp\.nix](nixos/modules/hardware/sensor/hddtemp.nix)



## hardware\.sensor\.hddtemp\.drives



List of drives to monitor\. If you pass /dev/disk/by-path/\* entries the symlinks will be resolved as hddtemp doesn’t like names with colons\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/hardware/sensor/hddtemp\.nix](nixos/modules/hardware/sensor/hddtemp.nix)



## hardware\.sensor\.hddtemp\.extraArgs



Additional arguments passed to the daemon\.



*Type:*
list of string



*Default:*

```nix
[ ]
```

*Declared by:*
 - [nixos/modules/hardware/sensor/hddtemp\.nix](nixos/modules/hardware/sensor/hddtemp.nix)



## hardware\.sensor\.hddtemp\.unit



Celsius or Fahrenheit



*Type:*
one of “C”, “F”



*Default:*

```nix
"C"
```

*Declared by:*
 - [nixos/modules/hardware/sensor/hddtemp\.nix](nixos/modules/hardware/sensor/hddtemp.nix)



## hardware\.sensor\.iio\.enable



Enable this option to support IIO sensors with iio-sensor-proxy\.

IIO sensors are used for orientation and ambient light
sensors on some mobile devices\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/sensor/iio\.nix](nixos/modules/hardware/sensor/iio.nix)



## hardware\.sensor\.iio\.package



The iio-sensor-proxy package to use\.



*Type:*
package



*Default:*

```nix
pkgs.iio-sensor-proxy
```

*Declared by:*
 - [nixos/modules/hardware/sensor/iio\.nix](nixos/modules/hardware/sensor/iio.nix)



## hardware\.sheep_net\.enable



Enables sheep_net udev rules, ensures ‘sheep_net’ group exists, and adds
sheep-net to boot\.kernelModules and boot\.extraModulePackages



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/sheep-net\.nix](nixos/modules/hardware/sheep-net.nix)



## hardware\.spacenavd\.enable



Whether to enable spacenavd to support 3DConnexion devices\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/spacenavd\.nix](nixos/modules/services/hardware/spacenavd.nix)



## hardware\.steam-hardware\.enable



Enable udev rules for Steam hardware such as the Steam Controller, other supported controllers and the HTC Vive



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/steam-hardware\.nix](nixos/modules/hardware/steam-hardware.nix)



## hardware\.system76\.enableAll



Whether to enable all recommended configuration for system76 systems\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/system-76\.nix](nixos/modules/hardware/system-76.nix)



## hardware\.system76\.firmware-daemon\.enable



Whether to enable the system76 firmware daemon



*Type:*
boolean



*Default:*

```nix
config.hardware.system76.enableAll
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/system-76\.nix](nixos/modules/hardware/system-76.nix)



## hardware\.system76\.kernel-modules\.enable



Whether to make the system76 out-of-tree kernel modules available



*Type:*
boolean



*Default:*

```nix
config.hardware.system76.enableAll
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/system-76\.nix](nixos/modules/hardware/system-76.nix)



## hardware\.system76\.power-daemon\.enable



Whether to enable the system76 power daemon



*Type:*
boolean



*Default:*

```nix
config.hardware.system76.enableAll
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/system-76\.nix](nixos/modules/hardware/system-76.nix)



## hardware\.tenstorrent\.enable



Whether to enable Tenstorrent driver \& utilities\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/tenstorrent\.nix](nixos/modules/hardware/tenstorrent.nix)



## hardware\.trackpoint\.enable



Enable sensitivity and speed configuration for trackpoints\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.device



The device name of the trackpoint\. You can check with xinput\.
Some newer devices (example x1c6) use “TPPS/2 Elan TrackPoint”\.



*Type:*
string



*Default:*

```nix
"TPPS/2 IBM TrackPoint"
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.draghys



The drag hysteresis controls how hard it is to drag with z-axis pressed\.



*Type:*
signed integer



*Default:*

```nix
255
```



*Example:*

```nix
200
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.drift_time



This parameter controls the period of time to test for a ‘hands off’ condition (i\.e\. when no force is applied) before a drift (noise) calibration occurs\.

IBM Trackpoints have a feature to compensate for drift by recalibrating themselves periodically\. By default, if for 0\.5 seconds there is no change in position, it’s used as the new zero\. This duration is too low\. Often, the calibration happens when the trackpoint is in fact being used\.



*Type:*
signed integer



*Default:*

```nix
5
```



*Example:*

```nix
100
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.emulateWheel



Enable scrolling while holding the middle mouse button\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.ext_dev



Disable or enable external pointing device\.



*Type:*
boolean



*Default:*

```nix
true
```



*Example:*

```nix
false
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.fakeButtons



Switch to “bare” PS/2 mouse support in case Trackpoint buttons are not recognized
properly\. This can happen for example on models like the L430, T450, T450s, on
which the Trackpoint buttons are actually a part of the Synaptics touchpad\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.inertia



Negative inertia factor\. High values cause the cursor to snap backward when the trackpoint is released\.



*Type:*
signed integer



*Default:*

```nix
6
```



*Example:*

```nix
10
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.jenks



Minimum curvature in degrees required to generate a double click without a release\.



*Type:*
signed integer



*Default:*

```nix
135
```



*Example:*

```nix
100
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.mindrag



Minimum amount of force needed to trigger dragging\.



*Type:*
signed integer



*Default:*

```nix
20
```



*Example:*

```nix
30
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.press_to_select



Setting this to true will enable the Press to Select functions like tapping the control stick to simulate a left click, and setting false will disable it\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.reach



Backup range for z-axis press\.



*Type:*
signed integer



*Default:*

```nix
10
```



*Example:*

```nix
20
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.sensitivity



Trackpoint sensitivity\.



*Type:*
signed integer



*Default:*

```nix
128
```



*Example:*

```nix
255
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.skipback



When the skipback bit is set, backup cursor movement during releases from drags will be suppressed\. The default value for this bit is 0\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.speed



Speed of the trackpoint cursor\.



*Type:*
signed integer



*Default:*

```nix
97
```



*Example:*

```nix
255
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.thresh



Minimum value for z-axis force required to trigger a press or release, relative to the running average\.



*Type:*
signed integer



*Default:*

```nix
8
```



*Example:*

```nix
10
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.upthresh



The offset from the running average required to generate a select (click) on z-axis on release\.



*Type:*
signed integer



*Default:*

```nix
255
```



*Example:*

```nix
250
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.trackpoint\.ztime



This attribute determines how sharp a press has to be in order to be recognized\.



*Type:*
signed integer



*Default:*

```nix
38
```



*Example:*

```nix
50
```

*Declared by:*
 - [nixos/modules/tasks/trackpoint\.nix](nixos/modules/tasks/trackpoint.nix)



## hardware\.tuxedo-drivers\.enable



Whether to enable The tuxedo-drivers driver enables access to the following on TUXEDO notebooks:

 - Driver for Fn-keys
 - SysFS control of brightness/color/mode for most TUXEDO keyboards
 - Hardware I/O driver for TUXEDO Control Center

For more inforation it is best to check at the source code description: [https://gitlab\.com/tuxedocomputers/development/packages/tuxedo-drivers](https://gitlab\.com/tuxedocomputers/development/packages/tuxedo-drivers)
\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/tuxedo-drivers\.nix](nixos/modules/hardware/tuxedo-drivers.nix)



## hardware\.tuxedo-drivers\.settings\.charging-priority



These options manage the trade-off between battery charging and CPU performance when the USB-C power supply cannot provide sufficient power for both simultaneously:

 - ` charge_battery ` prioritizes battery charging (driver default)
 - ` performance ` prioritizes maximum CPU performance



*Type:*
null or one of “charge_battery”, “performance”



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/tuxedo-drivers\.nix](nixos/modules/hardware/tuxedo-drivers.nix)



## hardware\.tuxedo-drivers\.settings\.charging-profile



The maximum charge level to help reduce battery wear:

 - ` high_capacity ` charges to 100% (driver default)
 - ` balanced ` charges to 90%
 - ` stationary ` charges to 80% (maximum lifespan)

**Note:** Regardless of the configured charging profile, the operating system will always report the battery as being charged to 100%\.



*Type:*
null or one of “high_capacity”, “balanced”, “stationary”



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/tuxedo-drivers\.nix](nixos/modules/hardware/tuxedo-drivers.nix)



## hardware\.tuxedo-drivers\.settings\.fn-lock



Enables or disables the laptop keyboard’s Function (Fn) lock at boot\.

When set to ` true `, the Fn lock is enabled, allowing the function keys (F1–F12) to control brightness, volume etc\.



*Type:*
null or boolean



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/tuxedo-drivers\.nix](nixos/modules/hardware/tuxedo-drivers.nix)



## hardware\.tuxedo-rs\.enable



Whether to enable Rust utilities for interacting with hardware from TUXEDO Computers\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/tuxedo-rs\.nix](nixos/modules/services/hardware/tuxedo-rs.nix)



## hardware\.tuxedo-rs\.tailor-gui\.enable



Whether to enable tailor-gui, an alternative to TUXEDO Control Center, written in Rust\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/services/hardware/tuxedo-rs\.nix](nixos/modules/services/hardware/tuxedo-rs.nix)



## hardware\.ubertooth\.enable



Whether to enable Ubertooth software and its udev rules\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/ubertooth\.nix](nixos/modules/hardware/ubertooth.nix)



## hardware\.ubertooth\.group



Group for Ubertooth’s udev rules\.



*Type:*
string



*Default:*

```nix
"ubertooth"
```



*Example:*

```nix
"wheel"
```

*Declared by:*
 - [nixos/modules/hardware/ubertooth\.nix](nixos/modules/hardware/ubertooth.nix)



## hardware\.uinput\.enable



Whether to enable uinput support\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/uinput\.nix](nixos/modules/hardware/uinput.nix)



## hardware\.uni-sync\.enable



Whether to enable udev rules and software for Lian Li Uni Controllers\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/uni-sync\.nix](nixos/modules/hardware/uni-sync.nix)



## hardware\.uni-sync\.package



The uni-sync package to use\.



*Type:*
package



*Default:*

```nix
pkgs.uni-sync
```

*Declared by:*
 - [nixos/modules/hardware/uni-sync\.nix](nixos/modules/hardware/uni-sync.nix)



## hardware\.uni-sync\.devices



List of controllers with their configurations\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  {
    device_id = "VID:1111/PID:11111/SN:1111111111";
    sync_rgb = true;
    channels = [
      {
        mode = "PWM";
      }
      {
        mode = "Manual";
        speed = 100;
      }
      {
        mode = "Manual";
        speed = 54;
      }
      {
        mode = "Manual";
        speed = 0;
      }
    ];
  }
  {
    device_id = "VID:1010/PID:10101/SN:1010101010";
    sync_rgb = false;
    channels = [
      {
        mode = "Manual";
        speed = 0;
      }
    ];
  }
]

```

*Declared by:*
 - [nixos/modules/hardware/uni-sync\.nix](nixos/modules/hardware/uni-sync.nix)



## hardware\.uni-sync\.devices\.\*\.channels



List of channels connected to the controller\.



*Type:*
list of (submodule)



*Default:*

```nix
[ ]
```



*Example:*

```nix
[
  {
    mode = "PWM";
  }
  {
    mode = "Manual";
    speed = 100;
  }
  {
    mode = "Manual";
    speed = 54;
  }
  {
    mode = "Manual";
    speed = 0;
  }
]

```

*Declared by:*
 - [nixos/modules/hardware/uni-sync\.nix](nixos/modules/hardware/uni-sync.nix)



## hardware\.uni-sync\.devices\.\*\.channels\.\*\.mode



“PWM” to enable PWM sync\. “Manual” to set speed\.



*Type:*
one of “Manual”, “PWM”



*Default:*

```nix
"Manual"
```



*Example:*

```nix
"PWM"
```

*Declared by:*
 - [nixos/modules/hardware/uni-sync\.nix](nixos/modules/hardware/uni-sync.nix)



## hardware\.uni-sync\.devices\.\*\.channels\.\*\.speed



Fan speed as percentage (clamped between 0 and 100)\.



*Type:*
signed integer



*Default:*

```nix
"50"
```



*Example:*

```nix
"100"
```

*Declared by:*
 - [nixos/modules/hardware/uni-sync\.nix](nixos/modules/hardware/uni-sync.nix)



## hardware\.uni-sync\.devices\.\*\.device_id



Unique device ID displayed at each startup\.



*Type:*
string



*Example:*

```nix
"VID:1111/PID:11111/SN:1111111111"
```

*Declared by:*
 - [nixos/modules/hardware/uni-sync\.nix](nixos/modules/hardware/uni-sync.nix)



## hardware\.uni-sync\.devices\.\*\.sync_rgb



Enable ARGB header sync\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/uni-sync\.nix](nixos/modules/hardware/uni-sync.nix)



## hardware\.usb-modeswitch\.enable



Enable this option to support certain USB WLAN and WWAN adapters\.

These network adapters initial present themselves as Flash Drives containing their drivers\.
This option enables automatic switching to the networking mode\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/usb-modeswitch\.nix](nixos/modules/hardware/usb-modeswitch.nix)



## hardware\.usbStorage\.manageShutdown



Enable this option to gracefully spin-down external storage during shutdown\.
If you suspect improper head parking after poweroff, install ` smartmontools ` and check
for the ` Power-Off_Retract_Count ` field for an increment\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [nixos/modules/hardware/usb-storage\.nix](nixos/modules/hardware/usb-storage.nix)



## hardware\.wirelessRegulatoryDatabase



Whether to enable loading the wireless regulatory database at boot\.



*Type:*
boolean



*Default:*
Enabled if proprietary firmware is allowed via ` enableRedistributableFirmware ` or ` enableAllFirmware `\.



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/all-firmware\.nix](nixos/modules/hardware/all-firmware.nix)



## hardware\.wooting\.enable



Whether to enable support for Wooting keyboards\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/wooting\.nix](nixos/modules/hardware/wooting.nix)



## hardware\.xone\.enable



Whether to enable the xone driver for Xbox One and Xbox Series X|S accessories\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/xone\.nix](nixos/modules/hardware/xone.nix)



## hardware\.xpad-noone\.enable



Whether to enable the Xpad driver from the Linux kernel with support for Xbox One controllers removed\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/xpad-noone\.nix](nixos/modules/hardware/xpad-noone.nix)



## hardware\.xpadneo\.enable



Whether to enable the xpadneo driver for Xbox One wireless controllers\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [nixos/modules/hardware/xpadneo\.nix](nixos/modules/hardware/xpadneo.nix)



## hardware\.xpadneo\.quirks



Controller-specific quirk flags, keyed by MAC address\.
Flags are combined as a bitmask to address compatibility issues
with specific controllers\.

The value is a sum of individual flag values\. For example, to apply
flags 1, 2, and 4, use ` 7 ` (1 + 2 + 4)\. To apply flags 2, 4, and 32,
use ` 38 ` (2 + 4 + 32)\.

See [https://github\.com/atar-axis/xpadneo/blob/master/docs/CONFIGURATION\.md](https://github\.com/atar-axis/xpadneo/blob/master/docs/CONFIGURATION\.md)
for available quirk flags and their values\.



*Type:*
attribute set of 16 bit unsigned integer; between 0 and 65535 (both inclusive)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  "11:22:33:44:55:66" = 7; # Applies flags 1 + 2 + 4
}

```

*Declared by:*
 - [nixos/modules/hardware/xpadneo\.nix](nixos/modules/hardware/xpadneo.nix)



## hardware\.xpadneo\.rumbleAttenuation



Force feedback attenuation settings\. Higher values reduce rumble strength\.

See [https://github\.com/atar-axis/xpadneo/blob/master/docs/CONFIGURATION\.md](https://github\.com/atar-axis/xpadneo/blob/master/docs/CONFIGURATION\.md)
for more information\.



*Type:*
submodule



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  overall = 50;   # 50% overall rumble
  triggers = 50;  # 25% trigger rumble (50% of 50%)
}

```

*Declared by:*
 - [nixos/modules/hardware/xpadneo\.nix](nixos/modules/hardware/xpadneo.nix)



## hardware\.xpadneo\.rumbleAttenuation\.overall



Overall force feedback attenuation as a percentage\.
` 0 ` means full rumble, ` 100 ` means no rumble\.
Applies to both main and trigger rumble\.



*Type:*
integer between 0 and 100 (both inclusive)



*Default:*

```nix
0
```

*Declared by:*
 - [nixos/modules/hardware/xpadneo\.nix](nixos/modules/hardware/xpadneo.nix)



## hardware\.xpadneo\.rumbleAttenuation\.triggers



Extra attenuation for trigger rumble as a percentage, applied
on top of ` overall `\. For example, ` overall = 50 ` and
` triggers = 50 ` results in 50% main rumble and 25% trigger rumble\.
Set to ` 100 ` to disable trigger rumble while keeping main rumble\.
` null ` means no extra trigger attenuation\.



*Type:*
null or integer between 0 and 100 (both inclusive)



*Default:*

```nix
null
```

*Declared by:*
 - [nixos/modules/hardware/xpadneo\.nix](nixos/modules/hardware/xpadneo.nix)



## hardware\.xpadneo\.settings



Kernel module parameters for hid_xpadneo\. These are passed directly
to the module via modprobe\.

See [https://github\.com/atar-axis/xpadneo/blob/master/docs/CONFIGURATION\.md](https://github\.com/atar-axis/xpadneo/blob/master/docs/CONFIGURATION\.md)
for available parameters and their values\.



*Type:*
attribute set of (signed integer or string)



*Default:*

```nix
{ }
```



*Example:*

```nix
{
  disable_deadzones = 1;
  trigger_rumble_mode = 2;
  disable_shift_mode = 1;
}

```

*Declared by:*
 - [nixos/modules/hardware/xpadneo\.nix](nixos/modules/hardware/xpadneo.nix)



## system\.boot\.enable



Enable\`s boot for installation\.



*Type:*
boolean



*Default:*

```nix
true
```

*Declared by:*
 - [modules/nixos/system/boot](modules/nixos/system/boot)



## system\.boot\.bootManager



Select the Default boot Manager\.



*Type:*
null or one of “grub”, “systemd-boot”, “raspberry”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/system/boot](modules/nixos/system/boot)



## system\.boot\.bootType



Default’s boot option\.



*Type:*
null or one of “efi”, “legacy”, “hybrid-legacy”



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/system/boot](modules/nixos/system/boot)



## system\.boot\.device



Device for GRUB loader (e\.g\., /dev/sda, /dev/vda, /dev/nvme0n1)\.



*Type:*
null or string



*Default:*

```nix
null
```

*Declared by:*
 - [modules/nixos/system/boot](modules/nixos/system/boot)



## system\.boot\.isDualBoot



Enable’s dualboot options\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/system/boot](modules/nixos/system/boot)



## system\.boot\.plymouth



Enable’s plymouth\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/system/boot](modules/nixos/system/boot)



## system\.boot\.secureBoot



Whether or not to enable secure boot\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/system/boot](modules/nixos/system/boot)



## system\.boot\.silentBoot



Whether or not to enable silent boot\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/system/boot](modules/nixos/system/boot)



## system\.console\.options\.enable



Whether to enable Enable console support\.



*Type:*
boolean



*Default:*

```nix
false
```



*Example:*

```nix
true
```

*Declared by:*
 - [modules/nixos/system/console](modules/nixos/system/console)



## system\.security\.pam\.enable



Enable optimizations module\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/system/security/pam](modules/nixos/system/security/pam)



## system\.security\.superuser\.enable



Whether or not enable superuser manager\.



*Type:*
boolean



*Default:*

```nix
false
```

*Declared by:*
 - [modules/nixos/system/security/superuser](modules/nixos/system/security/superuser)



## system\.security\.superuser\.manager



The super user manager to use\.



*Type:*
one of “sudo”, “doas”



*Default:*

```nix
"sudo"
```

*Declared by:*
 - [modules/nixos/system/security/superuser](modules/nixos/system/security/superuser)



## system\.services



A collection of NixOS [modular services](https://nixos\.org/manual/nixos/unstable/\#modular-services) that are configured as systemd services\.



*Type:*
attribute set of (submodule)



*Default:*

```nix
{ }
```

*Declared by:*
 - [nixos/modules/system/service/systemd/system\.nix](nixos/modules/system/service/systemd/system.nix)


