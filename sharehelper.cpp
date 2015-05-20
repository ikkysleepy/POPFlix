#include "sharehelper.h"
#include <QImage>

/*
  .pro
CONFIG += meegotouch
CONFIG += shareuiinterface-maemo-meegotouch mdatauri
  */

#include <QDeclarativeContext>
#ifndef QT_SIMULATOR
    #include <maemo-meegotouch-interfaces/shareuiinterface.h>
    #include <MDataUri>
#endif


ShareHelper::ShareHelper(QObject *parent) :
    QObject(parent)
{
}

void ShareHelper::share(QString title, QString url, QString desc) {
#ifndef QT_SIMULATOR
    MDataUri dataUri;

/*
    QImage image;
    image.load(url);
    QByteArray body;
    QBuffer buffer(&body);
    buffer.open(QIODevice::WriteOnly);
    image.save(&buffer, "JPG");

    dataUri.setBinaryData(body);
    dataUri.setMimeType("image/jpeg");
*/

    dataUri.setMimeType("text/x-url");
    dataUri.setTextData(url);

    dataUri.setAttribute("title", title);
    dataUri.setAttribute("description", desc);

    qDebug() << dataUri.toString();

    QStringList items;
    items << dataUri.toString();
    ShareUiInterface shareIf("com.nokia.ShareUi");
    if (shareIf.isValid()) {
        shareIf.share(items);
    } else {
        qCritical() << "Invalid interface";
    }
#else
    Q_UNUSED(title)
    Q_UNUSED(url)
#endif
}
