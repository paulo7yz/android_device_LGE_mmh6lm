# =============================================================================
# BoardConfig.mk — LG X120 / LM-X120BMW (mmh6lm) / MT6739
# Baseado no device tree Samsung A01 Core (MT6739 + TWRP 11) como referência
# =============================================================================

DEVICE_PATH := device/lge/mmh6lm

# For building with minimal manifest
ALLOW_MISSING_DEPENDENCIES := true
BUILD_BROKEN_USES_BUILD := true
BUILD_BROKEN_DUP_RULES := true
BUILD_BROKEN_MISSING_REQUIRED_MODULES := true

# Architecture — 32-bit (armv7l, Cortex-A53 em AArch32)
TARGET_ARCH := arm
TARGET_ARCH_VARIANT := armv8-a
TARGET_CPU_ABI := armeabi-v7a
TARGET_CPU_ABI2 := armeabi
TARGET_CPU_VARIANT := cortex-a53
TARGET_CPU_SMP := true
ARCH_ARM_HAVE_TLS_REGISTER := true

TARGET_IS_64_BIT := false
TARGET_USES_64_BIT_BINDER := false

# Platform
TARGET_BOARD_PLATFORM := mt6739
TARGET_BOOTLOADER_BOARD_NAME := mt6739
TARGET_NO_BOOTLOADER := true

# Bootloader
BOARD_VENDOR := lge
BOARD_HAS_MTK_HARDWARE := true
BOARD_USES_MTK_HARDWARE := true
MTK_HARDWARE := true

# Kernel pré-compilado extraído do stock recovery
TARGET_PREBUILT_KERNEL := $(DEVICE_PATH)/kernel

# Kernel header e offsets (extraídos do stock recovery.img via hex dump)
BOARD_KERNEL_CMDLINE := bootopt=64S3,32S1,32S5 buildvariant=userdebug androidboot.selinux=permissive
BOARD_KERNEL_BASE := 0x40000000
BOARD_KERNEL_PAGESIZE := 2048
BOARD_KERNEL_OFFSET := 0x00008000
BOARD_RAMDISK_OFFSET := 0x05000000
BOARD_KERNEL_TAGS_OFFSET := 0x04000000
BOARD_SECOND_OFFSET := 0x00000000
BOARD_MKBOOTIMG_ARGS := --kernel_offset 0x00008000 --ramdisk_offset 0x05000000 --second_offset 0x00000000 --tags_offset 0x04000000

# Tela / framebuffer (480x960)
TARGET_SCREEN_WIDTH := 480
TARGET_SCREEN_HEIGHT := 960
TW_THEME := portrait_mdpi
TW_NO_SCREEN_BLANK := true
RECOVERY_GRAPHICS_USE_LINELENGTH := true
TARGET_RECOVERY_PIXEL_FORMAT := "RGBX_8888"

# Brilho
TW_BRIGHTNESS_PATH := "/sys/class/leds/lcd-backlight/brightness"
TW_MAX_BRIGHTNESS := 255
TW_DEFAULT_BRIGHTNESS := 150

# Partições (valores reais via /proc/partitions + by-name)
BOARD_BOOTIMAGE_PARTITION_SIZE := 16777216
BOARD_RECOVERYIMAGE_PARTITION_SIZE := 26214400
BOARD_SYSTEMIMAGE_PARTITION_SIZE := 1845493760
BOARD_USERDATAIMAGE_PARTITION_SIZE := 12085227520
BOARD_CACHEIMAGE_PARTITION_SIZE := 528482304
BOARD_FLASH_BLOCK_SIZE := 131072
BOARD_VENDORIMAGE_PARTITION_SIZE := 251658240
BOARD_VENDORIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_COPY_OUT_VENDOR := vendor

# Filesystems
BOARD_SYSTEMIMAGE_FILE_SYSTEM_TYPE := ext4
BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs
BOARD_CACHEIMAGE_FILE_SYSTEM_TYPE := ext4
TARGET_USERIMAGES_USE_EXT4 := true
TARGET_USERIMAGES_USE_F2FS := true
TARGET_USES_MKE2FS := true

BOARD_HAS_LARGE_FILESYSTEM := true
BOARD_HAS_NO_REAL_SDCARD := true
BOARD_SUPPRESS_SECURE_ERASE := true
RECOVERY_SDCARD_ON_DATA := true
BOARD_HAS_NO_SELECT_BUTTON := true

# fstab
TARGET_RECOVERY_FSTAB := $(DEVICE_PATH)/recovery/root/system/etc/recovery.fstab

# --- Crypto DESATIVADO ---
# MT6739: blobs TEE (keymaster/gatekeeper) não estão disponíveis no ramdisk
# do recovery — ativar crypto causa loop infinito no splash screen.
TW_INCLUDE_CRYPTO := false
TW_INCLUDE_CRYPTO_FBE := false
TW_INCLUDE_FBE_METADATA_DECRYPT := false

# Security patch (evita avb rollback check)
PLATFORM_SECURITY_PATCH := 2099-12-31
VENDOR_SECURITY_PATCH := 2099-12-31
PLATFORM_VERSION := 16.1.0
PLATFORM_VERSION_LAST_STABLE := $(PLATFORM_VERSION)

# TWRP flags
RECOVERY_VARIANT := twrp
TW_DEFAULT_LANGUAGE := en
TW_EXTRA_LANGUAGES := true
TW_EXCLUDE_DEFAULT_USB_INIT := true
TARGET_USES_LOGD := true
TWRP_INCLUDE_LOGCAT := true
TW_INPUT_BLACKLIST := "hbtp_vm"
TW_EXCLUDE_TWRPAPP := true
TW_EXCLUDE_SUPERSU := true
TW_USE_TOOLBOX := true
TW_USE_NEW_MINADBD := true
TW_NO_LEGACY_PROPS := true
TW_NO_BIND_SYSTEM := true
TW_INCLUDE_FUSE_EXFAT := true
TW_INCLUDE_FUSE_NTFS := true
TW_INCLUDE_NTFS_3G := true
TW_HAS_MTP := true

# ccache
USE_CCACHE := 1
CCACHE_EXEC := /usr/bin/ccache
