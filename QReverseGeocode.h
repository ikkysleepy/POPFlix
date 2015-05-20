#ifndef _QREVERSEGEOCODE_H_
#define _QREVERSEGEOCODE_H_

#include <QNetworkConfigurationManager>
#include <QNetworkSession>
#include <QNetworkProxy>
#include <QNetworkProxyFactory>
#include <QGeoServiceProvider>
#include <QGeoSearchManager>
#include <QtCore>

QTM_USE_NAMESPACE

class QReverseGeocode : public QObject
 {
    Q_OBJECT
    Q_PROPERTY (double latitude  READ latitude WRITE setLatitude NOTIFY latitudeChanged)
    Q_PROPERTY (double longitude READ longitude WRITE setLongitude NOTIFY longitudeChanged)

    Q_PROPERTY (QString city READ city)
    Q_PROPERTY (QString postCode READ postCode)
    Q_PROPERTY (QString street READ street)
    Q_PROPERTY (QString state READ state)
    Q_PROPERTY (QString country READ country)

public:
    QReverseGeocode (QObject *parent = 0);
    double latitude () const {return m_latitude;}
    double longitude () const {return m_longitude;}
    void setLatitude (double&);
    void setLongitude(double&);

    QString street() const { return m_street;}
    QString city() const { return m_city;}
    QString state() const { return m_state;}
    QString postCode() const { return m_postCode;}
    QString country() const { return m_country;}

signals:
    void latitudeChanged();
    void longitudeChanged();
    void reverseGeocodeFinished();

public slots:
    void process();

private slots:
    void networkSessionOpened();
    void error(QNetworkSession::SessionError error);
    void finished();
    void resultsError(QGeoSearchReply::Error errorCode, QString errorString);

private:
    void setProvider(QString providerId);

private:
    double m_latitude;
    double m_longitude;

    QString m_street;
    QString m_city;
    QString m_state;
    QString m_postCode;
    QString m_country;

    QNetworkSession*        m_session;
    QNetworkConfigurationManager m_manager;
    QGeoServiceProvider*    m_serviceProvider;
    QGeoSearchManager*      m_searchManager;

    // Fix for no provider
    QGeoServiceProvider* provider;
    QGeoMappingManager* m_mapManager;

};

#endif // _QREVERSEGEOCODE_H_
