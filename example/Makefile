ARCHS = armv7 armv7s arm64
include theos/makefiles/common.mk

TWEAK_NAME = FSMonitorTestCase
FSMonitorTestCase_FILES = Tweak.xm
FSMonitorTestCase_LIBRARIES = fsmonitor

include $(THEOS_MAKE_PATH)/tweak.mk

after-install::
	install.exec "killall -9 SpringBoard"
