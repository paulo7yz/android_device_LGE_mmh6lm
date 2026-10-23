# =============================================================================
# BoardConfig.mk — LG X120 / LM-X120BMW (mmh6lm) / MT6739
#
# Baseado em dados REAIS extraídos do aparelho via ADB (root Magisk):
#   ro.board.platform = mt6739, ro.mediatek.platform = MT6739
#   ro.build.version.release = 9  (SDK 28), fingerprint PKQ1.180904.001
#   kernel 4.4.146 armv7l (32-bit userspace, 64-bit kernel na prática NÃO é —
#     uname = armv7l, bootopt=64S3,32N2,32N2 → kernel 32-bit+userspace 32-bit)
#   framebuffer fb0 virtual_size = 480x2880 (triple buffer) → painel 480x960
#   fb0 bits_per_pixel não acessível (SELinux); MTK default RGBX 8888/BGRX
#   UDC = musb-hdrc
#   Bootloader: state=unlocked (vbmeta.device_state=unlocked)
#   Kernel zImage extraído de recovery.img @0x800 (0x844076 bytes = 8.67MB)
#
# Layout recovery.img ((fonte: hex dump do stock recovery.img):
#   page_size    = 2048
#   kernel_addr  = 0x40008000, kernel_size = 0x00844076 (~8.3 MB)
#   ramdisk_addr = 0x45000000  (ramdisk começa na página 0x845000)
#   tags_addr    = 0x44000000, dt_size = 0, second = 0
#   cmdline      = "bootopt=64S3,32S1,32S5 buildvariant=userdebug buildvariant=eng"
#   LG patchea o campo ramdisk_size no header (valor falso 62); LK lê o
#   ramdisk da página seguinte ao kernel. Não usamos mkbootimg distro;
#   geramos recovery.img por repack do stock (ver tools/repack_lg.py).
# =============================================================================

# --- Inclui variáveis estáticas (agora hardcode; nada de auto-descoberta) ---
# AOSP 11 exige armv8-a para arm 32-bit (Cortex-A53 roda AArch32)
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_SMP := true
ARCH_ARM_HAVE_TLS_REGISTER := true

TARGET_IS_64_BIT := false
TARGET_USES_64_BIT_BINDER := false

# --- Kernel pré-compilado extraído do stock recovery/boot ---
TARGET_PREBUILT_KERNEL := device/lge/mmh6lm/kernel

# --- Boot / recovery header (LEGACY + offset custom LG) ---
BOARD_KERNEL_CMDLINE := bootopt=64S3,32S1,32S5 buildvariant=userdebug
BOARD_KERNEL_BASE := 0x40008000
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x45000000
BOARD_SECOND_OFFSET := 0x00000000
BOARD_TAGS_OFFSET := 0x44000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset 0x45000000 --second_offset 0x00000000 --tags_offset 0x44000000

# --- Tela / framebuffer (480x960 HD+ 18:9) ---
TARGET_SCREEN_WIDTH := 480
TARGET_SCREEN_HEIGHT := 960
TW_THEME := portrait_mdpi
TW_NO_SCREEN_BLANK := true
BOARD_USE_FRAMEBUFFER_ALPHA_CHANNEL := true
RECOVERY_GRAPHICS_USE_LINELENGTH := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"

# --- Brilho ---
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 150

# --- USB / UDC ---
TW_INCLUDE_CRYPTO := true

# --- Botões de seleção ---
BOARD_HAS_NO_SELECT_BUTTON := true

# --- Partições (do /proc/partitions + by-name real) ---
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 26214400
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1845493760
BOARD_USERDATAIMAGE_PARTITION_SIZE := 12085227520
BOARD_CACHEIMAGE_PARTITION_SIZE := 528482304
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_VENDORIMAGE_PARTITION_SIZE := 251658240
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor

# --- Filesystems REAIS do fstab de vendor ---
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true

BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_REAL_SDCARD := true
BOARD_SUPPRESS_SECURE_ERASE := true
RECOVERY_SDCARD_ON_DATA := true

# --- fstab do recovery ---
TARGET_RECOVERY_FSTAB := device/lge/mmh6lm/recovery/root/system/etc/recovery.fstab

# --- TWRP flags ---
TW_DEFAULT_LANGUAGE := en
TW_EXTRA_LANGAGES := false
TW_EXCLUDE_DEFAULT_USB_INIT := true
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_EXCLUDE_TWRPAPP := true
TW_EXCLUDE_SUPERSU := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_LOW_RES_SUPPORT := true
TW_USE_TOOLBOX := true

# --- SELinux / MTK ---
BOARD_HAS_MTK_HARDWARE := true
BOARD_USES_MTK_HARDWARE := true
MTK_DYNAMIC_KERNEL := true
MTK_HARDWARE := true

TARGET_BOOTLOADER_BOARD_NAME := mt6739
TARGET_BOARD_PLATFORM := mt6739
TARGET_NO_BOOTLOADER := true

# --- Encryption (FBE) ---
TW_INCLUDE_CRYPTO := true
TW_CRYPTO_FS_TYPE := "f2fs"
TW_CRYPTO_REAL_BLKDEV := "/dev/block/platform/bootdevice/by-name/userdata"
TW_CRYPTO_MNT_POINT := "/data"
TW_CRYPTO_FS_OPTIONS := "rw,noatime,nosuid,nodev,discard,noflush_merge,rsv_percent=0"
TW_NOTHW_ENCRYPTION := true

# --- Compatibilidade de build ---
ALLOW_MISSING_DEPENDENCIES := true
BUILD_BROKEN_USES_BUILD := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true

# --- ccache ---
USE_CCACHE := 1
CCACHE_EXEC := /usr/bin/ccache
