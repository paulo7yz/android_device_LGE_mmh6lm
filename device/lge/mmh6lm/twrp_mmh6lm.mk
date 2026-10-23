#
# twrp_mmh6lm.mk — LG X120 (mmh6lm) / MT6739 — TWRP 11
#

# Inherit from AOSP base products
$(call inherit-product, $(SRC_TARGET_DIR)/product/aosp_base.mk)

# Inherit common TWRP configurations
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit system properties
$(call inherit-product-if-exists, device/lge/mmh6lm/system_prop.mk)

PRODUCT_DEVICE := mmh6lm
PRODUCT_NAME := twrp_mmh6lm
PRODUCT_BRAND := LGE
PRODUCT_MODEL := LM-X120BMW
PRODUCT_MANUFACTURER := LGE

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.device=mmh6lm \
    twrp.device=mmh6lm
