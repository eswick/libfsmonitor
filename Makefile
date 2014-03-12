ARCHS = armv7 armv7s arm64
THEOS_BUILD_DIR = build

include theos/makefiles/common.mk

LIBRARY_NAME = libfsmonitor
libfsmonitor_FILES = FSMonitor.m
libfsmonitor_PRIVATE_FRAMEWORKS = AppSupport
libfsmonitor_FRAMEWORKS = UIKit
CFLAGS = -Ilayout/usr/include
libfsmonitor_LIBRARIES = rocketbootstrap

include $(THEOS_MAKE_PATH)/library.mk
SUBPROJECTS += fsmonitord
include $(THEOS_MAKE_PATH)/aggregate.mk
