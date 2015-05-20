#include "geohelper.h"

#include <QScriptEngine>
#include <QScriptValue>
#include <QScriptValueIterator>

#include <QDeclarativeListReference>
#include <QGeoMapRouteObject>


GeoHelper::GeoHelper(QObject *parent) :
    QObject(parent)
{
    provider = new QGeoServiceProvider("nokia");

    mappingManager = provider->mappingManager();
    searchManager = provider->searchManager();
    routingManager = provider->routingManager();
    mapitem = NULL;

    QObject::connect(searchManager, SIGNAL(error(QGeoSearchReply *, QGeoSearchReply::Error, QString)), this, SLOT(searchErrorSlot(QGeoSearchReply *, QGeoSearchReply::Error, QString)));
    QObject::connect(searchManager, SIGNAL(finished(QGeoSearchReply*)), this, SLOT(searchFinishedSlot(QGeoSearchReply*)));

    QObject::connect(routingManager, SIGNAL(error(QGeoRouteReply*, QGeoRouteReply::Error, QString)), this, SLOT(routingErrorSlot(QGeoRouteReply*, QGeoRouteReply::Error, QString)));
    QObject::connect(routingManager, SIGNAL(finished(QGeoRouteReply*)), this, SLOT(routingFinishedSlot(QGeoRouteReply*)));
}

GeoHelper::~GeoHelper()
{
    clearMap();

    if (provider)
    {
        delete provider;
        provider = NULL;
    }
}


void GeoHelper::searchErrorSlot(QGeoSearchReply *reply, QGeoSearchReply::Error error, QString errorString)
{
    emit searchError(errorString);
}

void GeoHelper::searchFinishedSlot(QGeoSearchReply *reply)
{
    if (reply->error() == QGeoSearchReply::NoError)
    {
        QScriptEngine scriptEngine;
        QScriptValue replyObject = scriptEngine.newArray();

        QList<QGeoPlace> places = reply->places();
        for (int i = 0; i < places.count(); i++)
        {
            QScriptValue placeObject = scriptEngine.newObject();

            QScriptValue coordinateObject = scriptEngine.newObject();
            QGeoCoordinate coordinate = places[i].coordinate();
            coordinateObject.setProperty("latitude", QScriptValue(coordinate.latitude()));
            coordinateObject.setProperty("longitude", QScriptValue(coordinate.longitude()));
            placeObject.setProperty("coordinate", coordinateObject);

            QScriptValue addressObject = scriptEngine.newObject();
            QGeoAddress address = places[i].address();

            if (!address.isEmpty())
            {
                addressObject.setProperty("country", address.country());
                addressObject.setProperty("countryCode", address.countryCode());
                addressObject.setProperty("state", address.state());
                addressObject.setProperty("county", address.county());
                addressObject.setProperty("city", address.city());
                addressObject.setProperty("district", address.district());
                addressObject.setProperty("street", address.street());
                addressObject.setProperty("postcode", address.postcode());

            }

            placeObject.setProperty("address", addressObject);
            replyObject.setProperty(i, placeObject);
        }


        QScriptValue fun = scriptEngine.evaluate("(function(a) { return JSON.stringify(a); })");
        QScriptValueList args;
        args << replyObject;
        QScriptValue result = fun.call(QScriptValue(), args);

        emit searchReply(result.toString());
    }


}

void GeoHelper::routingErrorSlot(QGeoRouteReply *reply, QGeoRouteReply::Error error, QString errorString)
{
    emit routingError(errorString);
}


void GeoHelper::routingFinishedSlot(QGeoRouteReply * reply)
{

    if (reply->error() == QGeoRouteReply::NoError)
    {
        QScriptEngine scriptEngine;
        QScriptValue replyObject = scriptEngine.newArray();

        QList<QGeoCoordinate> waypoints = reply->request().waypoints();
        double lat1 = 0;
        double lon1 = 0;
        double lat2 = 0;
        double lon2 = 0;

        if (waypoints.count() > 0)
        {
            /*
            QString msg = QString("lat %1, lon %2 => lat %3, lon %4").
                    arg(waypoints.at(0).latitude()).arg(waypoints.at(0).longitude()).
                    arg(waypoints.at((waypoints.count()-1)).latitude()).arg(waypoints.at((waypoints.count()-1)).longitude());
            emit routingError(msg);
            */
            lat1 = waypoints.at(0).latitude();
            lon1 = waypoints.at(0).longitude();
            lat2 = waypoints.at((waypoints.count()-1)).latitude();
            lon2 = waypoints.at((waypoints.count()-1)).longitude();

        }


        for (int i = 0; i < reply->routes().size(); ++i)
        {
            QScriptValue routeObject = scriptEngine.newObject();
            QGeoRoute route = reply->routes().at(i);

            routeObject.setProperty("distance", QScriptValue(route.distance()));
            routeObject.setProperty("travelTime", QScriptValue(route.travelTime()));
            routeObject.setProperty("lat1", QScriptValue(lat1));
            routeObject.setProperty("lon1", QScriptValue(lon1));
            routeObject.setProperty("lat2", QScriptValue(lat2));
            routeObject.setProperty("lon2", QScriptValue(lon2));


            QScriptValue pathObject = scriptEngine.newArray();
            QList<QGeoCoordinate> path = route.path();
            for (int p = 0; p < path.length(); p++)
            {
                QScriptValue coordinateObject = scriptEngine.newObject();
                coordinateObject.setProperty("latitude", QScriptValue(path[p].latitude()));
                coordinateObject.setProperty("longitude", QScriptValue(path[p].longitude()));
                pathObject.setProperty(p, coordinateObject);

            }

            routeObject.setProperty("path", pathObject);

            replyObject.setProperty(i, routeObject);

        }

        QScriptValue fun = scriptEngine.evaluate("(function(a) { return JSON.stringify(a); })");
        QScriptValueList args;
        args << replyObject;
        QScriptValue result = fun.call(QScriptValue(), args);

        emit routingReply(result.toString());

    }
}

// ------------- Q_INVOKABLE METHODS -------

void GeoHelper::removeFromMap(QString id)
{
    if (mapobjects.contains(id))
    {

        QGeoMapObject *obj = mapobjects.take(id);
        if (obj != NULL)
        {
            delete obj;
            obj = NULL;
        }

        // Now we have to construct the map's objects list again
        // this is because the objects list does not have a method
        // to remove a single object.
        for (int i = 0; i < listRef.count(); i++)
            listRef.at(i)->deleteLater();

        listRef.clear();

        QStringList keys = mapobjects.keys();
        foreach (QString id, keys)
        {
            emit debugMsg("lisaa uudestaan " + id);
            QGeoMapObject *obj = mapobjects.value(id);
            if (obj != NULL)
            {
                if (obj->type() == QGeoMapObject::PolylineType)
                {
                    QGeoMapPolylineObject *newobj = new QGeoMapPolylineObject;
                    newobj->setPath(((QGeoMapPolylineObject *)obj)->path());
                    newobj->setPen(QPen(QBrush(Qt::blue), 4));
                    newobj->setObjectName(obj->objectName());

                    listRef.append(newobj);
                }
                else if (obj->type() == QGeoMapObject::PixmapType)
                {
                    QGeoMapPixmapObject *newobj = new QGeoMapPixmapObject;
                    newobj->setCoordinate(((QGeoMapPixmapObject *)obj)->coordinate());
                    newobj->setPixmap(((QGeoMapPixmapObject *)obj)->pixmap());
                    newobj->setOffset(QPoint(-10,-34));
                    newobj->setObjectName(obj->objectName());

                    listRef.append(newobj);
                }
            }
        }
    }
}

void GeoHelper::clearMap()
{

    QStringList keys = mapobjects.keys();
    foreach (QString id, keys)
    {
        QGeoMapObject *obj = mapobjects.take(id);
        if (obj != NULL)
        {
            delete obj;
            obj = NULL;
        }
    }

    mapobjects.clear();

    for (int i = 0; i < listRef.count(); i++)
        listRef.at(i)->deleteLater();

    listRef.clear();
}

void GeoHelper::drawPolyline(QString id, QString coordinateArr)
{
    /*
        [
                {"latitude":61.4735985,"longitude":23.7550697},
                {"latitude":61.4735985,"longitude":23.7550697}
        ]

    */


    if (mapitem != NULL)
    {
        removeFromMap(id);

        QScriptValue sc;
        QScriptEngine engine;
        sc = engine.evaluate("(" + QString(coordinateArr) + ")");

        if (sc.isArray())
        {

             QScriptValueIterator it(sc);
             QList<QGeoCoordinate> coordinates;

             while (it.hasNext())
             {
                 it.next();
                 if (it.value().property("latitude").toString() != "" && it.value().property("longitude").toString() != "")
                 {
                    coordinates << QGeoCoordinate(it.value().property("latitude").toNumber(),it.value().property("longitude").toNumber());
                 }
             }

             QGeoMapPolylineObject *obj = new QGeoMapPolylineObject;
             obj->setPath(coordinates);
             obj->setPen(QPen(QBrush(Qt::blue), 4));
             obj->setObjectName(id);

             listRef.append(obj);

             // keep a copy to construct the map objects list again
             QGeoMapPolylineObject *copyobj = new QGeoMapPolylineObject;
             copyobj->setPath(coordinates);
             copyobj->setPen(QPen(QBrush(Qt::blue), 4));
             copyobj->setObjectName(id);
             mapobjects.insert(id,copyobj);



        }
    }
}

void GeoHelper::drawImage(QString id, double latitude, double longitude, QString imagepath, int xOffset, int yOffset)
{

    if (mapitem != NULL)
    {

        //emit debugMsg(QString("offset: %1, %2").arg(xOffset).arg(yOffset));

        removeFromMap(id);
        QGeoMapPixmapObject *obj = new QGeoMapPixmapObject;
        obj->setCoordinate(QGeoCoordinate(latitude,longitude));
        obj->setPixmap(imagepath);
        obj->setOffset(QPoint(xOffset,yOffset));
        //obj->setOffset(QPoint(-10,-34));
        obj->setObjectName(id);

        listRef.append(obj);

        // keep a copy to construct the map objects list again
        QGeoMapPixmapObject *copyobj = new QGeoMapPixmapObject;
        copyobj->setCoordinate(QGeoCoordinate(latitude,longitude));
        copyobj->setPixmap(imagepath);
        copyobj->setOffset(QPoint(xOffset,yOffset));
        //copyobj->setOffset(QPoint(-10,-34));
        copyobj->setObjectName(id);
        mapobjects.insert(id,copyobj);


    }

}



QBrush usebrush(Qt::darkRed);
QPen usepen(usebrush,1);
QFont usefont("Terminal", 12);



void GeoHelper::drawText(QString id, double latitude, double longitude, QString text)
{

    if (mapitem != NULL)
    {

        //emit debugMsg(QString("offset: %1, %2").arg(xOffset).arg(yOffset));

        removeFromMap(id);
        QGeoMapTextObject *obj = new QGeoMapTextObject;
        obj->setCoordinate(QGeoCoordinate(latitude,longitude));
        obj->setText(text);
        obj->setFont(usefont);
        obj->setOffset(QPoint(20,-10));
        obj->setAlignment(Qt::AlignLeft | Qt::AlignBottom);
        obj->setBrush(usebrush);
        obj->setPen(usepen);
        obj->setObjectName(id);

        listRef.append(obj);

        // keep a copy to construct the map objects list again
        QGeoMapTextObject *copyobj = new QGeoMapTextObject;
        copyobj->setCoordinate(QGeoCoordinate(latitude,longitude));
        copyobj->setText(text);
        copyobj->setFont(usefont);
        copyobj->setOffset(QPoint(20,-10));
        copyobj->setAlignment(Qt::AlignLeft | Qt::AlignBottom);
        copyobj->setBrush(usebrush);
        copyobj->setPen(usepen);
        copyobj->setObjectName(id);
        mapobjects.insert(id,copyobj);

    }

}

void GeoHelper::findObjectsInCoordinates(double latitude, double longitude)
{
    QGeoCoordinate coord(latitude, longitude);

    for (int i = 0; i < listRef.count(); i++)
    {
        if ( ((QGeoMapObject *)listRef.at(i))->contains(coord))
        {
            emit geomapobjectSelected(listRef.at(i)->objectName(), true);
        }
    }

}

void GeoHelper::findRoute(double fromLatitude, double fromLongitude, double toLatitude, double toLongitude)
{
    QGeoRouteRequest *geoRouteRequest = new QGeoRouteRequest(QGeoCoordinate(fromLatitude, fromLongitude), QGeoCoordinate(toLatitude, toLongitude));
    routingManager->calculateRoute(*geoRouteRequest);
}

void GeoHelper::findAddress(double latitude, double longitude)
{
    QGeoCoordinate location(latitude,longitude);
    searchManager->reverseGeocode(location);
}

void GeoHelper::findCoordinates(QString street, QString city, QString country)
{

    QGeoAddress address;
    address.setStreet(street);
    address.setCity(city);
    address.setCountry(country);
    searchManager->geocode(address);
}
