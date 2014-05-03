PRODUCT_BRAND ?= cyanogenmod

SUPERUSER_EMBEDDED := true
SUPERUSER_PACKAGE_PREFIX := com.android.settings.cyanogenmod.superuser

# To deal with CM9 specifications
# TODO: remove once all devices have been switched
ifneq ($(TARGET_BOOTANIMATION_NAME),)
TARGET_SCREEN_DIMENSIONS := $(subst -, $(space), $(subst x, $(space), $(TARGET_BOOTANIMATION_NAME)))
ifeq ($(TARGET_SCREEN_WIDTH),)
TARGET_SCREEN_WIDTH := $(word 2, $(TARGET_SCREEN_DIMENSIONS))
endif
ifeq ($(TARGET_SCREEN_HEIGHT),)
TARGET_SCREEN_HEIGHT := $(word 3, $(TARGET_SCREEN_DIMENSIONS))
endif
endif

ifneq ($(TARGET_SCREEN_WIDTH) $(TARGET_SCREEN_HEIGHT),$(space))

# clear TARGET_BOOTANIMATION_NAME in case it was set for CM9 purposes
TARGET_BOOTANIMATION_NAME :=

# determine the smaller dimension
TARGET_BOOTANIMATION_SIZE := $(shell \
  if [ $(TARGET_SCREEN_WIDTH) -lt $(TARGET_SCREEN_HEIGHT) ]; then \
    echo $(TARGET_SCREEN_WIDTH); \
  else \
    echo $(TARGET_SCREEN_HEIGHT); \
  fi )

# get a sorted list of the sizes
bootanimation_sizes := $(subst .zip,, $(shell ls vendor/cm/prebuilt/common/bootanimation))
bootanimation_sizes := $(shell echo -e $(subst $(space),'\n',$(bootanimation_sizes)) | sort -rn)

# find the appropriate size and set
define check_and_set_bootanimation
$(eval TARGET_BOOTANIMATION_NAME := $(shell \
  if [ -z "$(TARGET_BOOTANIMATION_NAME)" ]; then
    if [ $(1) -le $(TARGET_BOOTANIMATION_SIZE) ]; then \
      echo $(1); \
      exit 0; \
    fi;
  fi;
  echo $(TARGET_BOOTANIMATION_NAME); ))
endef
$(foreach size,$(bootanimation_sizes), $(call check_and_set_bootanimation,$(size)))

PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bootanimation/$(TARGET_BOOTANIMATION_NAME).zip:system/media/bootanimation.zip
endif

ifdef CM_NIGHTLY
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmodnightly
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.rommanager.developerid=cyanogenmod
endif

PRODUCT_BUILD_PROP_OVERRIDES += BUILD_UTC_DATE=0

ifeq ($(PRODUCT_GMS_CLIENTID_BASE),)
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=android-google
else
PRODUCT_PROPERTY_OVERRIDES += \
    ro.com.google.clientidbase=$(PRODUCT_GMS_CLIENTID_BASE)
endif

PRODUCT_PROPERTY_OVERRIDES += \
    keyguard.no_require_sim=true \
    ro.url.legal=http://www.google.com/intl/%s/mobile/android/basic/phone-legal.html \
    ro.url.legal.android_privacy=http://www.google.com/intl/%s/mobile/android/basic/privacy.html \
    ro.com.android.wifi-watchlist=GoogleGuest \
    ro.setupwizard.enterprise_mode=1 \
    ro.com.android.dateformat=MM-dd-yyyy \
    ro.com.android.dataroaming=false \
    pm.sleep_mode=0 \
    ro.ril.disable.power.collapse=0 \
    ro.vold.umsdirtyratio=20

PRODUCT_PROPERTY_OVERRIDES += \
    ro.build.selinux=1 \
    persist.sys.root_access=1 \
    persist.sys.dun.override=0

# Backup Tool
ifneq ($(WITH_GMS),true)
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/bin/backuptool.sh:system/bin/backuptool.sh \
    vendor/cm/prebuilt/common/bin/backuptool.functions:system/bin/backuptool.functions \
    vendor/cm/prebuilt/common/bin/50-cm.sh:system/addon.d/50-cm.sh \
    vendor/cm/prebuilt/common/bin/blacklist:system/addon.d/blacklist
endif

# init.d support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/00banner:system/etc/init.d/00banner \
    vendor/cm/prebuilt/common/bin/sysinit:system/bin/sysinit \
    vendor/cm/prebuilt/common/bin/99-backup.sh:system/addon.d/99-backup.sh \
    vendor/cm/prebuilt/common/etc/backup.conf:system/etc/backup.conf \
    vendor/cm/prebuilt/common/etc/init.d/00check:system/etc/init.d/00check \
    vendor/cm/prebuilt/common/etc/init.d/01zipalign:system/etc/init.d/01zipalign \
    vendor/cm/prebuilt/common/etc/init.d/02sysctl:system/etc/init.d/02sysctl \
    vendor/cm/prebuilt/common/etc/init.d/03firstboot:system/etc/init.d/03firstboot \
    vendor/cm/prebuilt/common/etc/init.d/05freemem:system/etc/init.d/05freemem \
    vendor/cm/prebuilt/common/etc/init.d/06removecache:system/etc/init.d/06removecache \
    vendor/cm/prebuilt/common/etc/init.d/07fixperms:system/etc/init.d/07fixperms \
    vendor/cm/prebuilt/common/etc/init.d/09cron:system/etc/init.d/09cron \
    vendor/cm/prebuilt/common/etc/init.d/10sdboost:system/etc/init.d/10sdboost \
    vendor/cm/prebuilt/common/etc/init.d/11battery:system/etc/init.d/11battery \
    vendor/cm/prebuilt/common/etc/init.d/12touch:system/etc/init.d/12touch \
    vendor/cm/prebuilt/common/etc/init.d/13minfree:system/etc/init.d/13minfree \
    vendor/cm/prebuilt/common/etc/init.d/14gpurender:system/etc/init.d/14gpurender \
    vendor/cm/prebuilt/common/etc/init.d/15sleepers:system/etc/init.d/15sleepers \
    vendor/cm/prebuilt/common/etc/init.d/16journalism:system/etc/init.d/16journalism \
    vendor/cm/prebuilt/common/etc/init.d/17sqlite3:system/etc/init.d/17sqlite3 \
    vendor/cm/prebuilt/common/etc/init.d/18wifisleep:system/etc/init.d/18wifisleep \
    vendor/cm/prebuilt/common/etc/init.d/19iostats:system/etc/init.d/19iostats \
    vendor/cm/prebuilt/common/etc/init.d/20setrenice:system/etc/init.d/20setrenice \
    vendor/cm/prebuilt/common/etc/init.d/21tweaks:system/etc/init.d/21tweaks \
    vendor/cm/prebuilt/common/etc/init.d/24speedy_modified:system/etc/init.d/24speedy_modified \
    vendor/cm/prebuilt/common/etc/init.d/25loopy_smoothness_tweak:system/etc/init.d/25loopy_smoothness_tweak \
    vendor/cm/prebuilt/common/etc/init.d/98tweaks:system/etc/init.d/98tweaks \
    vendor/cm/prebuilt/common/etc/helpers.sh:system/etc/helpers.sh \
    vendor/cm/prebuilt/common/etc/sysctl.conf:system/etc/sysctl.conf \
    vendor/cm/prebuilt/common/etc/init.d.cfg:system/etc/init.d.cfg

# Added xbin files
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/xbin/zip:system/xbin/zip \
    vendor/cm/prebuilt/common/xbin/zipalign:system/xbin/zipalign

# userinit support
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.d/90userinit:system/etc/init.d/90userinit

# CM-specific init file
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/init.local.rc:root/init.cm.rc

# Copy JNI libarary of Term
PRODUCT_COPY_FILES +=  \
    vendor/cm/proprietary/Term.apk:system/app/Term.apk \
    vendor/cm/proprietary/lib/armeabi/libjackpal-androidterm4.so:system/lib/libjackpal-androidterm4.so \
    vendor/cm/prebuilt/hololauncherhd/HoloLauncherHD.apk:system/app/HoloLauncherHD.apk \
    vendor/cm/prebuilt/Nova.apk:system/app/Nova.apk \
    vendor/cm/prebuilt/appsetting.apk:system/app/appsetting.apk \
    vendor/cm/prebuilt/xposed_installer.apk:system/app/xposed_installer.apk

# Bring in camera effects
PRODUCT_COPY_FILES +=  \
    vendor/cm/prebuilt/common/media/LMprec_508.emd:system/media/LMprec_508.emd \
    vendor/cm/prebuilt/common/media/PFFprec_600.emd:system/media/PFFprec_600.emd

# Enable SIP+VoIP on all targets
PRODUCT_COPY_FILES += \
    frameworks/native/data/etc/android.software.sip.voip.xml:system/etc/permissions/android.software.sip.voip.xml

# Enable wireless Xbox 360 controller support
PRODUCT_COPY_FILES += \
    frameworks/base/data/keyboards/Vendor_045e_Product_028e.kl:system/usr/keylayout/Vendor_045e_Product_0719.kl

# This is CM!
PRODUCT_COPY_FILES += \
    vendor/cm/config/permissions/com.cyanogenmod.android.xml:system/etc/permissions/com.cyanogenmod.android.xml

# Don't export PS1 in /system/etc/mkshrc.
PRODUCT_COPY_FILES += \
    vendor/cm/prebuilt/common/etc/sysctl.conf:system/etc/sysctl.conf

# T-Mobile theme engine
include vendor/cm/config/themes_common.mk

# Required CM packages
PRODUCT_PACKAGES += \
    Development \
    BluetoothExt \
    LatinIME \
    Superuser \
    su

# Optional CM packages
PRODUCT_PACKAGES += \
    VoicePlus \
    VoiceDialer \
    SoundRecorder \
    Basic \
    libemoji

# Custom CM packages
PRODUCT_PACKAGES += \
    Launcher3 \
    Trebuchet \
    DSPManager \
    libcyanogen-dsp \
    audio_effects.conf \
    ScreenRecorder \
    libscreenrecorder \
    BeanStalkPapers \
    BeanStalkOTA \
    Apollo \
    MonthCalendarWidget \
    LockClock \
    DashClock \
    StalkExplorer

PRODUCT_PACKAGES += \
    CellBroadcastReceiver

PRODUCT_PACKAGES += \
    org.cyanogenmod.hardware \
    org.cyanogenmod.hardware.xml

# Extra tools in CM
PRODUCT_PACKAGES += \
    libsepol \
    openvpn \
    e2fsck \
    mke2fs \
    tune2fs \
    bash \
    vim \
    nano \
    htop \
    powertop \
    lsof \
    mount.exfat \
    fsck.exfat \
    mkfs.exfat \
    ntfsfix \
    ntfs-3g \
    gdbserver \
    micro_bench \
    oprofiled \
    procmem \
    procrank \
    sqlite3 \
    strace

# Openssh
PRODUCT_PACKAGES += \
    scp \
    sftp \
    ssh \
    sshd \
    sshd_config \
    ssh-keygen \
    start-ssh

# rsync
PRODUCT_PACKAGES += \
    rsync

# easy way to extend to add more packages
-include vendor/extra/product.mk

PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/dictionaries
PRODUCT_PACKAGE_OVERLAYS += vendor/cm/overlay/common

PRODUCT_VERSION_MAJOR = 11
PRODUCT_VERSION_MINOR = 0
PRODUCT_VERSION_MAINTENANCE = 0-RC0

# Set CM_BUILDTYPE from the env RELEASE_TYPE, for jenkins compat

ifndef CM_BUILDTYPE
ifdef RELEASE_TYPE
# Starting with "CM_" is optional
        RELEASE_TYPE := $(shell echo $(RELEASE_TYPE) | sed -e 's|^CM_||g')
        CM_BUILDTYPE := $(RELEASE_TYPE)
endif
endif

# Filter out random types, so it'll reset to UNOFFICIAL
ifeq ($(filter RELEASE NIGHTLY SNAPSHOT EXPERIMENTAL,$(CM_BUILDTYPE)),)
    CM_BUILDTYPE :=
endif

ifdef CM_BUILDTYPE
ifneq ($(CM_BUILDTYPE), SNAPSHOT)
ifdef CM_EXTRAVERSION
# Force build type to EXPERIMENTAL
            CM_BUILDTYPE := EXPERIMENTAL
# Remove leading dash from CM_EXTRAVERSION
            CM_EXTRAVERSION := $(shell echo $(CM_EXTRAVERSION) | sed 's/-//')
# Add leading dash to CM_EXTRAVERSION
            CM_EXTRAVERSION := -$(CM_EXTRAVERSION)
endif
else
ifndef CM_EXTRAVERSION
# Force build type to EXPERIMENTAL, SNAPSHOT mandates a tag
            CM_BUILDTYPE := EXPERIMENTAL
else
# Remove leading dash from CM_EXTRAVERSION
            CM_EXTRAVERSION := $(shell echo $(CM_EXTRAVERSION) | sed 's/-//')
# Add leading dash to CM_EXTRAVERSION
            CM_EXTRAVERSION := -$(CM_EXTRAVERSION)
endif
endif
else
# If CM_BUILDTYPE is not defined, set to UNOFFICIAL
    CM_BUILDTYPE := UNOFFICIAL
    CM_EXTRAVERSION :=
endif

Bean_Version=4.4.275
CM_VERSION := SOKP-$(Bean_Version)-$(shell date -u +%Y%m%d)$(CM_EXTRAVERSION)-$(CM_BUILD)

PRODUCT_PROPERTY_OVERRIDES += \
  ro.cm.version=$(CM_VERSION) \
  ro.modversion=$(CM_VERSION) \
  ro.bs=true \
  ro.goo.developerid=beanstalk \
  ro.goo.rom=$(CM_BUILD) \
  ro.goo.version=22

-include vendor/cm-priv/keys/keys.mk

-include $(WORKSPACE)/build_env/image-auto-bits.mk

-include vendor/cyngn/product.mk
