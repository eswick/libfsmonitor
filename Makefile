THEOS_BUILD_DIR = build

include theos/makefiles/common.mk

LIBRARY_NAME = libfsmonitor
libfsmonitor_FILES = FSMonitor.m
libfsmonitor_PRIVATE_FRAMEWORKS = AppSupport
CFLAGS = -Ilayout/usr/include

include $(THEOS_MAKE_PATH)/library.mk
SUBPROJECTS += fsmonitord
include $(THEOS_MAKE_PATH)/aggregate.mk
