# =============================================================================
# twrp_mmh6lm.mk - LG K8+ (LM-X120) / MT6739
# =============================================================================
# CORREÇÃO: Herdar do TWRP common config, NÃO do full_base.mk.
# full_base.mk compila a recovery AOSP padrão, não o TWRP!
# =============================================================================

# TWRP common config (essencial para compilar TWRP em vez de AOSP recovery)
$(call inherit-product, vendor/twrp/config/common.mk)

# Identificação do dispositivo
PRODUCT_DEVICE := mmh6lm
PRODUCT_NAME := twrp_mmh6lm
PRODUCT_BRAND := LGE
PRODUCT_MODEL := LM-X120
PRODUCT_MANUFACTURER := LGE
PRODUCT_PLATFORM := mt6739

# --- Propriedades do produto ---
PRODUCT_BUILD_PROP_OVERRIDES += \
    PRODUCT_DEVICE=mmh6lm \
    PRODUCT_NAME=mmh6lm \
    BUILD_FINGERPRINT=lge/mmh6lm/mmh6lm:9/PKQ1.180904.001/6739900210901:user/release-keys \
    PRIVATE_BUILD_DESC="mmh6lm-user 9 PKQ1.180904.001 6739900210901 release-keys"

# --- TWRP específico ---
PRODUCT_COPY_FILES += \
    device/lge/mmh6lm/recovery/root/etc/twrp.fstab:recovery/root/etc/twrp.fstab

# --- Recovery init ---
PRODUCT_COPY_FILES += \
    rootdir/init.rc:recovery/root/init.rc \
    rootdir/init.recovery.mt6739.rc:recovery/root/init.recovery.mt6739.rc

# --- Secure boot: desabilitado para recovery ---
PRODUCT_COPY_FILES += \
    device/lge/mmh6lm/recovery/root/init.recovery.mt6739.rc:recovery/root/init.recovery.mt6739.rc
