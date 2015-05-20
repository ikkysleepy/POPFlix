#include <QtGui/QApplication>
#include "qmlapplicationviewer.h"

// Image Lib
#include <imagesaver.h>

// GPS Libs
#include <QtDeclarative>
#include "QReverseGeocode.h"
#include "geohelper.h"

// Share Lib
#include "sharehelper.h"

// Youtube
#include "youtube.h"

Q_DECL_EXPORT int main(int argc, char *argv[])
{
    QScopedPointer<QApplication> app(createApplication(argc, argv));

    // Register Geo Helpers
    qmlRegisterType<QReverseGeocode>("QReverseGeocode", 1, 0, "QReverseGeocode");
    qmlRegisterType<GeoHelper>("GeoHelper",1,0,"GeoHelper");

    // Register Share
    qmlRegisterType<ShareHelper>("cz.vutbr.fit.pcmlich", 1, 0, "ShareHelper");

    QmlApplicationViewer viewer;

    // Youtube
    YouTube yt;
    QNetworkAccessManager *manager = new QNetworkAccessManager();
    yt.setNetworkAccessManager(manager);
    QDeclarativeContext *context = viewer.rootContext();
    context->setContextProperty("YouTube", &yt);

    // New Temp Folder Location
    QString cache = "/home/user/popflix";
    context->setContextProperty("appCache", cache);

    // Set Image saver
    ImageSaver imageSaver;
    viewer.rootContext()->setContextProperty("imageSaver", &imageSaver);

    viewer.setOrientation(QmlApplicationViewer::ScreenOrientationAuto);
    viewer.setMainQmlFile(QLatin1String("qml/pop_flixs/main.qml"));
    viewer.showExpanded();

    return app->exec();
}
