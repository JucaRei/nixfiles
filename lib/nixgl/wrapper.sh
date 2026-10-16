# shellcheck shell=bash disable=SC2154
# Corpo do wrapper nixGL "smart" (multi-GPU, decide em runtime).
#
# O cabeçalho (#! e _target_bin) é gerado por lib/nixgl/default.nix.
# Os placeholders entre arrobas abaixo são substituídos por pkgs.replaceVars (falha se faltar algum).
#
# Prioridade: 1. NVIDIA  2. Intel  3. AMD  4. Mesa/direto
#
# Overrides por variável de ambiente (valor "1"):
#   FORCE_NVIDIA  FORCE_INTEL  FORCE_AMD  FORCE_MESA
#   __NV_PRIME_RENDER_OFFLOAD=0  -> desliga a NVIDIA (equivale a FORCE_INTEL se houver iGPU)

INTEL_RUNNER="@intelRunner@"        # caminho do nixGLIntel ("" = executa direto)
MESA_RUNNER="@mesaRunner@"          # caminho do nixGLMesa  ("" = executa direto)
NVIDIA_VAAPI_DIR="@nvidiaVaapiDir@" # nvidia-vaapi-driver (NVDEC)

# ── Utilitários ──────────────────────────────────────────────────────────────
is_set() { [ "${1:-}" = "1" ]; }

# Prepend em variável tipo PATH: prepend VAR valor
prepend() { export "$1=$2${!1:+:${!1}}"; }

# run_with <runner> [args...]: executa o alvo via runner (vazio = direto)
run_with() {
  local runner="$1"
  shift
  if [ -n "$runner" ]; then
    exec "$runner" "$_target_bin" "$@"
  fi
  exec "$_target_bin" "$@"
}

# ── Detecção de hardware ─────────────────────────────────────────────────────
has_nvidia() { [ -d /proc/driver/nvidia ] || [ -e /dev/nvidia0 ] || [ -e /dev/nvidiactl ]; }
has_intel() { [ -d /sys/module/i915 ] || [ -d /sys/module/xe ] || grep -qs "0x8086" /sys/class/drm/card*/device/vendor 2>/dev/null; }
has_amd() { [ -d /sys/module/amdgpu ] || [ -d /sys/module/radeon ] || grep -qs "0x1002" /sys/class/drm/card*/device/vendor 2>/dev/null; }

# Imprime: nvidia | intel | amd | mesa
select_gpu() {
  local other_forced=false
  if is_set "${FORCE_INTEL:-}" || is_set "${FORCE_AMD:-}" || is_set "${FORCE_MESA:-}"; then
    other_forced=true
  fi

  if is_set "${FORCE_NVIDIA:-}"; then
    echo nvidia
  elif ! $other_forced && [ "${__NV_PRIME_RENDER_OFFLOAD:-}" != "0" ] && has_nvidia; then
    echo nvidia
  elif ! is_set "${FORCE_MESA:-}" && ! is_set "${FORCE_AMD:-}" && { is_set "${FORCE_INTEL:-}" || has_intel; }; then
    echo intel
  elif ! is_set "${FORCE_MESA:-}" && { is_set "${FORCE_AMD:-}" || has_amd; }; then
    echo amd
  else
    echo mesa
  fi
}

# ── NVIDIA proprietária (distro host) ────────────────────────────────────────
setup_nvidia_env() {
  export __NV_PRIME_RENDER_OFFLOAD=1
  export __GLX_VENDOR_LIBRARY_NAME=nvidia
  export __VK_LAYER_NV_optimus=NVIDIA_only
  export MOZ_X11_EGL=1

  # Diretório de symlinks só com as libs do driver (sem expor a libc.so.6 do host)
  local nv_lib_dir="$HOME/.local/share/nixgl-nvidia"
  if [ ! -e "$nv_lib_dir/libGLX_nvidia.so.0" ] || [ ! -e "$nv_lib_dir/libEGL_nvidia.so.0" ]; then
    rm -rf "$nv_lib_dir"
    mkdir -p "$nv_lib_dir"
    local pattern lib
    for pattern in "libGLX_nvidia*" "libEGL_nvidia*" "libGLESv*_nvidia*" "libnvidia-glcore*" \
      "libnvidia-eglcore*" "libnvidia-glsi*" "libnvidia-glvkstream*" "libnvidia-allocator*" \
      "libnvidia-tls*" "libcuda*" "libnvcuvid*" "libnvidia-ml*" "libnvidia-ptxjitcompiler*"; do
      for lib in /usr/lib/x86_64-linux-gnu/$pattern /usr/lib/x86_64-linux-gnu/nvidia/current/$pattern \
        /usr/lib64/$pattern /usr/lib/$pattern /usr/lib/nvidia/$pattern; do
        [ -e "$lib" ] && ln -sf "$lib" "$nv_lib_dir/" 2>/dev/null
      done
    done
  fi
  [ -d "$nv_lib_dir" ] && prepend LD_LIBRARY_PATH "$nv_lib_dir"

  local dir
  for dir in /usr/lib/x86_64-linux-gnu/nvidia/current /usr/lib64/nvidia /usr/lib/nvidia; do
    [ -d "$dir" ] && prepend LD_LIBRARY_PATH "$dir"
  done

  # ICDs de EGL e Vulkan (evita o GLVND ficar restrito ao Mesa)
  local egl vk
  for egl in /usr/share/glvnd/egl_vendor.d/10_nvidia.json /etc/glvnd/egl_vendor.d/10_nvidia.json \
    /usr/lib/x86_64-linux-gnu/nvidia/current/10_nvidia.json; do
    if [ -f "$egl" ]; then
      prepend __EGL_VENDOR_LIBRARY_FILENAMES "$egl:/usr/share/glvnd/egl_vendor.d/50_mesa.json"
      break
    fi
  done
  for vk in /usr/share/vulkan/icd.d/nvidia_icd.json /etc/vulkan/icd.d/nvidia_icd.json; do
    if [ -f "$vk" ]; then
      prepend VK_ICD_FILENAMES "$vk"
      break
    fi
  done

  # Decodificação de vídeo NVDEC
  if [ -f "$NVIDIA_VAAPI_DIR/nvidia_drv_video.so" ]; then
    export LIBVA_DRIVER_NAME=nvidia
    export NVD_BACKEND=direct
    export MOZ_DISABLE_RDD_SANDBOX=1
    prepend LIBVA_DRIVERS_PATH "$NVIDIA_VAAPI_DIR"
  fi
}

# ── Despacho ─────────────────────────────────────────────────────────────────
case "$(select_gpu)" in
  nvidia)
    setup_nvidia_env
    exec "$_target_bin" "$@"
    ;;
  intel) run_with "$INTEL_RUNNER" "$@" ;;
  *) run_with "$MESA_RUNNER" "$@" ;; # amd e mesa usam nixGLMesa
esac
