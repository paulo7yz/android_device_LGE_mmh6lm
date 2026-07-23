# =============================================================================
# system_prop.mk - Propriedades do sistema LG K8+ (LM-X120) MT6739
# =============================================================================

PRODUCT_DEFAULT_PROPERTY_OVERRIDES += \
    ro.secure=0 \
    ro.adb.secure=0 \
    ro.debuggable=1 \
    ro.allow.mock.location=1 \
    persist.sys.usb.config=mtp,adb \
    ro.adb.secure=0

PRODUCT_PROPERTY_OVERRIDES += \
    ro.hardware=mmh6lm \
    ro.board.platform=mt6739 \
    ro.product.model=LM-X120 \
    ro.product.brand=LGE \
    ro.product.manufacturer=LGE \
    ro.sf.lcd_density=240
