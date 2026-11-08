{
  cfg,
  shouldInstall,
  optionalString,
}:
(
  if !shouldInstall then
    ''
      [hw-preset]
      profile-desc=Distro Nativa: Perfil Universal Seguro (auto hwdec, vo=gpu,x11)
      vo=gpu,x11
      gpu-api=auto
      hwdec=vaapi-copy,vaapi,no
      video-sync=audio
      ${optionalString (cfg.vaapiDevice != null) ''
        vaapi-device=${cfg.vaapiDevice}
      ''}
    ''
  else if cfg.profile == "nitro" then
    ''
      [hw-preset]
      profile-desc=Nitro 5: Intel UHD 630 via nixGLIntel (vaapi, opengl)
      vo=gpu,x11
      gpu-api=opengl
      hwdec=vaapi
      gpu-shader-cache-dir=~/.cache/mpv/shaders
      video-sync=display-resample
    ''
  else if cfg.profile == "legacy-nvidia" then
    ''
      [hw-preset]
      profile-desc=Rocinante: NVIDIA 340 Legacy (Proprietário)
      vo=gpu
      gpu-api=opengl
      hwdec=no
      profile=fast
      scale=bilinear
      cscale=bilinear
      dscale=bilinear
    ''
  else if cfg.profile == "legacy-nouveau" then
    ''
      [hw-preset]
      profile-desc=Rocinante: Nouveau (Open Source)
      vo=gpu
      gpu-api=opengl
      hwdec=vaapi
      scale=bilinear
      cscale=bilinear
      dscale=bilinear
    ''
  else if cfg.profile == "low-ram" then
    ''
      [hw-preset]
      profile-desc=MacBook Air: Intel HD 3000 (vaapi, opengl, 2GB RAM)
      vo=gpu
      gpu-api=opengl
      hwdec=vaapi
      scale=bilinear
      cscale=bilinear
      dscale=bilinear
      correct-downscaling=no
      sigmoid-upscaling=no
      cache-secs=5
      video-sync=audio
    ''
  else if cfg.profile == "software" then
    ''
      [hw-preset]
      profile-desc=Hyper-V: Software rendering (x11, sem hwdec)
      vo=x11
      hwdec=no
      video-sync=audio
    ''
  else
    ''
      [hw-preset]
      profile-desc=Generic: auto hwdec (auto-safe, opengl)
      vo=gpu
      gpu-api=auto
      hwdec=auto-safe
    ''
)
+ (optionalString cfg.hybridGraphics ''

  [nvidia]
  profile-desc=Nitro 5: NVIDIA dGPU via PRIME (nvdec/cuda/auto)
  vo=gpu
  gpu-api=auto
  hwdec=nvdec-copy,cuda-copy,auto-safe
  gpu-shader-cache-dir=~/.cache/mpv/shaders-nvidia
  video-sync=display-resample
'')
