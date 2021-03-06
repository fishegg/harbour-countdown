# NOTICE:
#
# Application name defined in TARGET has a corresponding QML filename.
# If name defined in TARGET is changed, the following needs to be done
# to match new name:
#   - corresponding QML filename must be changed
#   - desktop icon filename must be changed
#   - desktop filename must be changed
#   - icon definition filename in desktop file must be changed
#   - translation filenames have to be changed

# The name of your application
TARGET = harbour-countdown

CONFIG += sailfishapp

SOURCES += src/harbour-countdown.cpp \
    src/settings.cpp

OTHER_FILES += qml/harbour-countdown.qml \
    qml/cover/CoverPage.qml \
    qml/pages/FirstPage.qml \
    rpm/harbour-countdown.spec \
    rpm/harbour-countdown.yaml \
    translations/*.ts \
    harbour-countdown.desktop \
    qml/pages/storage.js \
    translations/harbour-countdown-zh_CN.ts \
    qml/pages/AboutPage.qml \
    rpm/harbour-countdown.changes \
    qml/pages/EditDialog.qml \
    qml/images/harbour-countdown-new.png \
    qml/images/harbour-countdown.png

SAILFISHAPP_ICONS = 86x86 108x108 128x128 256x256

# to disable building translations every time, comment out the
# following CONFIG line
CONFIG += sailfishapp_i18n

# German translation is enabled as an example. If you aren't
# planning to localize your app, remember to comment out the
# following TRANSLATIONS line. And also do not forget to
# modify the localized app name in the the .desktop file.
TRANSLATIONS += translations/harbour-countdown-de.ts \
            translations/harbour-countdown-zh_CN.ts

DISTFILES += \
    qml/pages/SettingsDialog.qml \
    qml/pages/compute.js

HEADERS += \
    src/settings.h

