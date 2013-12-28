THEOS_BUILD_DIR = build

include theos/makefiles/common.mk

LIBRARY_NAME = libfsmonitor
libfsmonitor_FILES = libfsmonitor.m

include $(THEOS_MAKE_PATH)/library.mk
SUBPROJECTS += fsmonitord
include $(THEOS_MAKE_PATH)/aggregate.mk
