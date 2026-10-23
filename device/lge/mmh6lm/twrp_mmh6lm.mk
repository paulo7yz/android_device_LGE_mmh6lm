#
# twrp_mmh6lm.mk — LG X120 (mmh6ln) / MT6739 — TWRP 9.0
#
$(call inherit-product, vendor/twrp/config/common.mk)

PRODUCT_DEVICE := mmh6lm
PRODUCT_NAME := twrp_mmh6lm
PRODUCT_BRAND := LGE
PRODUCT_MODEL := LM-X120BMW
PRODUCT_MANUFACTURER := LGE

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.device=mmh6lm \
    twrp.device=mmh6lm
