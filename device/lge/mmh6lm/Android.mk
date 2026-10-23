LOCAL_PATH := $(call my-dir)

ifeq ($(TARGET_DEVICE),mmh6lm)
include $(call all-subdir-makefiles,$(LOCAL_PATH))
endif
