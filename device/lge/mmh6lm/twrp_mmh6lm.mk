# =============================================================================
# twrp_mmh6lm.mk - LG K8+ (LM-X120) / MT6739
# =============================================================================
# Herda do TWRP common config (vendor/twrp sincronizado via local_manifest)
# =============================================================================

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

# --- fstab e init ---
PRODUCT_COPY_FILES += \
    device/lge/mmh6lm/recovery/root/etc/twrp.fstab:recovery/root/etc/twrp.fstab \
    rootdir/init.rc:recovery/root/init.rc \
    rootdir/init.recovery.mt6739.rc:recovery/root/init.recovery.mt6739.rc
