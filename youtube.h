#ifndef YouTube_H
#define YouTube_H

#include <QObject>
#include <QByteArray>
#include <QtNetwork/QNetworkAccessManager>
#include <QUrl>
#include <QFile>
#include <QTime>
#include <QVariantMap>

class QNetworkAccessManager;
class QNetworkReply;

class YouTube : public QObject {
    Q_OBJECT

public:
    explicit YouTube(QObject *parent = 0);
    virtual ~YouTube();
    void setNetworkAccessManager(QNetworkAccessManager *manager);

public slots:
    QString getDeveloperKey() const { return QString(developerKey); }
    void setPlaybackQuality(const QString &quality);
    void getVideoUrl(const QString &videoId);

private slots:
    void parseVideoPage();

private:
    QNetworkReply *reply;
    QNetworkAccessManager *nam;
    QByteArray developerKey;
    int playbackFormat;
    QHash<QString, int> pbMap;
    QString message;

signals:
    void gotVideoUrl(const QString &videoUrl);
    void videoUrlError();
    void alert(const QString &message);
};

#endif // YouTube_H
