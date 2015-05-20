#ifndef GEOHELPER_H
#define GEOHELPER_H

#include <QObject>
#include <QMap>


#include <QGeoServiceProvider>
#include <QGeoMappingManager>
#include <QGeoSearchManager>
#include <QGeoRoutingManager>

#include <QDeclarativeEngine>
#include <QGeoRouteReply>
#include <QGeoRouteRequest>

#include <QGeoCoordinate>

#include <QDeclarativeItem>
#include <QGeoMapPolylineObject>
#include <QGeoMapPixmapObject>
#include <QGeoMapTextObject>


QTM_USE_NAMESPACE


class GeoHelper : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QDeclarativeItem* map READ map WRITE setMap)
public:
    explicit GeoHelper(QObject *parent = 0);
    ~GeoHelper();

    QDeclarativeItem *map() const {return mapitem; }
    void setMap(QDeclarativeItem *map) { mapitem = map; listRef = QDeclarativeListReference(mapitem, "objects");};

    Q_INVOKABLE void findRoute(double fromLatitude, double fromLongitude, double toLatitude, double toLongitude);
    Q_INVOKABLE void findAddress(double latitude, double longitude);
    Q_INVOKABLE void findCoordinates(QString street, QString city, QString country = QString("FINLAND"));
    Q_INVOKABLE void clearMap();
    Q_INVOKABLE void removeFromMap(QString id);
    Q_INVOKABLE void drawPolyline(QString id, QString coordinateArr);
    Q_INVOKABLE void drawImage(QString id, double latitude, double longitude, QString imagepath, int xOffset, int yOffset);
    Q_INVOKABLE void drawText(QString id, double latitude, double longitude, QString text);
    Q_INVOKABLE void findObjectsInCoordinates(double latitude, double longitude);


signals:
    void searchError(const QString &error);
    void routingError(const QString &error);

    void searchReply(const QString &reply);
    void routingReply(const QString &reply);

    void geomapobjectSelected(QString id, bool selected);

    void debugMsg(const QString &reply);


private slots:
    void searchErrorSlot(QGeoSearchReply *reply, QGeoSearchReply::Error error, QString errorString = QString());
    void searchFinishedSlot(QGeoSearchReply *reply);

    void routingErrorSlot(QGeoRouteReply *reply, QGeoRouteReply::Error error, QString errorString);
    void routingFinishedSlot(QGeoRouteReply * reply);



private:

    QGeoServiceProvider* provider;
    QGeoMappingManager* mappingManager;
    QGeoSearchManager* searchManager;
    QGeoRoutingManager* routingManager;
    QDeclarativeContext* context;
    QDeclarativeItem* mapitem;


    QMap<QString, QGeoMapObject *> mapobjects;
    QDeclarativeListReference listRef;

};

#endif // GEOHELPER_H
