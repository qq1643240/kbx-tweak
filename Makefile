export ARCHS = arm64 arm64e
export TARGET = iphone:clang:latest:15.0
export PACKAGE_VERSION = 1.0.4

# 打包方案，可用命令行 / 环境变量覆盖：
#   make package THEOS_PACKAGE_SCHEME=rootless
#   make package THEOS_PACKAGE_SCHEME=roothide
ifeq ($(THEOS_PACKAGE_SCHEME),)
export THEOS_PACKAGE_SCHEME = rootless
endif

include $(THEOS)/makefiles/common.mk

TWEAK_NAME = SuperX
SuperX_FILES = Tweak.xm $(wildcard Sources/*.m)
SuperX_CFLAGS = -fobjc-arc -I$(THEOS_PROJECT_DIR)/Sources -Wno-deprecated-declarations -Wno-unused-function -Wno-unused-variable -Wno-unused-but-set-variable
SuperX_FRAMEWORKS = UIKit Foundation CoreGraphics QuartzCore CoreImage
SuperX_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

TWEAK_NAME = SuperXDisablePasteTips
SuperXDisablePasteTips_FILES = SuperXDisablePasteTips.xm
SuperXDisablePasteTips_CFLAGS = -fobjc-arc
SuperXDisablePasteTips_FRAMEWORKS = UIKit Foundation
SuperXDisablePasteTips_LIBRARIES = substrate

include $(THEOS_MAKE_PATH)/tweak.mk

SUBPROJECTS += prefs
include $(THEOS_MAKE_PATH)/aggregate.mk

after-install::
	install.exec "killall -9 SpringBoard backboardd pasted druid"
