# lib/nixGL.nix - Wrapper universal do nixGL para binários e arquivos .desktop
#
# O QUE É O nixGL E POR QUE ELE É NECESSÁRIO?
# Em distribuições Linux tradicionais (ex: Fedora, Ubuntu, Arch), os programas instalados via Nix
# tentam carregar os drivers de vídeo (Nvidia, Mesa/Intel, Vulkan) a partir do diretório do Nix Store (/nix/store).
# Como a distribuição hospedeira usa os drivers do próprio sistema (ex: /usr/lib), os apps GUI crasham sem aceleração de hardware.
# O `nixGL` resolve isso fazendo a ponte entre o app do Nix e o driver OpenGL/Vulkan da distribuição hospedeira.

{
  pkgs,
  # Detecção do nixGL:
  # 1. Se estiver rodando no sistema com GPU e em modo impuro, usa a detecção automática `pkgs.nixgl.auto.nixGLDefault`.
  # 2. Se estiver em modo de avaliação pura do Nix (ex: `nix flake check`), usa um script fallback transparente `exec "$@"`
  #    para evitar erros de `builtins.currentTime` inexistente na avaliação pura.
  nixGL ?
    if (builtins ? currentTime && pkgs ? nixgl && pkgs.nixgl ? auto) then
      pkgs.nixgl.auto.nixGLDefault
    else
      (pkgs.writeShellScriptBin "nixGL" ''exec "$@"''),
}:

let
  inherit (pkgs.lib) concatStringsSep optionalString;
in
rec {
  # ---------------------------------------------------------------------------
  # 1. WRAPPER DE BINÁRIOS (`wrapper`)
  # ---------------------------------------------------------------------------
  # Recebe um pacote Nix (ex: `pkgs.alacritty`) e empacota todos os seus executáveis em `bin/`.
  # Em vez de chamar o binário diretamente, ele cria um script shell que executa:
  #   `nixGL /nix/store/...-alacritty/bin/alacritty "$@"`
  # Isso garante aceleração de hardware por GPU via terminal.
  wrapper =
    pkg:
    if pkg == null || !(pkg ? outPath) then
      pkg
    else
      pkgs.runCommandLocal "nixgl-bin-${pkg.name or pkg.pname or "unnamed"}"
        {
          inherit (pkg) meta passthru;
        }
        ''
                      set -euo pipefail

                      # Copia a estrutura original do pacote sem sobrescrever o nix store original
                      cp -r --no-preserve=mode "${pkg}" "$out"

                      # Recria a pasta bin/ com os scripts envoltos pelo nixGL
                      rm -rf "$out/bin"
                      mkdir -p "$out/bin"

                      # Itera sobre cada binário do pacote e cria o wrapper
                      shopt -s nullglob
                      for bin in "${pkg}"/bin/*; do
                        if [ -f "$bin" ] && [ -x "$bin" ]; then
                          cat > "$out/bin/$(basename "$bin")" <<EOF
          #!${pkgs.runtimeShell}
          exec ${nixGL}/bin/nixGL "$bin" "\$@"
          EOF
                          chmod +x "$out/bin/$(basename "$bin")"
                        fi
                      done
                      shopt -u nullglob
        '';

  # ---------------------------------------------------------------------------
  # 2. WRAPPER DE ARQUIVOS DESKTOP (`wrapDesktopFiles`)
  # ---------------------------------------------------------------------------
  # Além dos binários, altera os atalhos de menu gráfico (arquivos `.desktop`).
  # Substitui a linha `Exec=programa` por `Exec=nixGL programa`.
  # Isso garante que abrir o programa pelo menu do sistema (GNOME, XFCE, Rofi, etc) também use a GPU.
  wrapDesktopFiles =
    pkg:
    let
      binWrapped = wrapper pkg;
    in
    pkgs.runCommandLocal "nixgl-desktop-${pkg.name or pkg.pname}"
      {
        inherit (pkg) meta passthru;
      }
      ''
        set -euo pipefail

        cp -r --no-preserve=mode "${binWrapped}" "$out"

        # Diretório temporário para edição segura dos atalhos .desktop
        mkdir -p temp_desktop

        shopt -s globstar nullglob
        for d in "$out"/share/applications/**/*.desktop "$out"/share/gnome/applications/**/*.desktop; do
          if [ -f "$d" ]; then
            cp "$d" temp_desktop/temp.desktop
            sed 's|^Exec=\(.*\)$|Exec=${nixGL}/bin/nixGL \1|' temp_desktop/temp.desktop > "$d"
            rm temp_desktop/temp.desktop
          fi
        done
        shopt -u globstar nullglob

        rm -rf temp_desktop
      '';
}
