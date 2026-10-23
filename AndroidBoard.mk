LOCAL_PATH := $(call my-dir)

ifneq ($(filter mmh6lm,$(TARGET_DEVICE)),)
include $(call all-makefiles-under,$(LOCAL_PATH))
endif
