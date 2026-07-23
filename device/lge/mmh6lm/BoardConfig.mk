# =============================================================================
# BoardConfig.mk - LG K8+ (LM-X120BMW) / MT6737M (32-bit ARM)
# TWRP branch android-11
# =============================================================================
# Este BoardConfig é DINÂMICO: inclui device_vars.mk gerado pela auto-descoberta
# (scripts/discover_device.sh) ou pelo fallback (scripts/fallback_vars.sh).
# As variáveis descobertas têm prioridade; valores abaixo são fallback.
# =============================================================================
# CORREÇÕES BUILD #13:
#   - Resolução corrigida: 480x960 (LM-X120 real) em vez de 720x1280
#   - TW_THEME: portrait_mdpi (correto para 480x960)
#   - BOARD_HAS_NO_SELECT_BUTTON := true (LG K8+ só tem volume+power)
#   - Kernel: device/lge/mmh6lm/kernel/zImage
#   - fstab: recovery/root/etc/twrp.fstab
#   - Pixel format: ABGR_8888 (MT6737M/MT6739 exige)
#   - Recovery partition: 26214400 (25MB, original do stock)
#   - userdata: f2fs (stock LG usa f2fs, não ext4)
#   - Crypto: configurado para f2fs
#   - Platform flags: TARGET_USES_64_BIT_BINDER, TARGET_IS_64_BIT
#   - MTK_HARDWARE flags
# =============================================================================

# --- Inclui variáveis descobertas dinamicamente ---
-include device/lge/mmh6lm/device_vars.mk

# =============================================================================
# Arquitetura - MT6737M é 32-bit ARM (kernel 64-bit, userspace 32-bit)
# =============================================================================
TARGET_ARCH := arm
# CRÍTICO: AOSP 11 (twrp-11) exige armv8-a, não armv7-a-neon.
# Cortex-A53 do MT6737M suporta ARMv8-A em modo AArch32.
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_SMP := true

# Kernel é 64-bit, userspace 32-bit (TWRP)
TARGET_IS_64_BIT := false
TARGET_USES_64_BIT_BINDER := true
TARGET_SUPPORTS_64_BIT_APPS := false

# =============================================================================
# Tela / Framebuffer
# =============================================================================
# LG K8+ (LM-X120BMW) tem display 480x960 (18:9 ratio)
# device_vars.mk pode sobrescrever com valores reais do dispositivo
TARGET_SCREEN_WIDTH ?= 480
TARGET_SCREEN_HEIGHT ?= 960

# TW_THEME:
#   portrait_mdpi -> 480x800, 540x960 (medium DPI - correto para 480x960)
#   portrait_hdpi -> 720x1280, 1080x1920 (high DPI)
TW_THEME := portrait_mdpi

# --- CRÍTICO: evita screen blank que crasha UI em alguns MediaTek ---
TW_NO_SCREEN_BLANK := true

# --- Framebuffer alpha channel (exigido por MediaTek) ---
BOARD_USE_FRAMEBUFFER_ALPHA_CHANNEL := true

# --- Gráficos (linelength em vez de stride, comum em MTK) ---
RECOVERY_GRAPHICS_USE_LINELENGTH := true

# =============================================================================
# Brilho
# =============================================================================
TW_BRIGHTNESS_PATH ?= "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS ?= 255
TW_DEFAULT_BRIGHTNESS := 176

# =============================================================================
# USB / UDC
# =============================================================================
USB_UDC_NAME ?= "musb-hdrc"

# =============================================================================
# Configurações de recovery específicas TWRP
# =============================================================================
BOARD_HAS_NO_REAL_SDCARD := true
BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_SUPPRESS_SECURE_ERASE := true
RECOVERY_SDCARD_ON_DATA := true
TW_INCLUDE_NTFS_3G := true
TW_INCLUDE_EXFAT := true
TW_INCLUDE_FUSE_EXFAT := true
TWRP_INCLUDE_LOGCAT := true
TARGET_USES_LOGD := true
TW_DEFAULT_LANGUAGE := en
TW_EXTRA_LANGUAGES := true

# --- Botão de seleção ---
# LG K8+ NÃO tem botão de seleção (select/home). Só volume + power.
# BOARD_HAS_NO_SELECT_BUTTON=true faz TWRP usar volume keys como seleção.
BOARD_HAS_NO_SELECT_BUTTON := true

# --- Habilita ADB em recovery ---
TW_INCLUDE_ADB := true
TW_EXCLUDE_TWRPAPP := true
TW_EXCLUDE_SUPERSU := true
TW_USE_TOOLBOX := false

# --- Input ---
TW_INPUT_BLACKLIST := "hbtp_vm"

# =============================================================================
# Kernel - MT6737M pré-compilado (LG K8+ usa kernel 3.18.x)
# =============================================================================
BOARD_KERNEL_CMDLINE := bootopt=64S3,32S1,32S5 buildvariant=userdebug

# Valores de base/offset do stock LG K8+
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x05000000
BOARD_SECOND_OFFSET := 0x00f00000
BOARD_TAGS_OFFSET := 0x04000000
BOARD_KERNEL_PAGESIZE := 2048

BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset 0x05000000 --second_offset 0x00f00000 --tags_offset 0x04000000

# Kernel pré-compilado do stock
# Está em kernel/zImage no repo, copiado pelo CI para device/lge/mmh6lm/kernel
TARGET_PREBUILT_KERNEL := device/lge/mmh6lm/kernel

# =============================================================================
# Partições - LG K8+ (16GB storage)
# =============================================================================
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 26214400
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1845493760
BOARD_USERDATAIMAGE_PARTITION_SIZE := 12154568704
BOARD_CACHEIMAGE_PARTITION_SIZE := 452984832
BOARD_FLASH_BLOCK_SIZE := 131072

# --- Filesystems (LG stock usa ext2 para system, f2fs para userdata) ---
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext2
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := false

# =============================================================================
# Configurações de build e plataforma
# =============================================================================
BOARD_HAS_MTK_HARDWARE := true
BOARD_USES_MTK_HARDWARE := true
MTK_HARDWARE := true
BOARD_USES_MTK_AUDIO := true
TARGET_NO_BOOTLOADER := true
TARGET_BOOTLOADER_BOARD_NAME := mt6739
TARGET_BOARD_PLATFORM := mt6739
TARGET_BOARD_SUFFIX := _64

# --- system.prop ---
TARGET_SYSTEM_PROP := device/lge/mmh6lm/system_prop.mk

# =============================================================================
# Recovery
# =============================================================================
TARGET_RECOVERY_FSTAB := device/lge/mmh6lm/recovery/root/etc/twrp.fstab
TARGET_RECOVERY_INITRC := rootdir/init.rc
TARGET_RECOVERY_PIXEL_FORMAT := "ABGR_8888"

# --- Backlight path ---
TARGET_RECOVERY_LCD_BACKLIGHT_PATH := "/sys/class/leds/lcd-backlight/brightness"

# =============================================================================
# Graphics
# =============================================================================
BOARD_EGL_CFG := device/lge/mmh6lm/egl.cfg
USE_OPENGL_RENDERER := true
TARGET_USES_ION := true
TARGET_DISABLE_TRIPLE_BUFFERING := false

# =============================================================================
# SELinux (desabilitado em recovery para debug)
# =============================================================================
BOARD_SEPOLICY_DIRS += device/lge/mmh6lm/sepolicy
TARGET_USES_INTERPRETER_SEPOLICY := true

# =============================================================================
# Encryption
# =============================================================================
TW_INCLUDE_CRYPTO := true
TW_CRYPTO_FS_TYPE := "f2fs"
TW_CRYPTO_REAL_BLKDEV := "/dev/block/platform/bootdevice/by-name/userdata"
TW_CRYPTO_MNT_POINT := "/data"
TW_CRYPTO_FS_OPTIONS := "rw,lazytime,seclabel,nosuid,nodev,noatime,background_gc=on,no_heap,user_xattr,inline_xattr,acl,inline_data,inline_dentry,flush_merge,extent_cache,mode=adaptive,active_logs=6,reserve_root=32768,resuid=0,resgid=1065,alloc_mode=reuse,fsync_mode=posix"
PLATFORM_SECURITY_PATCH := 2021-09-01

# =============================================================================
# Flags de compatibilidade Android 11 / TWRP
# =============================================================================
ALLOW_MISSING_DEPENDENCIES := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_USES_BUILD := true
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true

# =============================================================================
# Vendor image
# =============================================================================
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor

# =============================================================================
# Jack compiler (32-bit precisa de mais heap)
# =============================================================================
ANDROID_JACK_VM_SIZE := 4g

# =============================================================================
# CCache
# =============================================================================
USE_CCACHE := true
CCACHE_EXEC := /usr/bin/ccache

# =============================================================================
# Resumo de variáveis dinâmicas (para debug no log de build)
# =============================================================================
# As seguintes variáveis são injetadas por device_vars.mk:
#   TARGET_SCREEN_WIDTH   - largura do framebuffer (default: 480)
#   TARGET_SCREEN_HEIGHT  - altura do framebuffer (default: 960)
#   TW_BRIGHTNESS_PATH    - caminho do sysfs de brilho (default: lcd-backlight)
#   TW_MAX_BRIGHTNESS     - brilho máximo (default: 255)
#   USB_UDC_NAME          - controlador USB (default: musb-hdrc)
#   RO_HARDWARE           - ro.hardware do dispositivo (default: mmh6lm)
#   RO_BOARD_PLATFORM     - plataforma do SoC (default: mt6739)
# =============================================================================
