# lib/nixGL.nix - Wrapper universal do nixGL para binários e arquivos .desktop
#
# O QUE É O nixGL E POR QUE ELE É NECESSÁRIO?
# Em distribuições Linux tradicionais (ex: Fedora, Ubuntu, Debian, Arch), os programas instalados via Nix
# tentam carregar os drivers de vídeo (Nvidia, Mesa/Intel, Vulkan) a partir do diretório do Nix Store (/nix/store).
# Como a distribuição hospedeira usa os drivers do próprio sistema (ex: /usr/lib), os apps GUI crasham sem aceleração de hardware.
# O `nixGL` resolve isso fazendo a ponte entre o app do Nix e o driver OpenGL/Vulkan da distribuição hospedeira.
#
# DETECÇÃO DO NIXGL:
# - Modo impuro (avaliação com --impure, ex: hm-switch): usa `auto.nixGLDefault` que detecta GPU automaticamente.
# - Modo puro (nix flake check, build CI): usa `nixGLIntel` como fallback funcional para sistemas Intel/Mesa.
#   NOTA: O fallback anterior era `exec "$@"` (identidade), que causava erro GL em distros não-NixOS.
#         Agora usamos nixGLIntel que exporta os paths corretos do Mesa do Nix Store.
#
# SELECÇÃO EXPLÍCITA (parâmetro nixGLType):
# Para evitar a auto-detecção quebrada (ex: nixGLNvidia falha no nixpkgs 26.05 por mudança de API),
# use o parâmetro `nixGLType` ao chamar este arquivo:
#   - "intel"  -> nixGLIntel  (Intel/Mesa, recomendado para laptops dual-GPU onde Intel gerencia o display)
#   - "nvidia" -> nixGLNvidia (somente NVIDIA discreta, xorg/wayland rodando na GPU NVIDIA)
#   - "mesa"   -> nixGLMesa   (Mesa genérico, sem VA-API Intel)
#   - "auto"   -> auto.nixGLDefault (detecção automática, pode falhar em alguns sistemas)
#   - null     -> comportamento padrão (auto se impuro, intel se puro)

{
  pkgs,
  # Tipo de wrapper nixGL a usar. Veja comentários acima.
  # Valores: "intel" | "nvidia" | "mesa" | "auto" | null
  nixGLType ? null,
  # Fallback explícito do nixGL caso nixGLType seja null.
  # Detecção:
  # 1. nixGLType explícito -> usa o wrapper correspondente diretamente
  # 2. Modo impuro (builtins.currentTime disponível) e nixGLType=null -> auto.nixGLDefault
  # 3. Modo puro e nixGLType=null -> nixGLIntel (fallback seguro Intel/Mesa)
  nixGL ?
    if nixGLType == "intel" then
      pkgs.nixgl.nixGLIntel
    else if nixGLType == "nvidia" then
      pkgs.nixgl.auto.nixGLNvidia
    else if nixGLType == "mesa" then
      pkgs.nixgl.nixGLMesa
    else if nixGLType == "auto" then
      pkgs.nixgl.auto.nixGLDefault
    else if (builtins ? currentTime && pkgs ? nixgl && pkgs.nixgl ? auto) then
      # Modo impuro com nixGLType=null: tenta auto, com fallback para Intel
      # ATENÇÃO: auto.nixGLDefault pode falhar se a GPU NVIDIA usar uma versão de driver
      # incompatível com o nixpkgs atual. Nesse caso, defina nixGLType = "intel" no mkHome.
      pkgs.nixgl.nixGLIntel
    else if (pkgs ? nixgl && pkgs.nixgl ? nixGLIntel) then
      pkgs.nixgl.nixGLIntel
    else
      (pkgs.writeShellScriptBin "nixGL" ''exec "$@"''),
}:

let
  inherit (pkgs.lib) concatStringsSep optionalString optionalAttrs;
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
      let
        drv = pkgs.runCommandLocal "nixgl-bin-${pkg.name or pkg.pname or "unnamed"}"
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
      in
      drv
      // optionalAttrs (pkg ? override) {
        override = args: wrapper (pkg.override args);
      }
      // optionalAttrs (pkg ? overrideAttrs) {
        overrideAttrs = f: wrapper (pkg.overrideAttrs f);
      };

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
      drv = pkgs.runCommandLocal "nixgl-desktop-${pkg.name or pkg.pname or "unnamed"}"
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
    in
    drv
    // optionalAttrs (pkg ? override) {
      override = args: wrapDesktopFiles (pkg.override args);
    }
    // optionalAttrs (pkg ? overrideAttrs) {
      overrideAttrs = f: wrapDesktopFiles (pkg.overrideAttrs f);
    };
}
