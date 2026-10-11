export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0

ifeq ($(THEOS_PACKAGE_SCHEME),)
export THEOS_PACKAGE_SCHEME = rootless
endif

include $(THEOS)/makefiles/common.mk

BUNDLE_NAME = SuperXPrefs
SuperXPrefs_FILES = $(wildcard *.m) $(wildcard Cells/*.m)
SuperXPrefs_INSTALL_PATH = /Library/PreferenceBundles
SuperXPrefs_CFLAGS = -fobjc-arc -fno-autolink -I$(THEOS_PROJECT_DIR)/prefs -I$(THEOS_PROJECT_DIR)/prefs/Cells -I$(THEOS_PROJECT_DIR)/Sources -Wno-deprecated-declarations -Wno-unused-function -Wno-unused-variable
SuperXPrefs_FRAMEWORKS = UIKit Foundation SafariServices
SuperXPrefs_LIBRARIES = substrate
# Preferences.framework 是私有框架，SDK 中不存在，符号留待运行时解析
SuperXPrefs_LDFLAGS = -undefined dynamic_lookup

include $(THEOS_MAKE_PATH)/bundle.mk
