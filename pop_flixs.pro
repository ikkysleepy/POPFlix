# Add more folders to ship with the application, here
folder_01.source = qml/pop_flixs
folder_01.target = qml
folder_components.target = qml/pop_flixs

DEPLOYMENTFOLDERS = folder_01

# Additional import path used to resolve QML modules in Creator's code model
QML_IMPORT_PATH =

symbian:TARGET.UID3 = 0xE419420A

# Smart Installer package's UID
# This UID is from the protected range and therefore the package will
# fail to install if self-signed. By default qmake uses the unprotected
# range value if unprotected UID is defined for the application and
# 0x2002CCCF value if protected UID is given to the application
#symbian:DEPLOYMENT.installer_header = 0x2002CCCF

# Allow network access on Symbian
symbian:TARGET.CAPABILITY += NetworkServices

# If your application uses the Qt Mobility libraries, uncomment the following
# lines and add the respective components to the MOBILITY variable.
CONFIG += mobility
MOBILITY = location
MOBILITY += systeminfo
CONFIG += meegotouch
CONFIG += shareuiinterface-maemo-meegotouch mdatauri

# Speed up launching on MeeGo/Harmattan when using applauncherd daemon
CONFIG += qdeclarative-boostable
QMAKE_CXXFLAGS += -fPIC -fvisibility=hidden -fvisibility-inlines-hidden
QMAKE_LFLAGS += -pie -rdynamic

# Add dependency to Symbian components
# CONFIG += qt-components

# The .cpp file which was generated for your project. Feel free to hack it.
SOURCES += main.cpp \
    geohelper.cpp \
    QReverseGeocode.cpp \
    sharehelper.cpp \
    imagesaver.cpp \
    youtube.cpp

# Includ Scirpt for Reverse GeoCode
QT += script
QT += declarative webkit network

# Please do not modify the following two lines. Required for deployment.
include(qmlapplicationviewer/qmlapplicationviewer.pri)
qtcAddDeployment()

OTHER_FILES += \
    qtc_packaging/debian_harmattan/rules \
    qtc_packaging/debian_harmattan/README \
    qtc_packaging/debian_harmattan/manifest.aegis \
    qtc_packaging/debian_harmattan/copyright \
    qtc_packaging/debian_harmattan/control \
    qtc_packaging/debian_harmattan/compat \
    qtc_packaging/debian_harmattan/changelog \
    qml/pop_flixs/About.qml \
    qml/pop_flixs/BoxSelectionDialogCountry.qml \
    qml/pop_flixs/ChangeLocation.qml \
    qml/pop_flixs/Directions.qml \
    qml/pop_flixs/GradientBackground.qml \
    qml/pop_flixs/Header.qml \
    qml/pop_flixs/InfoBanner.qml \
    qml/pop_flixs/main.qml \
    qml/pop_flixs/MainPage.qml \
    qml/pop_flixs/MovieDetails.qml \
    qml/pop_flixs/MoviePage.qml \
    qml/pop_flixs/Pull2Update.qml \
    qml/pop_flixs/Reviews.qml \
    qml/pop_flixs/Settings.qml \
    qml/pop_flixs/showtimes.qml \
    qml/pop_flixs/theater.qml \
    qml/pop_flixs/theaters.qml \
    qml/pop_flixs/trailer.qml \
    qml/pop_flixs/Updating.qml

HEADERS += \
    geohelper.h \
    QReverseGeocode.h \
    sharehelper.h \
    imagesaver.h \
    youtube.h
