include theos/makefiles/common.mk

TWEAK_NAME = SiriIfPossible

SiriIfPossible_FILES = /mnt/d/codes/siriifpossible/SiriIfPossible.xm
SiriIfPossible_FRAMEWORKS = CydiaSubstrate Foundation UIKit
SiriIfPossible_PRIVATE_FRAMEWORKS = AppSupport
SiriIfPossible_LDFLAGS = -Wl,-segalign,4000
SiriIfPossible_CFLAGS = -fobjc-arc

export ARCHS = armv7 arm64
SiriIfPossible_ARCHS = armv7 arm64

include $(THEOS_MAKE_PATH)/tweak.mk
	
all::
	