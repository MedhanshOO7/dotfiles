-- hyprlang noerror false

-- ######### Input method ##########
-- See https://fcitx-im.org/wiki/Using_Fcitx_5_on_Wayland
-- hl.env("QT_IM_MODULE", "fcitx")
-- hl.env("XMODIFIERS", "@im=fcitx")
-- hl.env("SDL_IM_MODULE", "fcitx")
-- hl.env("GLFW_IM_MODULE", "ibus")
-- hl.env("INPUT_METHOD", "fcitx")

-- ######## Wayland #########
-- Tearing
-- hl.env("WLR_DRM_NO_ATOMIC", "1")
-- ?
-- hl.env("WLR_NO_HARDWARE_CURSORS", "1")

-- ######## NVIDIA / Wayland (Hybrid mode: Intel scanout, NVIDIA render) #########
-- DRM device order: Intel (card1) first for display scanout, NVIDIA (card0) second for rendering
hl.env("AQ_DRM_DEVICES", "/dev/dri/card1:/dev/dri/card0")

-- NVIDIA rendering
hl.env("NVD_BACKEND", "direct")                                                       -- NVIDIA direct backend for better perf
-- hl.env("GBM_BACKEND", "nvidia-drm")                                                   -- GBM via NVIDIA DRM
-- hl.env("__GLX_VENDOR_LIBRARY_NAME", "nvidia")                                          -- GLX through NVIDIA

-- VA-API (hardware video decode via Intel iGPU)
hl.env("LIBVA_DRIVER_NAME", "iHD")                                                    -- Intel VA-API driver
-- hl.env("__EGL_VENDOR_LIBRARY_FILENAMES", "/usr/share/glvnd/egl_vendor.d/50_mesa.json") -- Mesa EGL for Intel VA-API
hl.env("VDPAU_DRIVER", "nvidia")                                                      -- VDPAU through NVIDIA for apps that use it

-- Firefox
hl.env("MOZ_ENABLE_WAYLAND", "1")                                                     -- Native Wayland
hl.env("MOZ_DRM_DEVICE", "/dev/dri/renderD128")                                       -- Intel render node for WebGL/video (better battery life)

-- LibreOffice (GTK3 native Wayland backend for dark mode, scaling, and smooth rendering)
hl.env("SAL_USE_VCLPLUGIN", "gtk3")

-- ######## EDITOR #########
-- https://wiki.archlinux.org/title/Category:Text_editors
-- for example: vi nano nvim ...
-- hl.env("EDITOR", "vim")
