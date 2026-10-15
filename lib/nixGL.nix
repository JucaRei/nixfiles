# lib/nixGL.nix - Wrapper nixGL para binários e arquivos .desktop em distros não-NixOS.
#
# nixGLType: "intel" | "nvidia" | "mesa" | "auto" | null
#   intel  → nixGLIntel   (Intel/Mesa; recomendado para laptops Optimus onde Intel gerencia o display)
#   nvidia → nixGLNvidia  (GPU NVIDIA primária)
#   mesa   → nixGLMesa    (Mesa genérico)
#   auto   → auto.nixGLDefault (detecção automática — pode falhar no nixpkgs 26.05 com NVIDIA)
#   null   → nixGLIntel como padrão seguro
#
# ATENÇÃO: auto.nixGLDefault tenta construir nixGLNvidia ao ser avaliado (mesmo com --impure).
# No nixpkgs 26.05 isso falha (API 'kernel' removida). Use nixGLType = "intel" nesses casos.
# O nixGLOverrideOverlay em lib/helpers.nix previne essa avaliação para hosts com nixGLType explícito.

{
  pkgs,
  nixGLType ? null,
}:

let
  inherit (pkgs.lib) optionalAttrs;
  gl = pkgs.nixgl or { };

  intelGL = gl.nixGLIntel or null;
  mesaGL  = gl.nixGLMesa  or null;

  # Cria um wrapper inteligente de aceleração gráfica multi-GPU:
  # Ordem de prioridade estrita:
  # 1. NVIDIA (se dGPU detectada e ativa) -> PRIME Offload + drivers dedicados + NVDEC
  # 2. Intel  (se iGPU detectada) -> nixGLIntel
  # 3. Hardware / Mesa padrão -> nixGLMesa ou execução direta
  mkSmartBinWrapper =
    pkg:
    pkgs.runCommandLocal "nixgl-bin-${pkg.name or pkg.pname or "unnamed"}"
      { inherit (pkg) meta passthru; }
      ''
        set -euo pipefail
        cp -r --no-preserve=mode "${pkg}" "$out"
        rm -rf "$out/bin" && mkdir -p "$out/bin"
        shopt -s nullglob
        for bin in "${pkg}"/bin/*; do
          [ -f "$bin" ] && [ -x "$bin" ] || continue
          name="$(basename "$bin")"
          printf '#!%s\n_target_bin="%s"\n\n' "${pkgs.runtimeShell}" "$bin" > "$out/bin/$name"
          cat << 'EOF_WRAPPER' >> "$out/bin/$name"

# ── NixGL Smart Multi-GPU Wrapper ──────────────────────────────────────────
# Ordem de prioridade estrita:
# 1. NVIDIA (se driver proprietário dGPU detectado e ativo) -> PRIME Offload
# 2. Intel  (se iGPU detectada) -> nixGLIntel
# 3. AMD    (se GPU AMD detectada) -> nixGLMesa
# 4. Hardware / Mesa padrão -> nixGLMesa ou execução direta
#
# Overrides manuais suportados via variáveis de ambiente:
# - FORCE_INTEL=1 ou __NV_PRIME_RENDER_OFFLOAD=0 força uso de Intel
# - FORCE_AMD=1 força uso de AMD
# - FORCE_MESA=1 força uso de Mesa genérico
# - FORCE_NVIDIA=1 força uso de NVIDIA

# ── Detecção de Hardware de Vídeo ──────────────────────────────────────────
_has_nvidia=false
if [ -d /proc/driver/nvidia ] || [ -e /dev/nvidia0 ] || [ -e /dev/nvidiactl ]; then
  _has_nvidia=true
fi

_has_intel=false
if [ -d /sys/module/i915 ] || [ -d /sys/module/xe ] || grep -qs "0x8086" /sys/class/drm/card*/device/vendor 2>/dev/null; then
  _has_intel=true
fi

_has_amd=false
if [ -d /sys/module/amdgpu ] || [ -d /sys/module/radeon ] || grep -qs "0x1002" /sys/class/drm/card*/device/vendor 2>/dev/null; then
  _has_amd=true
fi

# ── 1. Verificação NVIDIA ──────────────────────────────────────────────────
_use_nvidia=false
if [ "''${FORCE_INTEL:-0}" != "1" ] && [ "''${FORCE_AMD:-0}" != "1" ] && [ "''${FORCE_MESA:-0}" != "1" ] && [ "''${__NV_PRIME_RENDER_OFFLOAD:-}" != "0" ]; then
  if [ "$_has_nvidia" = "true" ]; then
    _use_nvidia=true
  fi
fi

if [ "$_use_nvidia" = "true" ]; then
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __VK_LAYER_NV_optimus=NVIDIA_only

  # Cria diretório limpo de symlinks para bibliotecas do driver proprietário NVIDIA
  # (expõe libGLX_nvidia, libEGL_nvidia, libnvidia-glcore sem expor libc.so.6 do host)
  _nv_lib_dir="$HOME/.local/share/nixgl-nvidia"
  if [ ! -e "$_nv_lib_dir/libGLX_nvidia.so.0" ] || [ ! -e "$_nv_lib_dir/libEGL_nvidia.so.0" ]; then
    rm -rf "$_nv_lib_dir"
    mkdir -p "$_nv_lib_dir"
    for _pattern in "libGLX_nvidia*" "libEGL_nvidia*" "libGLESv*_nvidia*" "libnvidia-glcore*" "libnvidia-eglcore*" "libnvidia-glsi*" "libnvidia-glvkstream*" "libnvidia-allocator*" "libnvidia-tls*" "libcuda*" "libnvcuvid*" "libnvidia-ml*" "libnvidia-ptxjitcompiler*"; do
      for _lib in /usr/lib/x86_64-linux-gnu/$_pattern /usr/lib/x86_64-linux-gnu/nvidia/current/$_pattern /usr/lib64/$_pattern /usr/lib/$_pattern /usr/lib/nvidia/$_pattern; do
        if [ -e "$_lib" ]; then
          ln -sf "$_lib" "$_nv_lib_dir/" 2>/dev/null || true
        fi
      done
    done
  fi

  if [ -d "$_nv_lib_dir" ]; then
    export LD_LIBRARY_PATH="$_nv_lib_dir''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
  fi
  for _nv in /usr/lib/x86_64-linux-gnu/nvidia/current /usr/lib64/nvidia /usr/lib/nvidia; do
    if [ -d "$_nv" ]; then
      export LD_LIBRARY_PATH="$_nv''${LD_LIBRARY_PATH:+:$LD_LIBRARY_PATH}"
    fi
  done

  # Configura arquivos ICD do EGL e Vulkan para NVIDIA (evita que o GLVND fique restrito ao Mesa)
  for _egl in /usr/share/glvnd/egl_vendor.d/10_nvidia.json /etc/glvnd/egl_vendor.d/10_nvidia.json /usr/lib/x86_64-linux-gnu/nvidia/current/10_nvidia.json; do
    if [ -f "$_egl" ]; then
      export __EGL_VENDOR_LIBRARY_FILENAMES="$_egl:/usr/share/glvnd/egl_vendor.d/50_mesa.json''${__EGL_VENDOR_LIBRARY_FILENAMES:+:$__EGL_VENDOR_LIBRARY_FILENAMES}"
      break
    fi
  done
  for _vk in /usr/share/vulkan/icd.d/nvidia_icd.json /etc/vulkan/icd.d/nvidia_icd.json; do
    if [ -f "$_vk" ]; then
      export VK_ICD_FILENAMES="$_vk''${VK_ICD_FILENAMES:+:$VK_ICD_FILENAMES}"
      break
    fi
  done

  # Aceleração de vídeo NVDEC via nvidia-vaapi-driver
  if [ -f "${pkgs.nvidia-vaapi-driver}/lib/dri/nvidia_drv_video.so" ]; then
    export LIBVA_DRIVER_NAME=nvidia
    export NVD_BACKEND=direct
    export MOZ_DISABLE_RDD_SANDBOX=1
    export LIBVA_DRIVERS_PATH="${pkgs.nvidia-vaapi-driver}/lib/dri''${LIBVA_DRIVERS_PATH:+:$LIBVA_DRIVERS_PATH}"
  fi
  export MOZ_X11_EGL=1

  exec "$_target_bin" "$@"
fi

# ── 2. Verificação Intel ───────────────────────────────────────────────────
_use_intel=false
if [ "''${FORCE_MESA:-0}" != "1" ] && [ "''${FORCE_AMD:-0}" != "1" ]; then
  if [ "''${FORCE_INTEL:-0}" = "1" ] || [ "$_has_intel" = "true" ]; then
    _use_intel=true
  fi
fi

if [ "$_use_intel" = "true" ]; then
${if intelGL != null then "  exec ${intelGL}/bin/nixGLIntel \"\$_target_bin\" \"\$@\"" else "  exec \"\$_target_bin\" \"\$@\""}
fi

# ── 3. Verificação AMD ─────────────────────────────────────────────────────
_use_amd=false
if [ "''${FORCE_MESA:-0}" != "1" ]; then
  if [ "''${FORCE_AMD:-0}" = "1" ] || [ "$_has_amd" = "true" ]; then
    _use_amd=true
  fi
fi

if [ "$_use_amd" = "true" ]; then
${if mesaGL != null then "  exec ${mesaGL}/bin/nixGLMesa \"\$_target_bin\" \"\$@\"" else "  exec \"\$_target_bin\" \"\$@\""}
fi

# ── 4. Fallback Hardware Padrão (Mesa / Direto) ────────────────────────────
${if mesaGL != null then "exec ${mesaGL}/bin/nixGLMesa \"\$_target_bin\" \"\$@\"" else "exec \"\$_target_bin\" \"\$@\""}
EOF_WRAPPER

          chmod +x "$out/bin/$name"
        done
        shopt -u nullglob
      '';

  # Wrapper para tipos forçados (ex: nixGLType = "mesa")
  mkStaticBinWrapper =
    pkg: targetGL: binName:
    pkgs.runCommandLocal "nixgl-bin-${pkg.name or pkg.pname or "unnamed"}"
      { inherit (pkg) meta passthru; }
      ''
        set -euo pipefail
        cp -r --no-preserve=mode "${pkg}" "$out"
        rm -rf "$out/bin" && mkdir -p "$out/bin"
        shopt -s nullglob
        for bin in "${pkg}"/bin/*; do
          [ -f "$bin" ] && [ -x "$bin" ] || continue
          printf '#!${pkgs.runtimeShell}\nexec %s/bin/%s "%s" "$@"\n' "${targetGL}" "${binName}" "$bin" \
            > "$out/bin/$(basename "$bin")"
          chmod +x "$out/bin/$(basename "$bin")"
        done
        shopt -u nullglob
      '';

  mkWrapper =
    if nixGLType == "intel" && intelGL != null then
      pkg: mkStaticBinWrapper pkg intelGL "nixGLIntel"
    else if nixGLType == "mesa" && mesaGL != null then
      pkg: mkStaticBinWrapper pkg mesaGL "nixGLMesa"
    else
      mkSmartBinWrapper;
in
rec {
  # Envolve os binários de um pacote com nixGL (aceleração de hardware prioritária).
  wrapper =
    pkg:
    if pkg == null || !(pkg ? outPath) then
      pkg
    else
      let drv = mkWrapper pkg; in
      drv
      // optionalAttrs (pkg ? override)     { override     = args: wrapper (pkg.override args); }
      // optionalAttrs (pkg ? overrideAttrs) { overrideAttrs = f:   wrapper (pkg.overrideAttrs f); };

  # Envolve binários preservando caminhos dos arquivos .desktop.
  wrapDesktopFiles = wrapper;
}
