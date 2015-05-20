#include "youtube.h"
#include <QtNetwork/QNetworkRequest>
#include <QtNetwork/QNetworkReply>
#include <QString>
#include <QRegExp>
#include <QUrl>
#include <QMap>
#include <QStringList>
#include <QTimer>
#include <QXmlStreamReader>
#include <QDebug>

#define EXCLUDED_CHARS " \n\t#[]{}=+$&*()<>@|',/\":;?"

YouTube::YouTube(QObject *parent) :
    QObject(parent), nam(0), developerKey("AI39si6x9O1gQ1Z_BJqo9j2n_SdVsHu1pk2uqvoI3tVq8d6alyc1og785IPCkbVY3Q5MFuyt-IFYerMYun0MnLdQX5mo2BueSw"), playbackFormat(18) {
    pbMap["480p"] = 35;
    pbMap["360p"] = 18;
    pbMap["Mobile"] = 5;
}

YouTube::~YouTube() {
}

void YouTube::setNetworkAccessManager(QNetworkAccessManager *manager) {
    nam = manager;
}

void YouTube::setPlaybackQuality(const QString &quality) {
    playbackFormat = pbMap.value(quality, 18);
}

void YouTube::getVideoUrl(const QString &videoId) {
    QString playerUrl = "http://www.youtube.com/get_video_info?&video_id=" + videoId + "&el=detailpage&ps=default&eurl=&gl=US&hl=en";
    QString host = playerUrl.right(playerUrl.length() - playerUrl.indexOf("://") - 3);
     host = host.left(host.indexOf("/"));
    QString refererS = "http://www.youtube.com/watch?v="+ videoId;
    QNetworkAccessManager *manager = new QNetworkAccessManager(this);
    QNetworkRequest request;
    request.setUrl(QUrl(playerUrl));
    request.setRawHeader("Host",host.toAscii());
    request.setRawHeader("Referer",refererS.toAscii());
    request.setRawHeader("User-Agent", "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_8_2) AppleWebKit/536.26.14 (KHTML, like Gecko) Version/6.0.1 Safari/536.26.14");
    request.setAttribute(QNetworkRequest::CookieSaveControlAttribute,
    QVariant(true));
    request.setRawHeader("Accept", "text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8");
    request.setRawHeader("Accept-Language", "ru,en-us;q=0.7,en;q=0.3");
    request.setRawHeader("Accept-Encoding", "gzip,deflate");
    request.setRawHeader("Accept-Charset", "windows-1251,utf-8;q=0.7,*;q=0.7");
    request.setRawHeader("Keep-Alive", "300");
    request.setRawHeader("Connection", "keep-alive");
    request.setRawHeader("Content-Type", "application/x-www-form-urlencoded");

    reply = manager->get(request);
    connect(reply, SIGNAL(finished()), this, SLOT(parseVideoPage()));
}

void YouTube::parseVideoPage() {
    disconnect(reply, SIGNAL(finished()), this, SLOT(parseVideoPage()));
    if (!reply->error())
     {
         QMap<int, QString> formats;
         QString response(QByteArray::fromPercentEncoding(reply->readAll()));
         if (!response.contains("url_encoded_fmt_stream_map=")) {
             emit alert(tr("Unable to retrieve video. Access may be restricted"));
             emit videoUrlError();
         }
         else {
             response = response.section("url_encoded_fmt_stream_map=", 1, 1);
             QStringList parts = response.split("itag=", QString::SkipEmptyParts);
             QString part;
             QString url;
             int key;
             for (int i = 0; i < parts.length(); i++) {
                 part = parts[i];
                 key = part.left(part.indexOf('&')).toInt();
                 url = part.section("url=", 1, -1);
                 url = QByteArray::fromPercentEncoding(url.section("&quality", 0, 0).toUtf8()).replace("%2C", ",").replace("sig=", "signature=");
                 formats[key] = url;

                 qDebug() << key;
                 qDebug() << url;
                 qDebug() << "";
             }

             QList<int> flist;
             flist << pbMap.value("Mobile") << pbMap.value("360p") << pbMap.value("480p");
             QString videoUrl;
             int index = flist.indexOf(playbackFormat);
             while ((videoUrl == "") && index < flist.size()) {
                 videoUrl = formats.value(flist.at(index), "");
                 index++;
             }
             if (!videoUrl.startsWith("http")) {
                 emit alert(tr("Unable to retrieve video. Access may be restricted"));
                 emit videoUrlError();
             }
             else {
                 emit gotVideoUrl(videoUrl);
             }
         }

    }
    else
    {qDebug() << "Error mofo";
    }

}
