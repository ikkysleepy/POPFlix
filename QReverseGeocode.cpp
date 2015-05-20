#include "QReverseGeocode.h"

QReverseGeocode::QReverseGeocode (QObject *parent)
    : QObject(parent)
{
    QNetworkConfigurationManager manager;
    const bool canStartIAP = (manager.capabilities() & QNetworkConfigurationManager::CanStartAndStopInterfaces);

    QNetworkConfiguration cfg = manager.defaultConfiguration();
    if(cfg.isValid() && (canStartIAP && cfg.state() == QNetworkConfiguration::Active)) {
        m_session = new QNetworkSession(cfg, this);
        connect(m_session, SIGNAL(opened()), this, SLOT(networkSessionOpened()));
        connect(m_session,SIGNAL(error(QNetworkSession::SessionError)),this,SLOT(error(QNetworkSession::SessionError)));
        m_session->open();
    }
}

void QReverseGeocode::networkSessionOpened()
{
    QString urlEnv = QProcessEnvironment::systemEnvironment().value("http_proxy");
    if (!urlEnv.isEmpty())
    {
        QUrl url = QUrl(urlEnv, QUrl::TolerantMode);
        QNetworkProxy proxy;
        proxy.setType(QNetworkProxy::HttpProxy);
        proxy.setHostName(url.host());
        proxy.setPort(url.port(8080));
        QNetworkProxy::setApplicationProxy(proxy);
    }
    else
        QNetworkProxyFactory::setUseSystemConfiguration(true);

    //get provider, we are hardcoding it to nokia
    setProvider("nokia");

}

void QReverseGeocode::setProvider(QString providerId)
{
    if (m_serviceProvider)  delete m_serviceProvider;
    m_serviceProvider = new QGeoServiceProvider(providerId);
    if (m_serviceProvider->error() != QGeoServiceProvider::NoError)
    {
        return;
    }

    //m_mapManager = m_serviceProvider->mappingManager();
    m_searchManager = m_serviceProvider->searchManager();
}

void QReverseGeocode::process()
{
    // Fix for no provider
    provider = new QGeoServiceProvider("nokia");
    m_searchManager = provider->searchManager();

    if(!m_searchManager) { return; }
    QGeoSearchReply *reply = m_searchManager->reverseGeocode(QGeoCoordinate(m_latitude, m_longitude));
    QObject::connect(reply, SIGNAL(finished()), this,SLOT(finished()));
    QObject::connect(reply,SIGNAL(error(QGeoSearchReply::Error, QString)), this,SLOT(resultsError(QGeoSearchReply::Error, QString)));
}


void QReverseGeocode::finished()
{
    QGeoSearchReply* reply = static_cast<QGeoSearchReply *>(sender());

    if (reply->error() != QGeoSearchReply::NoError) {
        // Errors are handled in a different slot (resultsError)
        return;
    }

    QList<QGeoPlace> places = reply->places();
    if (places.length() != 0) {
        m_street = places[0].address().street();
        m_city = places[0].address().city();
        m_state = places[0].address().state();
        m_postCode = places[0].address().postcode();
        m_country  = places[0].address().country();
        emit reverseGeocodeFinished();
    }

    disconnect(reply, SIGNAL(finished()), this,SLOT(reverseGeocodeFinished()));
    disconnect(reply,SIGNAL(error(QGeoSearchReply::Error, QString)), this,SLOT(resultsError(QGeoSearchReply::Error, QString)));
    reply->deleteLater();
}

void QReverseGeocode::setLatitude(double &latitude)
{
    if(m_latitude != latitude)
    {
        m_latitude = latitude;
        emit latitudeChanged();
    }
}

void QReverseGeocode::setLongitude(double &longitude)
{
    if(m_longitude != longitude) {
        m_longitude = longitude;
        emit longitudeChanged();
    }
}

void QReverseGeocode::resultsError(QGeoSearchReply::Error errorCode, QString errorString)
{
    QObject* reply = static_cast<QGeoSearchReply *>(sender());
    disconnect(reply, SIGNAL(finished()), this,SLOT(searchReplyFinished()));
    disconnect(reply,SIGNAL(error(QGeoSearchReply::Error, QString)), this,SLOT(resultsError(QGeoSearchReply::Error, QString)));
    reply->deleteLater();
}

void QReverseGeocode::error(QNetworkSession::SessionError error)
{
    if (error == QNetworkSession::UnknownSessionError)
    {
        if (m_session->state() == QNetworkSession::Connecting)
        {

        }
    } else
    if (error == QNetworkSession::SessionAbortedError) {


    }
}


